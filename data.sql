-- ======================================================================
-- 种子数据：为所有业务表填充友好的示例数据
-- 密码统一为 "123456"（scrypt 加密）
-- ======================================================================

-- ===========================
-- 1. 租户表 (sys_tenant)
-- ===========================
INSERT INTO public.sys_tenant (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, code,
                               "name", parent_id, contact_name, contact_phone, expired_at, max_user_count, default_locale)
VALUES ('t-super-01', 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01',
        'default', '默认租户', NULL, '系统管理员', '13800000000', NULL, 1000, 'zh-CN');

INSERT INTO public.sys_tenant (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, code,
                               "name", parent_id, contact_name, contact_phone, expired_at, max_user_count, default_locale)
VALUES ('t-demo-01', 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01',
        'demo', '演示租户', 't-super-01', '演示联系人', '13800000010', NULL, 50, 'zh-CN');

INSERT INTO public.sys_tenant (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, code,
                               "name", parent_id, contact_name, contact_phone, expired_at, max_user_count, default_locale)
VALUES ('t-test-01', 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01',
        'test', '测试租户', 't-super-01', '测试联系人', '13800000020', NULL, 100, 'zh-CN');

INSERT INTO public.sys_tenant (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, code,
                               "name", parent_id, contact_name, contact_phone, expired_at, max_user_count, default_locale)
VALUES ('t-dev-01', 1, 1, '2026-06-01 10:15:00.000', 1, '2026-06-01 10:15:00.000', NULL, 't-super-01',
        'dev', '开发租户', 't-super-01', '开发联系人', '13800000030', NULL, 200, 'zh-CN');

INSERT INTO public.sys_tenant (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, code,
                               "name", parent_id, contact_name, contact_phone, expired_at, max_user_count, default_locale)
VALUES ('t-stg-01', 1, 1, '2026-06-01 10:20:00.000', 1, '2026-06-01 10:20:00.000', NULL, 't-super-01',
        'staging', '预发布租户', 't-super-01', '预发布联系人', '13800000040', NULL, 100, 'zh-CN');


-- ===========================
-- 2. 部门表 (sys_dept)
--    构建组织树：总公司 → 技术部/产品部/设计部/市场部/财务部
--               技术部 → 前端组/后端组
-- ===========================

-- 1. 总公司（根节点）
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (1, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01',
        NULL, '总公司', 1);

-- 2. 技术部
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (2, 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01',
        1, '技术部', 1);

-- 3. 产品部
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (3, 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01',
        1, '产品部', 1);

-- 4. 设计部
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (4, 1, 1, '2026-06-01 10:15:00.000', 1, '2026-06-01 10:15:00.000', NULL, 't-super-01',
        1, '设计部', 1);

-- 5. 市场部
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (5, 1, 1, '2026-06-01 10:20:00.000', 1, '2026-06-01 10:20:00.000', NULL, 't-super-01',
        1, '市场部', 1);

-- 6. 财务部
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (6, 1, 1, '2026-06-01 10:25:00.000', 1, '2026-06-01 10:25:00.000', NULL, 't-super-01',
        1, '财务部', 1);

-- 7. 前端组（归属技术部）
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (7, 1, 1, '2026-06-01 10:30:00.000', 1, '2026-06-01 10:30:00.000', NULL, 't-super-01',
        2, '前端组', 1);

-- 8. 后端组（归属技术部）
INSERT INTO public.sys_dept (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             parent_id, "name", owner_user_id)
VALUES (8, 1, 1, '2026-06-01 10:35:00.000', 1, '2026-06-01 10:35:00.000', NULL, 't-super-01',
        2, '后端组', 1);


-- ===========================
-- 3. 角色表 (sys_role)
-- ===========================

-- 101. 超级管理员（系统预置，全租户数据范围）
INSERT INTO public.sys_role (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name",
                             code, role_type, data_scope, scope_dept_id, remark)
VALUES (101, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01',
        '超级管理员', 'super_admin', 1, 7, NULL, '系统预置角色，拥有全部数据权限，不可删除');

-- 102. 部门管理员（租户自定义，本部门及子部门）
INSERT INTO public.sys_role (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name",
                             code, role_type, data_scope, scope_dept_id, remark)
VALUES (102, 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01',
        '部门管理员', 'dept_admin', 2, 3, 2, '管理本部门及子部门的用户与数据');

-- 103. 普通用户（租户自定义，仅本人数据）
INSERT INTO public.sys_role (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name",
                             code, role_type, data_scope, scope_dept_id, remark)
VALUES (103, 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01',
        '普通用户', 'user', 2, 1, NULL, '默认角色，仅可操作本人数据');

-- 104. 审计员（租户自定义，全租户只读）
INSERT INTO public.sys_role (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name",
                             code, role_type, data_scope, scope_dept_id, remark)
VALUES (104, 1, 1, '2026-06-01 10:15:00.000', 1, '2026-06-01 10:15:00.000', NULL, 't-super-01',
        '审计员', 'auditor', 2, 7, NULL, '拥有全租户数据查看权限，用于合规审计');

-- 105. 演示租户管理员（归属演示租户）
INSERT INTO public.sys_role (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name",
                             code, role_type, data_scope, scope_dept_id, remark)
VALUES (105, 1, 1, '2026-06-01 10:20:00.000', 1, '2026-06-01 10:20:00.000', NULL, 't-demo-01',
        '租户管理员', 'tenant_admin', 2, 7, NULL, '演示租户的管理角色');


-- ===========================
-- 4. 角色数据范围表 (sys_role_id_scope)
--    为超级管理员指定可管理的用户 ID
-- ===========================

-- 超级管理员可管理用户 1（admin）
INSERT INTO public.sys_role_id_scope (id, status, "type", role_id, data_id, created_by, created_at, updated_by,
                                      updated_at, deleted_at, tenant_id)
VALUES (1001, 1, 1, 101, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01');

-- 超级管理员可管理部门 2（技术部）
INSERT INTO public.sys_role_id_scope (id, status, "type", role_id, data_id, created_by, created_at, updated_by,
                                      updated_at, deleted_at, tenant_id)
VALUES (1002, 1, 2, 101, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01');


-- ===========================
-- 5. 用户表 (sys_user)
--    密码统一为 "123456"
-- ===========================

-- 1. admin — 默认租户的系统管理员
INSERT INTO public.sys_user (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             owner_user_id, owner_dept_id, "name", nickname, "password", email, phone, last_login_at, remark, locale)
VALUES (1, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01',
        1, 1, 'admin', '系统管理员',
        '{scrypt}$e0801$A7n6UaC5UUO/K09rwLa00JQXL5WipLnXHmT/k8xfCDU7Ei3szBiwEPj0O5G/MKznY5Wb3tTkRZLH+IORCt43MQ==$cJKUQc+TRb9KKZSJp+OFn/Yx5p0alwV1G3dFyT2Jf2s=',
        'admin@example.com', '13800000001', '2026-06-30 08:00:00.000', '超级管理员账号', 'zh-CN');

-- 2. zhangsan — 技术部员工
INSERT INTO public.sys_user (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             owner_user_id, owner_dept_id, "name", nickname, "password", email, phone, last_login_at, remark, locale)
VALUES (2, 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01',
        1, 2, 'zhangsan', '张三',
        '{scrypt}$e0801$yVcA71vEiZj0CtnDIGwcXLkxU4e5p32yOlBIjss1SpeWyrPITLNc+AVe/L/SgMwt4R0vcbVpEhGJIAqTTlw1Xw==$fhAHFCCrA42OzBuKj4KYhXSfT4HMCbP2tiGgkmCpIBk=',
        'zhangsan@example.com', '13800000002', NULL, '技术部-后端组', 'zh-CN');

-- 3. lisi — 产品部员工
INSERT INTO public.sys_user (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             owner_user_id, owner_dept_id, "name", nickname, "password", email, phone, last_login_at, remark, locale)
VALUES (3, 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01',
        1, 3, 'lisi', '李四',
        '{scrypt}$e0801$Ztjk9jl3scCFvshR0OgATvTBSUqu5kYn0k803sKHm4GAoF43WujIOnG2x6PFELsSYLaTvHtTrmyCNPrjTX6kqg==$k0B6HCx4+DA4HPqMoxnZ+JDsW8aJBO6ch4G4tIXMGbQ=',
        'lisi@example.com', '13800000003', NULL, '产品部-产品经理', 'zh-CN');

-- 4. wangwu — 设计部员工
INSERT INTO public.sys_user (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             owner_user_id, owner_dept_id, "name", nickname, "password", email, phone, last_login_at, remark, locale)
VALUES (4, 1, 1, '2026-06-01 10:15:00.000', 1, '2026-06-01 10:15:00.000', NULL, 't-super-01',
        1, 4, 'wangwu', '王五',
        '{scrypt}$e0801$sMnGKuCundaB6372FYv4Gha7tpPEFQnD2cswbudIfhjRY392rrufnUnUV/NgET+EZ2nmMtpD39cUwNfPNrD8pQ==$F1q7Q6HCv+4vKeX8yKtmDP7sIzGW2D8hTntBnlyZ3fc=',
        'wangwu@example.com', '13800000004', NULL, '设计部-UI 设计师', 'zh-CN');

-- 5. zhaoliu — 演示租户用户
INSERT INTO public.sys_user (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                             owner_user_id, owner_dept_id, "name", nickname, "password", email, phone, last_login_at, remark, locale)
VALUES (5, 1, 1, '2026-06-01 10:20:00.000', 1, '2026-06-01 10:20:00.000', NULL, 't-demo-01',
        5, 1, 'zhaoliu', '赵六',
        '{scrypt}$e0801$3KDaCR21e9FCbuLRzxiNApLS4M8w5xzu82jgpM+7s9AfPUX8VlhnQauYkQLS9yyTVF0kaZ3K8sVyA/QnKSklLw==$Ptpyytpz0dPZJUWeWkCtGVEjigU9n5HxECEK6CbuJVk=',
        'zhaoliu@example.com', '13800000005', NULL, '演示租户的普通用户', 'zh-CN');


-- ===========================
-- 6. 用户角色映射表 (user_role_mapping)
-- ===========================

-- admin → 超级管理员
INSERT INTO public.user_role_mapping (user_id, role_id, tenant_id)
VALUES (1, 101, 't-super-01');

-- admin → 部门管理员（兼）
INSERT INTO public.user_role_mapping (user_id, role_id, tenant_id)
VALUES (1, 102, 't-super-01');

-- zhangsan → 普通用户
INSERT INTO public.user_role_mapping (user_id, role_id, tenant_id)
VALUES (2, 103, 't-super-01');

-- lisi → 普通用户
INSERT INTO public.user_role_mapping (user_id, role_id, tenant_id)
VALUES (3, 103, 't-super-01');

-- wangwu → 部门管理员
INSERT INTO public.user_role_mapping (user_id, role_id, tenant_id)
VALUES (4, 102, 't-super-01');

-- zhaoliu → 演示租户管理员
INSERT INTO public.user_role_mapping (user_id, role_id, tenant_id)
VALUES (5, 105, 't-demo-01');


-- ===========================
-- 7. 用户组表 (sys_user_group)
-- ===========================

-- 核心开发组
INSERT INTO public.sys_user_group (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                                   "name", code, owner_user_id, remark)
VALUES (1, 1, 1, '2026-06-01 10:30:00.000', 1, '2026-06-01 10:30:00.000', NULL, 't-super-01',
        '核心开发组', 'core_dev', 1, '核心技术团队成员');

-- 产品设计组
INSERT INTO public.sys_user_group (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id,
                                   "name", code, owner_user_id, remark)
VALUES (2, 1, 1, '2026-06-01 10:35:00.000', 1, '2026-06-01 10:35:00.000', NULL, 't-super-01',
        '产品设计组', 'product_design', 1, '产品与设计团队成员');


-- ===========================
-- 8. 用户组成员映射表 (sys_user_group_mapping)
-- ===========================

-- zhangsan → 核心开发组
INSERT INTO public.sys_user_group_mapping (group_id, user_id, tenant_id)
VALUES (1, 2, 't-super-01');

-- lisi → 产品设计组
INSERT INTO public.sys_user_group_mapping (group_id, user_id, tenant_id)
VALUES (2, 3, 't-super-01');

-- wangwu → 产品设计组
INSERT INTO public.sys_user_group_mapping (group_id, user_id, tenant_id)
VALUES (2, 4, 't-super-01');


-- ===========================
-- 9. 字典类型表 (sys_dict_type)
-- ===========================

-- 默认租户下的系统字典
INSERT INTO public.sys_dict_type (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name", code, remark)
VALUES (1, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01',
        '数据范围', 'sys_data_scope', '角色数据范围规则，对应 sys_role.data_scope 的取值');
INSERT INTO public.sys_dict_type (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name", code, remark)
VALUES (2, 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01',
        '角色类型', 'sys_role_type', '角色类型：系统预置 / 租户自定义');
INSERT INTO public.sys_dict_type (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, "name", code, remark)
VALUES (3, 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01',
        '数据状态', 'sys_data_status', '通用启用/禁用状态');


-- ===========================
-- 10. 字典数据表 (sys_dict_data)
-- ===========================

-- sys_data_scope 数据范围
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (1, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '仅本人', '1', 'integer', 1, '仅可查看和操作本人数据');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (2, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '本部门', '2', 'integer', 2, '可查看和操作本部门数据');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '本部门及子部门', '3', 'integer', 3, '可查看和操作本部门及所有子部门数据');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (4, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '指定人', '4', 'integer', 4, '仅可查看指定用户的数据');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (5, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '指定部门', '5', 'integer', 5, '仅可查看指定部门的数据');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (6, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '用户组', '6', 'integer', 6, '仅可查看所属用户组的数据');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (7, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01', 1, '全租户', '7', 'integer', 7, '可查看租户下全部数据');

-- sys_role_type 角色类型
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (8, 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01', 2, '系统预置', '1', 'integer', 1, '系统内置角色，不可删除，核心权限不可剥离');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (9, 1, 1, '2026-06-01 10:05:00.000', 1, '2026-06-01 10:05:00.000', NULL, 't-super-01', 2, '租户自定义', '2', 'integer', 2, '租户自行创建的角色，可删除');

-- sys_data_status 数据状态
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (10, 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01', 3, '启用', '1', 'integer', 1, '数据正常可用');
INSERT INTO public.sys_dict_data (id, status, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id, dict_type_id, label, value, value_type, sort_order, remark)
VALUES (11, 1, 1, '2026-06-01 10:10:00.000', 1, '2026-06-01 10:10:00.000', NULL, 't-super-01', 3, '禁用', '0', 'integer', 2, '数据被禁用');
