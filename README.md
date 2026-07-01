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
| [sys_menu](#sysmenu-1) | 菜单/权限表 | 功能权限树，定义目录/菜单/按钮三级权限点，补全 RBAC 的功能维度 |
| [sys_role_menu](#sysrolemenu) | 角色-菜单映射 | 将菜单权限绑定到角色 |
| [sys_login_log](#sysloginlog) | 登录日志 | 记录登录尝试（含失败），追加写入不可变更 |
| [sys_operation_log](#sysoperationlog) | 操作日志 | 记录用户操作行为与数据变更，配合审计员角色使用 |
| [sys_session](#syssession) | 会话表 | 管理访问令牌和刷新令牌，支持服务端撤销 |
| [sys_config](#sysconfig) | 系统全局配置 | 平台级 key-value 配置参数，不绑定租户 |
| [sys_tenant_config](#systenantconfig) | 租户配置 | 租户级自定义配置，覆盖全局默认值 |
| [sys_feature_flag](#sysfeatureflag) | 功能特性 | 租户级功能开关，控制灰度发布和按租户授权 |

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

## 通用审计字段

除 `sys_dept_closure`、映射表外，全部业务表均包含以下审计字段。日志表（`sys_login_log`、`sys_operation_log`）为追加写入（append-only），省略 `updated_by`/`updated_at`/`deleted_at`：

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

### 数据范围查询链路

当用户进行操作时，权限拦截器根据角色 `data_scope` 动态附加过滤条件，决定用户能看到哪些数据：

```
用户 A
  ↓
user_role_mapping → 查出用户 A 的所有角色
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

---

### sys_role_menu

角色与菜单权限的多对多关联（纯映射，仅有业务键）。

| 字段 | 类型 | 说明 |
|------|------|------|
| `role_id` | int8 | 角色 ID |
| `menu_id` | int8 | 菜单/权限 ID |
| `tenant_id` | varchar(16) | 租户 ID |

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
| `old_value` | text | 操作前数据（JSON） |
| `new_value` | text | 操作后数据（JSON） |
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
6. **全局配置**：`sys_config` 为平台级配置，不绑定租户，无 RLS 策略
