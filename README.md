# basic-db-table

多租户 RBAC 基础数据库表结构，基于 PostgreSQL 18，涵盖租户、用户、部门、角色、用户组及它们之间的关联关系，并通过 **RLS（Row-Level Security）** 实现租户级数据隔离。

## 业务表概览

| 表名 | 说明 | 核心用途 |
|------|------|----------|
| [sys_tenant](#systenant) | 租户表 | 多租户体系的根节点，通过 parent_id 支持租户层级，所有业务数据按租户隔离 |
| [sys_dept](#sysdept) | 部门表 | 树形组织架构，通过闭包表加速层级查询 |
| [sys_dept_closure](#sysdeptclosure) | 部门闭包表 | 物化部门树的祖先-后代关系，支持 O(1) 子树/祖先查询 |
| [sys_role](#sysrole) | 角色表 | 权限载体，绑定数据范围规则与可见范围 |
| [sys_role_id_scope](#sysroleidscope) | 角色数据 ID 范围表 | 精细化控制角色能访问的指定用户/部门/用户组 |
| [sys_role_allowed_dept](#sysrolealloweddept) | 角色分发部门映射表 | 角色显式映射到多部门分发，实现角色定义与分发解耦 |
| [sys_user](#sysuser) | 用户表 | 登录主体，可归属到部门或用户组 |
| [sys_user_group](#sysusergroup) | 用户组表 | 用户的灵活分组，不依赖于部门树 |
| [sys_user_role_mapping](#sysuserrolemapping) | 用户-角色映射 | 用户与角色的多对多关联 |
| [sys_user_group_mapping](#sysusergroupmapping) | 用户组-成员映射 | 用户组成员关系 |
| [basic](#basic) | 基础字段示例表 | 展示标准字段模板，供新建业务表时参考 |
| [sys_menu](#sysmenu-1) | 菜单/权限表 | 功能权限树，定义目录/菜单/按钮三级权限点，补全 RBAC 的功能维度 |
| [sys_role_menu](#sysrolemenu) | 角色-菜单映射 | 将菜单权限绑定到角色 |
| [sys_login_log](#sysloginlog) | 登录日志 | 记录登录尝试（含失败），追加写入不可变更 |
| [sys_operation_log](#sysoperationlog) | 操作日志 | 记录用户操作行为与数据变更，配合审计员角色使用 |
| [sys_session](#syssession) | 会话表 | 管理访问令牌和刷新令牌，支持服务端撤销 |
| [sys_config](#sysconfig) | 系统全局配置 | 平台级 key-value 配置参数，不绑定租户 |
| [sys_tenant_config](#systenantconfig) | 租户配置 | 租户级自定义配置，覆盖全局默认值 |
| [sys_feature_flag](#sysfeatureflag) | 功能特性 | 租户级功能开关，控制灰度发布和按租户授权 |
| [sys_translation](#systranslation) | 通用翻译表 | 为业务表字段提供多语言翻译，支持按实体-字段-语言粒度管理 |

## 实体关系图

```
                   ┌──────────────┐
                   │  sys_tenant  │◄── parent_id（自引用树形）
                   └──────┬───────┘
                          │ tenant_id
          ┌────────────────────┼────────────────────────┐
          │                    │                        │
          ▼                    ▼                        ▼
   ┌──────────────┐    ┌──────────────┐    ┌────────────────────┐
   │   sys_dept   │    │   sys_role   │    │  sys_user_group    │
   │  (部门树)     │    │  (角色/权限)  │    │  (用户组)           │
   └──────┬───────┘    └──────┬───────┘    └─────────┬──────────┘
          │                   │                      │
          │ parent_id         │ role_id              │ group_id
          ▼                   │                      │
   ┌──────────────────┐       │                      │
   │ sys_dept_closure  │       │                      │
   │ (闭包表,加速树查询) │       │                      │
   └──────────────────┘       │                      │
                              ▼                      ▼
   ┌──────────────┐   ┌──────────────┐   ┌─────────────────────────┐
   │   sys_user   │◄──│user_role_map │   │sys_user_group_mapping   │
   │   (用户)      │   │(用户-角色映射) │   │(用户组-成员)              │
   └──────────────┘   └──────────────┘   └─────────────────────────┘
            │                   ▲
            │                   │ data_id (当 type=1 用户ID)
            └───────────────────┤
                                │
                   ┌────────────┴──────┐      dept_id（分发映射）
                   │ sys_role_id_scope │─────────────┐
                   │ (角色数据范围)      │             ▼
                   └───────────────────┘   ┌───────────────────────┐
                                           │ sys_role_allowed_dept │
                                           │ (角色分发部门映射)       │
                                           └───────────────────────┘
```

### 业务增强模块（enhance.sql）

在核心 RBAC 基础上，补充功能权限、审计日志、会话管理、系统配置四大能力：

```
  ┌─────────────────────────────────────────────────────────────────┐
  │                    功能权限层                                      │
  │  ┌──────────────┐      ┌────────────────┐                       │
  │  │   sys_menu   │◄─────│ sys_role_menu  │                       │
  │  │ (菜单/权限树)  │      │ (角色-菜单映射)  │                       │
  │  └──────────────┘      └────────┬───────┘                       │
  │                                 │ role_id                       │
  │                                 ▼                               │
  │                          ┌────────────┐                        │
  │                          │  sys_role  │ ← 复用 basic.sql 的角色  │
  │                          └────────────┘                        │
  ├─────────────────────────────────────────────────────────────────┤
  │                    审计日志层（追加写入）                           │
  │  ┌──────────────────┐    ┌──────────────────────┐               │
  │  │ sys_login_log    │    │ sys_operation_log    │               │
  │  │ (登录尝试记录)     │    │ (操作行为记录)         │               │
  │  └──────────────────┘    └──────────────────────┘               │
  ├─────────────────────────────────────────────────────────────────┤
  │                    会话管理层                                     │
  │  ┌────────────────────────────────────────────┐                  │
  │  │              sys_session                    │                  │
  │  │    (令牌哈希存储，支持服务端撤销)                │                  │
  │  └────────────────────────────────────────────┘                  │
  ├─────────────────────────────────────────────────────────────────┤
  │                    配置管理层                                     │
  │  ┌──────────────┐   ┌────────────────┐   ┌──────────────────┐   │
  │  │  sys_config  │   │sys_tenant_config│   │sys_feature_flag  │   │
  │  │ (全局配置)    │   │ (租户配置)       │   │ (功能特性开关)     │   │
  │  └──────────────┘   └────────────────┘   └──────────────────┘   │
  └─────────────────────────────────────────────────────────────────┘
```

### 国际适配层

在增强模块之上，通过 `sys_translation` 通用翻译表提供多语言支持：

```
  ┌──────────────────────────────────────────────────────────────┐
  │                    国际适配层（enhance.sql）                    │
  │  ┌──────────────────────────────────────────────────────────┐│
  │  │                   sys_translation                         ││
  │  │    通用翻译表，为 sys_menu.name / sys_dict_data.label /   ││
  │  │    sys_dept.name / sys_config.name 等字段提供多语言支持    ││
  │  └──────────────────────────────────────────────────────────┘│
  └──────────────────────────────────────────────────────────────┘
```

## 通用审计字段

除 `sys_dept_closure` 外，全部业务表均包含以下审计字段。两类例外：

- **日志表**（`sys_login_log`、`sys_operation_log`）：追加写入（append-only），省略 `updated_by`/`updated_at`/`deleted_at`。
- **映射表**（`sys_user_role_mapping`、`sys_user_group_mapping`、`sys_role_menu`）：映射行无可变业务字段，解除关联走物理删除，仅保留 `created_by`/`created_at` 最小审计字段（谁在何时授予），由应用层/ORM 写入。

标准审计字段如下：

| 字段 | 类型 | 说明 |
|------|------|------|
| `status` | int2 | 数据状态：0-禁用，1-启用（逻辑删除辅助） |
| `tenant_id` | varchar(16) | 所属租户 ID，RLS 隔离依据 |
| `created_by` | int8 | 创建人 |
| `created_at` | timestamp | 创建时间 |
| `updated_by` | int8 | 更新人（应用层/ORM 写入） |
| `updated_at` | timestamp | 更新时间（`BEFORE UPDATE` 触发器 `trg_touch_updated_at` 自动兜底刷新） |
| `deleted_at` | timestamp | 软删除时间，NULL 表示未删除 |

---

## 表结构详解

### sys_tenant

租户表是多租户体系的入口，每个租户拥有独立的用户、角色、部门等资源。通过 `parent_id` 实现租户的树形层级管理，适用于多级集团/组织场景。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | varchar(16) | 租户 ID（主键，字符串型） |
| `code` | varchar(32) | 租户编码（唯一，排除已删除记录） |
| `name` | varchar(256) | 租户名（唯一，排除已删除记录） |
| `parent_id` | varchar(16) | 父级租户 ID（NULL 为根租户） |
| `default_locale` | varchar(10) | 租户默认语言（BCP-47），如 zh-CN、en-US，新建用户时继承此值 |

> 该表自身也受 RLS 保护。子租户行挂在父租户 `tenant_id` 下（父租户上下文可见并可创建子租户）；策略的 `USING`/`WITH CHECK` 均含 `OR id = current_setting(...)`，保证租户可读写自身行。唯一性用部分唯一索引（`WHERE deleted_at IS NULL`）实现，软删后名称/编码可复用。

---

### sys_dept

部门表存储树形组织架构，`parent_id` 自引用实现父子层级。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 部门 ID |
| `name` | varchar(256) | 部门名 |
| `parent_id` | int8 | 父级部门 ID（NULL 为根部门） |
| `owner_user_id` | int8 | 部门管理员用户 |
| `owner_user_group_id` | int8 | 归属用户组 ID |

**唯一约束**：同一租户下部门名唯一（`sys_dept_tenant_name_un`，排除已删除记录）。

**触发器**：`trg_maintain_dept_closure` 在 INSERT / DELETE / UPDATE OF parent_id, deleted_at 时自动维护闭包表。写入前校验父级（存在、同租户、未删除、非自身、非自身子孙）；软删除等价删除、恢复等价重建；存在未删除子部门时拒绝删除（需自叶向根逐层删除）。

---

### sys_dept_closure

部门闭包表（Closure Table）物化了部门树中所有祖先-后代对，将递归查询降为简单 JOIN。

| 字段 | 类型 | 说明 |
|------|------|------|
| `ancestor_id` | int8 | 祖先节点 ID |
| `descendant_id` | int8 | 后代节点 ID |
| `depth` | int4 | 深度：0=自身，1=直接子节点，2=孙子节点… |

**典型查询**（软删除的部门其闭包路径已被触发器移除，业务查询仍建议显式过滤 `deleted_at`）：
- 查某部门所有子部门：`SELECT d.* FROM sys_dept d JOIN sys_dept_closure c ON c.descendant_id = d.id WHERE c.ancestor_id = ? AND c.depth > 0 AND d.deleted_at IS NULL`
- 查某部门所有祖先：`SELECT a.* FROM sys_dept a JOIN sys_dept_closure c ON c.ancestor_id = a.id WHERE c.descendant_id = ? AND c.depth > 0 AND a.deleted_at IS NULL`

闭包表由 `fn_maintain_dept_closure()` 触发器函数自动维护，支持部门的**新增**、**删除**（软删/物理删）、**移动**（修改 parent_id）、**恢复**四种操作：

- **写入校验**：父级必须存在、同租户、未软删；禁止以自身为父；禁止移入自身子树（显式报错，而非依赖主键冲突"意外"拦截）。
- **删除范围**：仅清理 `{X 的祖先 ∪ X} × {X 的子树}` 的路径，保留子树内部关系——子部门后续移动可正常重建，不会出现"整个子树闭包记录被清空且无法自愈"的数据损坏。
- **删除守卫**：存在未删除子部门时拒绝删除，需先处理子部门（自叶向根）。
- **软删一致**：软删除（`UPDATE deleted_at`）走 DELETE 分支移除路径，恢复走 INSERT 分支重建路径，两条删除路径对闭包表行为完全一致。

属于派生数据，可随时从部门树重建，因此不设审计字段（`created_by` 等），审计请看 `sys_dept` 本表。

---

### sys_role

角色是权限的载体，每个角色定义了一种数据访问规则。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 角色 ID |
| `name` | varchar(256) | 角色名 |
| `code` | varchar(64) | 权限编码 |
| `role_type` | int2 | 1-系统预置（不可删除，核心权限不可剥离），2-租户自定义 |
| `data_scope` | int2 | 数据范围规则（见下表） |
| `scope_dept_id` | int8 | 组织可见范围：NULL=全租户可分配，具体 ID=仅该部门及子部门可分配 |
| `remark` | varchar(512) | 备注 |

**data_scope 数据范围规则**：

| 值 | 含义 |
|----|------|
| 1 | 仅本人 |
| 2 | 本部门 |
| 3 | 本部门及子部门 |
| 4 | 指定人 |
| 5 | 指定部门 |
| 6 | 用户组 |
| 7 | 全租户 |

**唯一约束**：`(tenant_id, code)`、`(tenant_id, name)`（均排除已删除记录）。

---

### sys_role_id_scope

细化 `data_scope` 为 4/5/6 时，角色具体能访问哪些用户、部门或用户组。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 主键 |
| `type` | int2 | 数据 ID 类型：1-用户ID，2-部门ID，3-用户组ID |
| `role_id` | int8 | 角色 ID |
| `data_id` | int8 | 数据 ID |

**唯一约束**：`(tenant_id, role_id, type, data_id)`（排除已删除记录）。

---

### sys_role_allowed_dept

角色分发部门映射表，落地 `sys_role` 的 `allowed_dept_ids` 集合语义，实现"角色定义"与"角色分发"解耦：总部定义角色能力模板，各业务线在映射范围内进行人员分配。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 主键 |
| `role_id` | int8 | 角色 ID |
| `dept_id` | int8 | 允许分配该角色的部门 ID（映射分发范围） |

**唯一约束**：`(tenant_id, role_id, dept_id)`（排除已删除记录）。

**子树语义（明确约定）**：`dept_id` 为**严格部门集合，不自动扩展子树**——命中判定使用精确 `IN` 匹配操作人/目标用户所属部门 ID。若需覆盖子部门，须在映射中显式写入各子孙部门行（可由应用层结合 `sys_dept_closure` 展开生成）。这与 `sys_role.scope_dept_id` 的"该部门及子部门"语义不同，实现时不可混用。

**角色分发映射规则**（判定原则：显式映射优先，通用逻辑兜底）：

1. **角色列表可见性**
   - 规则 A（显式映射命中）：角色的 `allowed_dept_ids` 包含操作人所属部门 ID → 可见，直接返回，无需后续通用校验。
   - 规则 B（通用范围校验，兜底）：`scope_dept_id` 为 NULL（全租户）需操作人具备全局角色查看权限；为具体部门时需操作人部门在该部门子树内。
2. **角色分配授权**
   - 约束 1（映射来源豁免）：操作人部门 ∈ 目标角色 `allowed_dept_ids` → 豁免"操作人 data_scope ≥ 角色数据范围"的校验；但目标用户所属部门必须存在于 `allowed_dept_ids` 中，防止跨部门乱分。
   - 约束 2（通用范围校验，兜底）：未命中约束 1 时严格执行原有规范——操作人 data_scope 覆盖角色数据范围，scope_dept_id 覆盖角色分配范围。
3. **最终生效权限**：用户数据访问边界直接取其角色的 `data_scope` 最大值（或并集），不受分配者权限影响。

**场景示例**：总部创建"标准客服"角色，`allowed_dept_ids = [北京分公司, 上海分公司]`，`data_scope = 2`（本部门）。北京 HR 命中规则 A 可见该角色，分配时命中约束 1 豁免权限拦截，且仅能分给北京分公司员工；深圳 HR 未命中映射，角色不可见。

> **写入侧参考实现**：上述分配判定（约束 1/2 + 目标部门限制）的可执行版本见消费方项目 sqlc_zero_prj 的 `sqlcpg/operate.sql → fn_can_assign_role(操作者, 角色, 目标用户)`，写入前判断、同事务先检后写。

> **边界与注意事项**：`allowed_dept_ids` 需随组织架构变动手动维护（如新增子公司需手动加入）；本方案放宽了"谁能分"的限制，必须严控"角色本身能做什么"，建议全局角色下发时将 `data_scope` 设为 2（本部门）等相对范围，防止分配不当导致数据越权。

---

### 数据范围查询链路

当用户进行操作时，权限拦截器根据角色 `data_scope` 动态附加过滤条件，决定用户能看到哪些数据：

```
用户 A
  ↓
sys_user_role_mapping → 查出用户 A 的所有角色
  ↓
sys_role.data_scope → 确定数据范围模式（本人/部门/用户组/全租户...）
  ↓
sys_role_id_scope → data_scope 为 4/5/6 时，查出具体可见的
│                   用户 ID / 部门 ID / 用户组 ID
│
├── data_scope=6（用户组）
│   查询附加：WHERE owner_user_group_id IN (role_id_scope 中 type=3 的数据)
│
├── data_scope=2/3（本部门/部门及子部门）
│   查询附加：WHERE owner_dept_id IN (用户所在部门及其子部门)
│             子部门通过 sys_dept_closure 递归获取
│
├── data_scope=4（指定人）
│   查询附加：WHERE owner_user_id IN (role_id_scope 中 type=1 的数据)
│
├── data_scope=5（指定部门）
│   查询附加：WHERE owner_dept_id IN (role_id_scope 中 type=2 的数据)
│
├── data_scope=1（仅本人）
│   查询附加：WHERE owner_user_id = 当前用户
│
└── data_scope=7（全租户）
    不附加归属过滤，仅受 RLS 租户隔离约束
```

> **部门 vs 用户组**：部门基于树形组织架构（`parent_id` + 闭包表），适合正式汇报关系；用户组是扁平的灵活分组，适合跨部门项目协作。两者可同时作用于同一张表。

---

### 权限过滤函数（fun.sql）

将上述查询链路封装为三个可直接用于过滤的函数，业务方无需手写权限子查询。函数为 `SECURITY INVOKER + STABLE`，内部查询自动受 RLS 租户隔离，**调用前需 `SET app.tenant_id`**。命名与消费方项目（sqlc_zero_prj）保持同名同构。

| 函数 | 返回 | 用途 |
|------|------|------|
| `fn_accessible_user_ids(p_user_id)` | int8[] | 有权访问的用户 ID 集合，用于 `owner_user_id` 过滤 |
| `fn_accessible_dept_ids(p_user_id)` | int8[] | 有权访问的部门 ID 集合，用于 `owner_dept_id` 过滤 |
| `fn_accessible_group_ids(p_user_id)` | int8[] | 有权访问的用户组 ID 集合，用于 `owner_user_group_id` 过滤 |

**返回值三态契约（NULL=全租户）**：

- `NULL`：不受限（任一有效角色 `data_scope=7` 全租户），业务方无需附加过滤
- `'{}'`：拒绝一切（用户不存在/禁用/删除，或无任何有效角色）
- 数组：可见 ID 集合，**多角色取并集去重**

**纪律**：NULL 只允许出现在 data_scope=7 的分支——过滤谓词把 NULL 当"放行"语义，其余分支误返回 NULL 会放开整张表。

**data_scope 分支映射**：

| data_scope | fn_accessible_user_ids | fn_accessible_dept_ids | fn_accessible_group_ids |
|------------|------------------|------------------|------------------|
| 1 仅本人 | `{本人}` | `{本人归属部门}` | `{}` |
| 2 本部门 | 本部门有效用户 | `{本部门}` | `{}` |
| 3 部门及子部门 | 子树内有效用户 | 闭包子树部门 | `{}` |
| 4 指定人 | 指定的有效用户 | 指定用户归属部门 | `{}` |
| 5 指定部门 | 指定部门内有效用户 | 指定的有效部门 | `{}` |
| 6 用户组 | 有效组内有效成员 | 组内成员归属部门 | 角色指定的有效用户组 |
| 7 全租户 | `NULL`（不受限） | `NULL`（不受限） | `NULL`（不受限） |

**有效性判定**（贯穿所有分支）：本人须启用未删除；角色须启用未删除（`sys_user_role_mapping` 为物理删除表，无状态位）；`sys_role_id_scope` 须启用未删除；目标用户/部门/用户组均须启用未删除。

**使用示例**：

```sql
-- 用户维度过滤（LATERAL 只求值一次，推荐）
SELECT t.*
FROM biz t
CROSS JOIN LATERAL fn_accessible_user_ids(:uid) AS p(uids)
WHERE p.uids IS NULL OR t.owner_user_id = ANY(p.uids);

-- 部门维度过滤（简写，STABLE 保证两次求值一致）
SELECT * FROM biz
WHERE fn_accessible_dept_ids(:uid) IS NULL
   OR owner_dept_id = ANY(fn_accessible_dept_ids(:uid));

-- IN 写法等价替代
SELECT * FROM biz
WHERE owner_dept_id IN (SELECT unnest(fn_accessible_dept_ids(:uid)));
```

---

### sys_user

用户表为系统的登录主体。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 用户 ID |
| `name` | varchar(256) | 用户名（同租户下唯一） |
| `nickname` | varchar(256) | 昵称 |
| `password` | text | 密码（加密存储） |
| `remark` | varchar | 备注 |
| `locale` | varchar(10) | 用户语言偏好（BCP-47），如 zh-CN、en-US，影响界面语言和翻译回退优先级 |
| `failed_count` | int4 | 连续密码错误次数，达到 `sys_config` 的 `auth.lockout-threshold` 后锁定，登录成功清零 |
| `locked_until` | timestamp(0) | 账号锁定截止时间，NULL 表示未锁定；过期即自动解锁 |
| `owner_user_id` | int8 | 归属用户 ID（如直属上级） |
| `owner_dept_id` | int8 | 归属部门 ID |
| `owner_user_group_id` | int8 | 归属用户组 ID |

**唯一约束**：`(tenant_id, name)`（排除已删除记录）。

**登录链路与 RLS 的衔接**（先确定租户再进租户上下文）：

1. 登录请求携带租户编码（或用户名全局唯一时反查），应用层先以**非 RLS 通道**（管理连接或 `SECURITY DEFINER` 函数）校验 `sys_tenant`/`sys_user`，确定 `tenant_id`；
2. 确定租户后再 `set_config('app.tenant_id', ...)` 进入租户上下文执行后续流程；
3. 失败登录记录 `sys_login_log`：已知租户用真实 `tenant_id`；未知租户/不存在用户将**请求中的租户标识**原文写入 `tenant_id`（仅作审计留痕，不参与 RLS 业务读取）；
4. 账号锁定判定用 `failed_count`/`locked_until` 字段（O(1) 读写），不依赖扫描日志统计。

---

### sys_user_group

用户组提供独立于部门树的分组维度，适用于跨部门临时团队等场景。在权限体系中，用户组是 **data_scope = 6（用户组）** 的核心载体：

- **数据归属标记**：业务表通过 `owner_user_group_id` 标记数据归属于哪个用户组
- **成员关系**：`sys_user_group_mapping` 定义用户 → 组的多对多关系
- **范围绑定**：`sys_role_id_scope`（`type = 3`）将角色可见范围限定到具体用户组

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 用户组 ID |
| `name` | varchar(256) | 组名 |
| `code` | varchar(64) | 组编码 |
| `remark` | varchar(512) | 备注 |
| `owner_user_id` | int8 | 组长/归属用户 |

**唯一约束**：`(tenant_id, code)`、`(tenant_id, name)`（均排除已删除记录）。

---

### sys_user_role_mapping

用户与角色的多对多关联表。映射行无可变业务字段，解除关联走物理删除，因此仅保留 `created_by`/`created_at` 最小审计字段（谁在何时授予），不含 `updated_*`/`deleted_*`。

| 字段 | 类型 | 说明 |
|------|------|------|
| `user_id` | int8 | 用户 ID |
| `role_id` | int8 | 角色 ID |
| `tenant_id` | varchar(16) | 租户 ID |
| `created_by` | int8 | 授予人（创建人），由应用层/ORM 写入 |
| `created_at` | timestamp(0) | 授予时间（创建时间），默认 CURRENT_TIMESTAMP |

**主键**：`(user_id, role_id)`

---

### sys_user_group_mapping

用户与用户组的多对多成员关系表。同 `sys_user_role_mapping`，仅保留 `created_by`/`created_at` 最小审计字段。

| 字段 | 类型 | 说明 |
|------|------|------|
| `group_id` | int8 | 用户组 ID |
| `user_id` | int8 | 用户 ID |
| `tenant_id` | varchar(16) | 租户 ID |
| `created_by` | int8 | 添加人（创建人），由应用层/ORM 写入 |
| `created_at` | timestamp(0) | 添加时间（创建时间），默认 CURRENT_TIMESTAMP |

**主键**：`(group_id, user_id)`

---

### basic

基础字段示例表——不含任何业务字段，仅承载标准审计/隔离字段，作为新建业务表时的**字段模板**。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 主键 ID |
| `owner_user_id` | int8 | 归属用户 ID |
| `owner_dept_id` | int8 | 归属部门 ID |
| `owner_user_group_id` | int8 | 归属用户组 ID |

> 新建业务表时，复制 `basic` 的审计字段 + 归属字段，再加上业务特有字段即可。

---

## 业务增强表详解

以下表来自 `enhance.sql`，在核心 RBAC 之上补充功能权限、审计日志、会话管理、系统配置四大能力。

### sys_menu

菜单/权限树，定义系统功能权限的层级结构。通过 `sys_role_menu` 将权限点绑定到角色，补全 RBAC 的**功能权限**维度（与 `sys_role.data_scope` 的数据权限维度互补）。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 菜单 ID |
| `name` | varchar(64) | 菜单/权限名称 |
| `permission_code` | varchar(128) | 权限编码（租户内唯一），应用层匹配用，如 `sys:user:create` |
| `parent_id` | int8 | 父级菜单 ID（NULL 为根菜单） |
| `menu_type` | int2 | 1-目录，2-菜单，3-按钮（操作权限点） |
| `icon` | varchar(128) | 菜单图标 |
| `route_path` | varchar(256) | 前端路由路径 |
| `component` | varchar(256) | 前端组件路径 |
| `sort_order` | int4 | 排序号 |

**权限编码设计**：采用 `:` 分隔的三级命名法，如 `sys:user:create` 表示"系统模块-用户管理-新增"。应用层通过注解（如 `@RequiresPermission("sys:user:create")`）在 API 端点上匹配。

**唯一约束**：`(tenant_id, permission_code)`（排除已删除记录）。

**租户分发模型**：菜单为**租户数据**（带 `tenant_id` + RLS）。平台维护模板菜单树（`t-super-01` 下的 2xx），租户开通时按需复制所需子树到新租户（新租户使用独立 ID 段，如演示租户的 12xx）。`sys_role_menu` 只能映射本租户拥有的菜单——跨租户映射在 RLS 下 JOIN 不可见，等于无效授权。模板菜单变更走管理端/迁移通道（建表角色），应用连接用户对 `sys_menu` 只读。

---

### sys_role_menu

角色与菜单权限的多对多关联。映射行无可变业务字段，解除授权走物理删除，因此仅保留 `created_by`/`created_at` 最小审计字段（谁在何时授权），不含 `updated_*`/`deleted_*`。

| 字段 | 类型 | 说明 |
|------|------|------|
| `role_id` | int8 | 角色 ID |
| `menu_id` | int8 | 菜单/权限 ID |
| `tenant_id` | varchar(16) | 租户 ID |
| `created_by` | int8 | 授权人（创建人），由应用层/ORM 写入 |
| `created_at` | timestamp(0) | 授权时间（创建时间），默认 CURRENT_TIMESTAMP |

**主键**：`(role_id, menu_id)`

**权限判断流程**：
```
用户请求 API
  → 从 JWT/会话 获取用户角色列表
  → sys_role_menu 查出角色拥有的菜单权限编码
  → 匹配 API 端点所需的权限编码
  → 通过/拒绝
```

---

### sys_login_log

登录日志表，记录每次登录尝试（包括成功和失败）。追加写入（append-only），`bigserial` 自增主键，省略 `updated_by`/`updated_at`/`deleted_at`。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | bigserial | 日志 ID（自增） |
| `user_id` | int8 | 用户 ID |
| `username` | varchar(256) | 用户名（冗余，便于快速查看） |
| `ip_address` | varchar(64) | 登录 IP 地址 |
| `user_agent` | varchar(512) | 浏览器/客户端信息 |
| `login_type` | varchar(32) | 登录方式：password/sms/oauth/refresh_token |
| `is_success` | boolean | 是否登录成功 |
| `failure_reason` | varchar(256) | 失败原因：密码错误、账号禁用、租户过期等 |
| `login_at` | timestamp | 登录时间 |

**使用场景**：安全审计、暴力破解检测、用户登录历史查询。

---

### sys_operation_log

操作日志表，记录用户对系统数据的操作行为。追加写入，`bigserial` 自增主键。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | bigserial | 日志 ID（自增） |
| `user_id` | int8 | 操作用户 ID |
| `username` | varchar(256) | 用户名（冗余） |
| `operation_type` | varchar(64) | 操作类型：CREATE/UPDATE/DELETE/EXPORT/IMPORT 等 |
| `target_table` | varchar(64) | 操作目标表名 |
| `target_id` | varchar(64) | 操作目标记录 ID |
| `old_value` | jsonb | 操作前数据（jsonb，写入即校验 JSON 合法性，可索引） |
| `new_value` | jsonb | 操作后数据（jsonb，可索引） |
| `ip_address` | varchar(64) | 请求 IP |
| `api_path` | varchar(512) | API 路径 |
| `http_method` | varchar(16) | GET/POST/PUT/DELETE |
| `duration_ms` | int4 | 请求耗时（毫秒） |
| `result_code` | varchar(32) | 结果码：200/400/500 等 |
| `request_id` | varchar(64) | 请求追踪 ID，用于关联同一请求的多个操作 |
| `operated_at` | timestamp | 操作时间 |

**适用场景**：
- **合规审计**：种子数据中的"审计员"角色可以此表为数据源
- **安全溯源**：追溯某用户在特定时间段内的所有操作
- **数据恢复**：通过 `old_value`/`new_value` 了解数据变更内容

---

### sys_session

用户会话/令牌表，管理访问令牌和刷新令牌。令牌字段仅存 **SHA-256 哈希**，不存明文令牌。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 会话 ID |
| `user_id` | int8 | 用户 ID |
| `token_hash` | varchar(128) | 访问令牌哈希（UNIQUE） |
| `refresh_token_hash` | varchar(128) | 刷新令牌哈希 |
| `expires_at` | timestamp | 访问令牌过期时间 |
| `refresh_expires_at` | timestamp | 刷新令牌过期时间 |
| `last_activity_at` | timestamp | 最后活跃时间，用于僵尸会话检测 |
| `device_info` | varchar(512) | 设备信息 |
| `ip_address` | varchar(64) | 登录 IP |
| `is_revoked` | boolean | 是否已主动撤销 |

**唯一约束**：`token_hash` UNIQUE。

**关键能力**：
- **服务端撤销**：设置 `is_revoked = true`，即使 JWT 未过期也不再可用
- **退出所有设备**：撤销用户的所有会话
- **令牌轮换**：刷新令牌时，旧 refresh_token 标记为已使用

---

### sys_config

系统全局配置表，存储平台级 key-value 配置参数。**不绑定租户、无 RLS**，由平台超级管理员维护。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 配置 ID |
| `name` | varchar(128) | 配置名称 |
| `config_key` | varchar(128) | 配置键（UNIQUE） |
| `value` | text | 配置值 |
| `value_type` | varchar(32) | 值类型：string/integer/boolean/float/json |
| `remark` | varchar(512) | 备注 |

**典型配置项**：
- `session.timeout` — 会话超时时间（秒）
- `auth.lockout-threshold` — 密码错误锁定阈值
- `smtp.host` — 邮件服务器地址
- `system.name` — 系统显示名称

---

### sys_tenant_config

租户配置表，存储各租户的个性化配置，可覆盖全局默认值。有 RLS 租户隔离。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 配置 ID |
| `name` | varchar(128) | 配置名称 |
| `config_key` | varchar(128) | 配置键（租户内唯一） |
| `value` | text | 配置值 |
| `value_type` | varchar(32) | 值类型：string/integer/boolean/float/json |
| `remark` | varchar(512) | 备注 |

**唯一约束**：`(tenant_id, config_key)`（排除已删除记录）。

**与 sys_config 的关系**：应用层先查 `sys_tenant_config` 获取租户级值，未命中则回退到 `sys_config` 的全局默认值。

---

### sys_feature_flag

功能特性表，控制各租户的功能开关，支持灰度发布和按租户授权。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 特性 ID |
| `name` | varchar(128) | 特性名称 |
| `flag_key` | varchar(128) | 特性键（租户内唯一） |
| `description` | varchar(512) | 特性描述 |
| `is_enabled` | boolean | 是否启用 |

**唯一约束**：`(tenant_id, flag_key)`（排除已删除记录）。

**典型特性**：
- `export_enabled` — 数据导出功能
- `api_access` — API 密钥访问
- `sso_enabled` — SSO 单点登录
- `audit_log` — 操作日志记录

---

### sys_translation

通用翻译表，为业务表字段提供多语言支持，覆盖菜单名称、字典标签、部门/角色名称等可翻译内容。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 翻译 ID |
| `table_name` | varchar(64) | 来源表名，如 `sys_menu`、`sys_dict_data` |
| `row_id` | int8 | 来源行主键 ID |
| `column_name` | varchar(64) | 来源列名，如 `name`、`label` |
| `locale` | varchar(10) | 语言代码（BCP-47），如 `zh-CN`、`en-US`、`ja-JP` |
| `value` | text | 翻译文本，对应语言的展示值 |
| `remark` | varchar(512) | 备注 |

**唯一约束**：`(table_name, row_id, column_name, locale, tenant_id)`（排除已删除记录），确保同来源字段同语言只有一条有效翻译。

**设计要点**：
- **泛化设计**：一张 `sys_translation` 表覆盖所有实体字段的翻译，不需要为每张表建独立翻译表。
- **回退链**：应用层查询优先级为 `用户语言 → 租户默认语言 → 原始字段值`，允许部分翻译逐步上线。
- **租户隔离**：带 `tenant_id`，与所有业务表一致的 RLS 策略，翻译数据随业务数据隔离。
- **status 字段**：`status = 0` 可禁用某条翻译，使其回退到下一优先级，无需物理删除。

**典型查询 — 获取用户语言的菜单树（三层回退：用户语言 → 租户默认语言 → 原始值）**：
```sql
SELECT
    m.id,
    m.parent_id,
    m.menu_type,
    m.permission_code,
    COALESCE(t_user.value, t_tenant.value, m.name) AS display_name,  -- 用户语言 → 租户默认 → 原始值
    m.route_path,
    m.icon,
    m.sort_order
FROM sys_menu m
-- 第一层：用户语言偏好
LEFT JOIN sys_translation t_user
    ON  t_user.table_name  = 'sys_menu'
    AND t_user.row_id      = m.id
    AND t_user.column_name = 'name'
    AND t_user.locale      = current_setting('app.locale', true)
    AND t_user.deleted_at IS NULL
    AND t_user.status = 1
-- 第二层：租户默认语言（未命中用户语言时回退）
LEFT JOIN sys_translation t_tenant
    ON  t_tenant.table_name  = 'sys_menu'
    AND t_tenant.row_id      = m.id
    AND t_tenant.column_name = 'name'
    AND t_tenant.locale      = (SELECT default_locale FROM sys_tenant
                                WHERE id = current_setting('app.tenant_id', true))
    AND t_tenant.deleted_at IS NULL
    AND t_tenant.status = 1
WHERE m.deleted_at IS NULL
  AND m.tenant_id = current_setting('app.tenant_id', true)
ORDER BY m.sort_order;
```

**应用层配合**：
1. **设置语言**：每事务开头 `SELECT set_config('app.locale', 'en-US', true)`（与 `app.tenant_id` 同为事务级）。
2. **查询回退**：`COALESCE(用户语言翻译, 租户默认语言翻译, 原始字段)`，见上方三层回退示例。
3. **写入翻译**：对 `sys_translation` 表做标准的 CRUD。

> `sys_translation.row_id` 为 int8，覆盖 int8 主键的表；`sys_tenant` 等 varchar 主键表不在翻译范围内（已知限制，见文末"已知限制与演进方向"）。

---

## 多租户隔离（RLS）

全部表均启用了 **Row-Level Security**，并配置了租户隔离策略：

```sql
CREATE POLICY <table>_tenant_isolation ON public.<table>
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));
```

- **USING**：查询/更新/删除时，仅返回当前租户的数据
- **WITH CHECK**：插入/更新时，强制写入当前租户 ID

**租户上下文必须绑定到事务，而非会话**。连接池复用连接时，会话级 `SET` 的残留值是跨租户泄露的头号来源（事务 B 忘记重新 SET 即继承事务 A 的租户）。应用层约定：

```sql
-- 每个事务的第一条语句（第三个参数 true = 事务级，COMMIT/ROLLBACK 自动失效）
SELECT set_config('app.tenant_id', $tenantId, true);
-- 或等价的 SQL 级 SET LOCAL（同样仅事务内有效）
SET LOCAL app.tenant_id = 't-demo-01';
```

- 未设置时 `current_setting('app.tenant_id', true)` 返回 NULL，所有策略评估为假 → **默认拒绝**（fail-safe）；
- 禁止使用会话级 `SET app.tenant_id`；
- `GRANT SET ON PARAMETER` 为 PG15+ 语法，本方案面向 PostgreSQL 18；
- 数据库用户 `test_u` 已被授予对该参数的 SET 权限。

---

## 数据库用户

| 用户 | 用途 | 权限 |
|------|------|------|
| `test_u` | 测试连接用户（仅用于测试，密码写在脚本中仅供本地环境） | public schema 业务表 SELECT/INSERT/UPDATE/DELETE（例外：`sys_menu`、`sys_config` 只读），全部序列的 USAGE/SELECT，`app.tenant_id` 参数的 SET 权限 |

**最小权限例外**（防运行时提权）：

- `sys_menu`：权限体系定义本身。若应用可写，低权限会话可把高权限编码挂到任意层级 → 只读；变更走管理端/迁移通道；
- `sys_config`：无 RLS 的平台级全局配置（含 `session.timeout`、`auth.lockout-threshold` 等安全参数），任何租户的连接都能改 → 只读，仅平台管理端可写；
- `sys_role`/`sys_role_menu` 保持可写（角色管理是运行时功能），如需进一步隔离建议管理端使用独立数据库角色；
- public schema 已 `REVOKE CREATE ... FROM PUBLIC`，`ALTER DEFAULT PRIVILEGES` 显式 `FOR ROLE CURRENT_USER`——其他角色所建新表不会自动授权给 `test_u`。

---

## 索引策略

| 表 | 索引 | 类型 | 用途 |
|----|------|------|------|
| sys_tenant | `sys_tenant_name_un` | 部分唯一索引 | 租户名唯一，排除已删除（软删后可复用） |
| sys_tenant | `sys_tenant_code_un` | 部分唯一索引 | 租户编码唯一，排除已删除 |
| sys_dept | `sys_dept_tenant_name_un` | 部分唯一索引 | 同租户下部门名唯一，排除已删除 |
| sys_role | `sys_role_tenant_code_un` | 部分唯一索引 | 同租户下角色编码唯一 |
| sys_role | `sys_role_tenant_name_un` | 部分唯一索引 | 同租户下角色名唯一 |
| sys_role_id_scope | `sys_role_id_scope_tenant_role_type_data_un` | 部分唯一索引 | 防重复分配 |
| sys_role_allowed_dept | `sys_role_allowed_dept_tenant_role_dept_un` | 部分唯一索引 | 防重复映射 |
| sys_user | `sys_user_tenant_name_un` | 部分唯一索引 | 同租户下用户名唯一 |
| sys_user_group | `sys_user_group_tenant_code_un` | 部分唯一索引 | 同租户下组编码唯一 |
| sys_user_group | `sys_user_group_tenant_name_un` | 部分唯一索引 | 同租户下组名唯一 |
| sys_dept_closure | `idx_closure_ancestor` | B-tree | 加速祖先→后代查询 |
| sys_dept_closure | `idx_closure_descendant` | B-tree | 加速后代→祖先查询 |
| basic | `idx_basic_owner_user` | B-tree | data_scope=4 按 `owner_user_id` 过滤 |
| basic | `idx_basic_owner_dept` | B-tree | data_scope=2/3/5 按 `owner_dept_id` 过滤 |
| basic | `idx_basic_owner_user_group` | B-tree | data_scope=6 按 `owner_user_group_id` 过滤 |
| sys_user_role_mapping | `idx_surm_tenant` | B-tree | 加速按租户查询 |
| sys_user_role_mapping | `idx_surm_role_id` | B-tree | 禁用/删除角色时反查受影响用户 |
| sys_user_group_mapping | `idx_sugm_tenant` | B-tree | 加速按租户查询 |
| sys_user_group_mapping | `idx_sugm_user_id` | B-tree | 用户→所属组高频路径（data_scope=6） |
| sys_dict_data | `sys_dict_data_type_value_un` | 部分唯一索引 | 同租户下同字典类型值唯一 |
| sys_menu | `sys_menu_tenant_code_un` | 部分唯一索引 | 同租户下权限编码唯一 |
| sys_role_menu | `idx_srm_tenant` | B-tree | 加速按租户查询 |
| sys_role_menu | `idx_srm_menu_id` | B-tree | 加速按菜单 ID 反向查询 |
| sys_login_log | `idx_login_log_tenant_user` | B-tree | 加速按租户+用户查询登录历史 |
| sys_login_log | `idx_login_log_tenant_time` | B-tree | 加速按租户+时间排序 |
| sys_operation_log | `idx_operation_log_tenant_user` | B-tree | 加速按租户+用户查询操作记录 |
| sys_operation_log | `idx_operation_log_tenant_time` | B-tree | 加速按租户+时间排序 |
| sys_operation_log | `idx_operation_log_type` | B-tree | 加速按租户+操作类型过滤 |
| sys_session | `sys_session_token_hash_un` | 唯一索引 | 通过令牌哈希快速查找会话 |
| sys_session | `sys_session_refresh_token_hash_un` | 部分唯一索引 | 刷新令牌哈希唯一 |
| sys_session | `idx_session_tenant_user` | B-tree | 加速按租户+用户查询会话 |
| sys_config | `sys_config_key_un` | 部分唯一索引 | 配置键全局唯一 |
| sys_tenant_config | `sys_tenant_config_key_un` | 部分唯一索引 | 同租户下配置键唯一 |
| sys_feature_flag | `sys_feature_flag_tenant_key_un` | 部分唯一索引 | 同租户下特性键唯一 |
| sys_translation | `sys_translation_tenant_un` | 部分唯一索引 | 同来源字段+语言+租户翻译唯一 |
| sys_translation | `idx_translation_lookup` | 部分索引 | 加速翻译查找，仅含活跃翻译 |

> 多数唯一索引使用 `WHERE deleted_at IS NULL` 部分索引，允许已删除记录重复，同时保证活跃数据唯一。

---

## 软删除

所有业务表采用 `deleted_at` 字段实现软删除——删除操作仅设置时间戳，不物理删除行。查询时需添加 `WHERE deleted_at IS NULL` 条件（RLS 不自动处理软删除）。

---

## 设计约定

1. **字段顺序**：业务字段在前 → 审计字段（`created_by/at`、`updated_by/at`、`deleted_at`）在后 → `tenant_id` 收尾
2. **主键**：使用 `int8`（bigint）自增或雪花 ID，由应用层生成。日志表（`sys_login_log`、`sys_operation_log`）使用 `bigserial` 自增主键
3. **时间戳**：统一使用 `timestamp(0)`（秒级精度）
4. **默认值**：`status` 默认 1（启用），`created_at`/`updated_at` 默认当前时间
5. **追加写入**：日志表（`sys_login_log`、`sys_operation_log`）为 append-only 设计，省略 `updated_by`/`updated_at`/`deleted_at`，由应用层保证只追加不修改
6. **全局配置**：`sys_config` 为平台级配置，不绑定租户，无 RLS 策略，应用连接只读
7. **国际适配**：`sys_user.locale` 为个人语言偏好，`sys_tenant.default_locale` 为租户默认语言，`sys_translation` 统一管理所有可翻译字段的多语言值
8. **枚举校验**：`status`（0/1）、`role_type`（1/2）、`data_scope`（1-7）、`type`（1-3）、`menu_type`（1-3）等枚举字段均有 CHECK 约束，非法值在写入时即报错
9. **updated_at 兜底**：所有含 `updated_at` 的表挂载 `trg_touch_updated_at` 触发器，UPDATE 未显式赋值时自动刷新；`updated_by` 承载业务身份由应用层写入
10. **权限编码命名**：`:` 分隔层级，多词段用连字符（`sys:user:reset-pwd`、`sys:audit:operation-log`）
11. **种子幂等**：`data.sql`/`data_enhance.sql` 所有 INSERT 带 `ON CONFLICT DO NOTHING`，可重复执行

---

## 已知限制与演进方向

以下为审计确认但本轮暂缓的项，落地前需评估迁移成本：

1. **timestamp 无时区**：全库 `timestamp(0)`。多时区租户场景建议迁移 `timestamptz`，属于破坏性变更，需与应用层一并评估；
2. **日志表无分区**：`sys_login_log`/`sys_operation_log` 无限增长，生产环境建议按月分区 + 归档策略（建表时确定分区键，后改成本高）；
3. **无乐观锁**：全库无 `version` 字段，并发覆盖风险由应用层承担；若引入需同步 ORM 与全部更新语句；
4. **sys_translation.row_id 为 int8**：无法覆盖 `sys_tenant`（varchar 主键）等字符串主键表，如需覆盖需改 `varchar` 并迁移存量；
5. **sys_role_allowed_dept 业务规则**：分配豁免、可见性等规则全部承载在注释/文档层，DB 无约束保障，应用层需配套集成测试覆盖判定规则。
