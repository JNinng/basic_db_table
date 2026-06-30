# basic-db-table

多租户 RBAC 基础数据库表结构，基于 PostgreSQL，涵盖租户、用户、部门、角色、用户组及它们之间的关联关系，并通过 **RLS（Row-Level Security）** 实现租户级数据隔离。

## 业务表概览

| 表名 | 说明 | 核心用途 |
|------|------|----------|
| [sys_tenant](#systenant) | 租户表 | 多租户体系的根节点，通过 parent_id 支持租户层级，所有业务数据按租户隔离 |
| [sys_dept](#sysdept) | 部门表 | 树形组织架构，通过闭包表加速层级查询 |
| [sys_dept_closure](#sysdeptclosure) | 部门闭包表 | 物化部门树的祖先-后代关系，支持 O(1) 子树/祖先查询 |
| [sys_role](#sysrole) | 角色表 | 权限载体，绑定数据范围规则与可见范围 |
| [sys_role_id_scope](#sysroleidscope) | 角色数据 ID 范围表 | 精细化控制角色能访问的指定用户/部门/用户组 |
| [sys_user](#sysuser) | 用户表 | 登录主体，可归属到部门或用户组 |
| [sys_user_group](#sysusergroup) | 用户组表 | 用户的灵活分组，不依赖于部门树 |
| [user_role_mapping](#userrolemapping) | 用户-角色映射 | 用户与角色的多对多关联 |
| [sys_user_group_mapping](#sysusergroupmapping) | 用户组-成员映射 | 用户组成员关系 |
| [basic](#basic) | 基础字段示例表 | 展示标准字段模板，供新建业务表时参考 |

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
                   ┌────────────┴──────┐
                   │ sys_role_id_scope │
                   │ (角色数据范围)      │
                   └───────────────────┘
```

## 通用审计字段

除 `sys_dept_closure`、映射表外，全部业务表均包含以下审计字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `status` | int2 | 数据状态：0-禁用，1-启用（逻辑删除辅助） |
| `tenant_id` | varchar(16) | 所属租户 ID，RLS 隔离依据 |
| `created_by` | int8 | 创建人 |
| `created_at` | timestamp | 创建时间 |
| `updated_by` | int8 | 更新人 |
| `updated_at` | timestamp | 更新时间 |
| `deleted_at` | timestamp | 软删除时间，NULL 表示未删除 |

---

## 表结构详解

### sys_tenant

租户表是多租户体系的入口，每个租户拥有独立的用户、角色、部门等资源。通过 `parent_id` 实现租户的树形层级管理，适用于多级集团/组织场景。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | varchar(16) | 租户 ID（主键，字符串型） |
| `code` | varchar(32) | 租户编码（UNIQUE） |
| `name` | varchar(256) | 租户名（UNIQUE） |
| `parent_id` | varchar(16) | 父级租户 ID（NULL 为根租户） |

> 该表自身也受 RLS 保护，遵循"租户隔离"原则。不过根租户的 `tenant_id` 等于自身 `id`，RLS 需要特殊处理（如通过 superuser 或 bypass 策略访问全部租户）。

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

**触发器**：`trg_maintain_dept_closure` 在 INSERT / DELETE / UPDATE OF parent_id 时自动维护闭包表。

---

### sys_dept_closure

部门闭包表（Closure Table）物化了部门树中所有祖先-后代对，将递归查询降为简单 JOIN。

| 字段 | 类型 | 说明 |
|------|------|------|
| `ancestor_id` | int8 | 祖先节点 ID |
| `descendant_id` | int8 | 后代节点 ID |
| `depth` | int4 | 深度：0=自身，1=直接子节点，2=孙子节点… |

**典型查询**：
- 查某部门所有子部门：`SELECT descendant_id FROM sys_dept_closure WHERE ancestor_id = ? AND depth > 0`
- 查某部门所有祖先：`SELECT ancestor_id FROM sys_dept_closure WHERE descendant_id = ?`

闭包表由 `fn_maintain_dept_closure()` 触发器函数自动维护，支持部门的**新增**、**删除**、**移动**（修改 parent_id）三种操作，同时防止环的产生。

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

### sys_user

用户表为系统的登录主体。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 用户 ID |
| `name` | varchar(256) | 用户名（同租户下唯一） |
| `nickname` | varchar(256) | 昵称 |
| `password` | text | 密码（加密存储） |
| `remark` | varchar | 备注 |
| `owner_user_id` | int8 | 归属用户 ID（如直属上级） |
| `owner_dept_id` | int8 | 归属部门 ID |
| `owner_user_group_id` | int8 | 归属用户组 ID |

**唯一约束**：`(tenant_id, name)`（排除已删除记录）。

---

### sys_user_group

用户组提供独立于部门树的分组维度，适用于跨部门临时团队等场景。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | int8 | 用户组 ID |
| `name` | varchar(256) | 组名 |
| `code` | varchar(64) | 组编码 |
| `remark` | varchar(512) | 备注 |
| `owner_user_id` | int8 | 组长/归属用户 |

**唯一约束**：`(tenant_id, code)`、`(tenant_id, name)`（均排除已删除记录）。

---

### user_role_mapping

用户与角色的多对多关联表（纯映射，仅有业务键）。

| 字段 | 类型 | 说明 |
|------|------|------|
| `user_id` | int8 | 用户 ID |
| `role_id` | int8 | 角色 ID |
| `tenant_id` | varchar(16) | 租户 ID |

**主键**：`(user_id, role_id)`

---

### sys_user_group_mapping

用户与用户组的多对多成员关系表。

| 字段 | 类型 | 说明 |
|------|------|------|
| `group_id` | int8 | 用户组 ID |
| `user_id` | int8 | 用户 ID |
| `tenant_id` | varchar(16) | 租户 ID |

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

## 多租户隔离（RLS）

全部表均启用了 **Row-Level Security**，并配置了租户隔离策略：

```sql
CREATE POLICY <table>_tenant_isolation ON public.<table>
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));
```

- **USING**：查询/更新/删除时，仅返回当前租户的数据
- **WITH CHECK**：插入/更新时，强制写入当前租户 ID

应用层需要在会话中设置 `app.tenant_id` 参数，数据库用户 `app_u` 已被授予对该参数的 SET 权限。

---

## 数据库用户

| 用户 | 用途 | 权限 |
|------|------|------|
| `app_u` | 应用连接用户 | public schema 全部表的 SELECT/INSERT/UPDATE/DELETE，全部序列的 USAGE/SELECT，`app.tenant_id` 参数的 SET 权限 |

---

## 索引策略

| 表 | 索引 | 类型 | 用途 |
|----|------|------|------|
| sys_dept | `sys_dept_tenant_name_un` | 部分唯一索引 | 同租户下部门名唯一，排除已删除 |
| sys_role | `sys_role_tenant_code_un` | 部分唯一索引 | 同租户下角色编码唯一 |
| sys_role | `sys_role_tenant_name_un` | 部分唯一索引 | 同租户下角色名唯一 |
| sys_role_id_scope | `sys_role_id_scope_tenant_role_type_data_un` | 部分唯一索引 | 防重复分配 |
| sys_user | `sys_user_tenant_name_un` | 部分唯一索引 | 同租户下用户名唯一 |
| sys_user_group | `sys_user_group_tenant_code_un` | 部分唯一索引 | 同租户下组编码唯一 |
| sys_user_group | `sys_user_group_tenant_name_un` | 部分唯一索引 | 同租户下组名唯一 |
| sys_dept_closure | `idx_closure_ancestor` | B-tree | 加速祖先→后代查询 |
| sys_dept_closure | `idx_closure_descendant` | B-tree | 加速后代→祖先查询 |
| user_role_mapping | `idx_urm_tenant` | B-tree | 加速按租户查询 |
| sys_user_group_mapping | `idx_sugm_tenant` | B-tree | 加速按租户查询 |

> 多数唯一索引使用 `WHERE deleted_at IS NULL` 部分索引，允许已删除记录重复，同时保证活跃数据唯一。

---

## 软删除

所有业务表采用 `deleted_at` 字段实现软删除——删除操作仅设置时间戳，不物理删除行。查询时需添加 `WHERE deleted_at IS NULL` 条件（RLS 不自动处理软删除）。

---

## 设计约定

1. **字段顺序**：业务字段在前 → 审计字段（`created_by/at`、`updated_by/at`、`deleted_at`）在后 → `tenant_id` 收尾
2. **主键**：使用 `int8`（bigint）自增或雪花 ID，由应用层生成
3. **时间戳**：统一使用 `timestamp(0)`（秒级精度）
4. **默认值**：`status` 默认 1（启用），`created_at`/`updated_at` 默认当前时间
