-- ============================================================
-- fun.sql — 权限过滤函数
--
-- 依赖：basic.sql（表结构与 RLS 策略）。建议在 basic.sql 之后执行。
--
-- 三个可直接用于 IN / = ANY 过滤的权限函数，按当前用户的
-- 有效角色 data_scope 计算可见范围，替代业务方手写权限子查询：
--
--   1. fn_accessible_user_ids(p_user_id)   有权访问的用户 ID 集合
--      → 用于 WHERE owner_user_id = ANY(...) 场景
--   2. fn_accessible_dept_ids(p_user_id)   有权访问的部门 ID 集合
--      → 用于 WHERE owner_dept_id = ANY(...) 场景
--   3. fn_accessible_group_ids(p_user_id)  有权访问的用户组 ID 集合
--      → 用于 WHERE owner_user_group_id = ANY(...) 场景
--
-- 返回值三态契约（NULL=全租户）：
--   NULL    不受限（任一有效角色 data_scope=7 全租户），业务方无需附加过滤
--   '{}'    拒绝一切（用户不存在/被禁用/被删除，或无任何有效角色）
--   数组    可见 ID 集合，多角色取并集去重
--
-- 纪律：NULL 只允许出现在 data_scope=7 的分支。过滤谓词把 NULL 当
-- "放行"语义，其余分支误返回 NULL 会放开整张表；CASE 判序保证用户
-- 无效/漏设租户时走 '{}' 拒绝分支（my_roles 为空即不可能命中 7 分支）。
--
-- 前置条件：会话已 SET app.tenant_id = '<租户ID>'。函数为
-- SECURITY INVOKER（默认）+ STABLE，内部查询自动受各表 RLS
-- 租户隔离约束，跨租户用户/部门天然不可见；漏设置时查不到任何
-- 角色，返回 '{}'（什么都看不到，不会误放行）。
--
-- 有效性判定（贯穿所有分支）：
--   当前用户   sys_user.status=1 且 deleted_at IS NULL，否则直接返回 '{}'
--   角色       sys_role.status=1 且 deleted_at IS NULL
--              （sys_user_role_mapping 为物理删除表，无状态位，无需过滤）
--   范围明细   sys_role_id_scope.status=1 且 deleted_at IS NULL
--   目标用户   sys_user.status=1 且 deleted_at IS NULL
--   目标部门   sys_dept.status=1 且 deleted_at IS NULL
--   目标用户组 sys_user_group.status=1 且 deleted_at IS NULL
--              （sys_user_group_mapping 为物理删除表，无状态位）
--
-- 使用示例：
--   -- 用户维度过滤（LATERAL 只求值一次，推荐）
--   SELECT t.*
--   FROM biz t
--   CROSS JOIN LATERAL public.fn_accessible_user_ids(:uid) AS p(uids)
--   WHERE p.uids IS NULL OR t.owner_user_id = ANY(p.uids);
--
--   -- 部门维度过滤（简写，函数会被求值两次，STABLE 保证两次结果一致）
--   SELECT * FROM biz
--   WHERE public.fn_accessible_dept_ids(:uid) IS NULL
--      OR owner_dept_id = ANY(public.fn_accessible_dept_ids(:uid));
--
--   -- IN 写法等价替代
--   SELECT * FROM biz
--   WHERE owner_dept_id IN (SELECT unnest(public.fn_accessible_dept_ids(:uid)));
--
-- 命名说明：与消费方项目 sqlc_zero_prj
-- （https://github.com/JNinng/sqlc_zero_prj ，其 sqlcpg/rls.sql 为同源实现）
-- 同名同构，模板与消费侧共用一套形态，避免同名异义漂移。
-- ============================================================


-- 1. 有权访问的用户 ID 集合

-- DROP FUNCTION IF EXISTS public.fn_accessible_user_ids(int8);

CREATE OR REPLACE FUNCTION public.fn_accessible_user_ids(p_user_id int8)
    RETURNS int8[]
    STABLE
    LANGUAGE sql
AS $$
WITH me AS (
    -- 当前用户必须存在且有效（RLS 已按 app.tenant_id 限定租户）
    SELECT u.id, u.owner_dept_id
    FROM public.sys_user u
    WHERE u.id = p_user_id
      AND u.status = 1
      AND u.deleted_at IS NULL
),
my_roles AS (
    -- 当前用户的有效角色：启用 + 未删除
    SELECT r.id, r.data_scope
    FROM public.sys_role r
             JOIN public.sys_user_role_mapping m ON m.role_id = r.id
    WHERE m.user_id = p_user_id
      AND r.status = 1
      AND r.deleted_at IS NULL
),
scoped AS (
    -- data_scope=1 仅本人
    SELECT me.id AS user_id
    FROM me
             JOIN my_roles r ON r.data_scope = 1

    UNION

    -- data_scope=2 本部门
    SELECT u.id
    FROM me
             JOIN my_roles r ON r.data_scope = 2
             JOIN public.sys_user u ON u.owner_dept_id = me.owner_dept_id
    WHERE u.status = 1
      AND u.deleted_at IS NULL

    UNION

    -- data_scope=3 本部门及子部门（closure 含 depth=0 自身）
    SELECT u.id
    FROM me
             JOIN my_roles r ON r.data_scope = 3
             JOIN public.sys_dept_closure c ON c.ancestor_id = me.owner_dept_id
             JOIN public.sys_user u ON u.owner_dept_id = c.descendant_id
    WHERE u.status = 1
      AND u.deleted_at IS NULL

    UNION

    -- data_scope=4 指定人
    SELECT s.data_id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 1
             JOIN public.sys_user u ON u.id = s.data_id
    WHERE r.data_scope = 4
      AND s.status = 1
      AND s.deleted_at IS NULL
      AND u.status = 1
      AND u.deleted_at IS NULL

    UNION

    -- data_scope=5 指定部门
    SELECT u.id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 2
             JOIN public.sys_dept d
                  ON d.id = s.data_id AND d.status = 1 AND d.deleted_at IS NULL
             JOIN public.sys_user u ON u.owner_dept_id = d.id
    WHERE r.data_scope = 5
      AND s.status = 1
      AND s.deleted_at IS NULL
      AND u.status = 1
      AND u.deleted_at IS NULL

    UNION

    -- data_scope=6 用户组
    SELECT gm.user_id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 3
             JOIN public.sys_user_group g
                  ON g.id = s.data_id AND g.status = 1 AND g.deleted_at IS NULL
             JOIN public.sys_user_group_mapping gm ON gm.group_id = g.id
             JOIN public.sys_user u ON u.id = gm.user_id
    WHERE r.data_scope = 6
      AND s.status = 1
      AND s.deleted_at IS NULL
      AND u.status = 1
      AND u.deleted_at IS NULL
)
SELECT CASE
           -- 用户不存在/被禁用/被删除：拒绝一切
           WHEN NOT EXISTS (SELECT 1 FROM me) THEN '{}'::int8[]
           -- 任一有效角色为全租户：不受限（NULL 只允许在这个分支返回）
           WHEN EXISTS (SELECT 1 FROM my_roles WHERE data_scope = 7) THEN NULL::int8[]
           -- 多角色并集；无有效角色时 array_agg 为 NULL，归一为空集合（默认拒绝）
           ELSE COALESCE((SELECT array_agg(DISTINCT user_id) FROM scoped), '{}'::int8[])
           END
$$;

COMMENT ON FUNCTION public.fn_accessible_user_ids(int8) IS '权限过滤：返回当前用户有权访问的用户 ID 集合。NULL=全租户不受限(data_scope=7)；{}=拒绝一切(用户无效或无有效角色)；数组=多角色 data_scope 并集。需先 SET app.tenant_id，自动受 RLS 租户隔离';


-- 2. 有权访问的部门 ID 集合

-- DROP FUNCTION IF EXISTS public.fn_accessible_dept_ids(int8);

CREATE OR REPLACE FUNCTION public.fn_accessible_dept_ids(p_user_id int8)
    RETURNS int8[]
    STABLE
    LANGUAGE sql
AS $$
WITH me AS (
    SELECT u.id, u.owner_dept_id
    FROM public.sys_user u
    WHERE u.id = p_user_id
      AND u.status = 1
      AND u.deleted_at IS NULL
),
my_roles AS (
    SELECT r.id, r.data_scope
    FROM public.sys_role r
             JOIN public.sys_user_role_mapping m ON m.role_id = r.id
    WHERE m.user_id = p_user_id
      AND r.status = 1
      AND r.deleted_at IS NULL
),
scoped AS (
    -- data_scope=1 仅本人：也算上自己所在部门，
    -- 保证自己的数据在按部门过滤时仍能看到
    SELECT me.owner_dept_id AS dept_id
    FROM me
             JOIN my_roles r ON r.data_scope = 1
    WHERE me.owner_dept_id IS NOT NULL

    UNION

    -- data_scope=2 本部门
    SELECT me.owner_dept_id
    FROM me
             JOIN my_roles r ON r.data_scope = 2
    WHERE me.owner_dept_id IS NOT NULL

    UNION

    -- data_scope=3 本部门及子部门
    SELECT c.descendant_id
    FROM me
             JOIN my_roles r ON r.data_scope = 3
             JOIN public.sys_dept_closure c ON c.ancestor_id = me.owner_dept_id

    UNION

    -- data_scope=4 指定人：目标用户归属部门
    SELECT u.owner_dept_id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 1
             JOIN public.sys_user u ON u.id = s.data_id
    WHERE r.data_scope = 4
      AND s.status = 1
      AND s.deleted_at IS NULL
      AND u.status = 1
      AND u.deleted_at IS NULL
      AND u.owner_dept_id IS NOT NULL

    UNION

    -- data_scope=5 指定部门
    SELECT d.id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 2
             JOIN public.sys_dept d ON d.id = s.data_id
    WHERE r.data_scope = 5
      AND s.status = 1
      AND s.deleted_at IS NULL
      AND d.status = 1
      AND d.deleted_at IS NULL

    UNION

    -- data_scope=6 用户组：组内有效成员归属部门
    SELECT u.owner_dept_id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 3
             JOIN public.sys_user_group g
                  ON g.id = s.data_id AND g.status = 1 AND g.deleted_at IS NULL
             JOIN public.sys_user_group_mapping gm ON gm.group_id = g.id
             JOIN public.sys_user u ON u.id = gm.user_id
    WHERE r.data_scope = 6
      AND s.status = 1
      AND s.deleted_at IS NULL
      AND u.status = 1
      AND u.deleted_at IS NULL
      AND u.owner_dept_id IS NOT NULL
)
SELECT CASE
           WHEN NOT EXISTS (SELECT 1 FROM me) THEN '{}'::int8[]
           WHEN EXISTS (SELECT 1 FROM my_roles WHERE data_scope = 7) THEN NULL::int8[]
           ELSE COALESCE((SELECT array_agg(DISTINCT dept_id) FROM scoped), '{}'::int8[])
           END
$$;

COMMENT ON FUNCTION public.fn_accessible_dept_ids(int8) IS '权限过滤：返回当前用户有权访问的部门 ID 集合（用于 owner_dept_id 过滤）。NULL=全租户不受限(data_scope=7)；{}=拒绝一切；数组=多角色 data_scope 并集。"仅本人"角色也会返回自己所在部门，保证自己的数据在按部门过滤时仍能看到。需先 SET app.tenant_id，自动受 RLS 租户隔离';


-- 3. 有权访问的用户组 ID 集合
-- 只有两种角色会返回结果：data_scope=6（角色在 sys_role_id_scope 里指定了
-- 用户组）和 data_scope=7（全部，返回 NULL）；其他角色对用户组没有可见性。

-- DROP FUNCTION IF EXISTS public.fn_accessible_group_ids(int8);

CREATE OR REPLACE FUNCTION public.fn_accessible_group_ids(p_user_id int8)
    RETURNS int8[]
    STABLE
    LANGUAGE sql
AS $$
WITH me AS (
    SELECT u.id
    FROM public.sys_user u
    WHERE u.id = p_user_id
      AND u.status = 1
      AND u.deleted_at IS NULL
),
my_roles AS (
    SELECT r.id, r.data_scope
    FROM public.sys_role r
             JOIN public.sys_user_role_mapping m ON m.role_id = r.id
    WHERE m.user_id = p_user_id
      AND r.status = 1
      AND r.deleted_at IS NULL
),
scoped AS (
    -- data_scope=6：角色指定的用户组
    SELECT s.data_id AS group_id
    FROM my_roles r
             JOIN public.sys_role_id_scope s
                  ON s.role_id = r.id AND s."type" = 3
             JOIN public.sys_user_group g
                  ON g.id = s.data_id AND g.status = 1 AND g.deleted_at IS NULL
    WHERE r.data_scope = 6
      AND s.status = 1
      AND s.deleted_at IS NULL
)
SELECT CASE
           WHEN NOT EXISTS (SELECT 1 FROM me) THEN '{}'::int8[]
           WHEN EXISTS (SELECT 1 FROM my_roles WHERE data_scope = 7) THEN NULL::int8[]
           ELSE COALESCE((SELECT array_agg(DISTINCT group_id) FROM scoped), '{}'::int8[])
           END
$$;

COMMENT ON FUNCTION public.fn_accessible_group_ids(int8) IS '权限过滤：返回当前用户有权访问的用户组 ID 集合（用于 owner_user_group_id 过滤）。只有两种角色返回结果：角色指定了用户组（data_scope=6）和全租户（data_scope=7，NULL 不过滤）；其他情况为 {}（该维度什么都看不到）。需先 SET app.tenant_id，自动受 RLS 租户隔离';
