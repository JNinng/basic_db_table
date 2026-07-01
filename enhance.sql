-- ============================================================================
-- enhance.sql — 业务增强方案
-- 基于 basic.sql 之上，补充功能权限、审计日志、会话管理、系统配置等能力
-- 适用 PostgreSQL 15+
--
-- 新增表汇总：
--   1. sys_menu               菜单/权限树
--   2. sys_role_menu          角色-菜单映射
--   3. sys_login_log          登录日志
--   4. sys_operation_log      操作日志
--   5. sys_session            用户会话/令牌
--   6. sys_config             系统全局配置
--   7. sys_tenant_config      租户配置
--   8. sys_feature_flag       功能特性
--
-- 设计约定（与 basic.sql 保持一致）：
--   - 字段排序：id → status → 业务字段 → 审计字段 → tenant_id
--   - 主键类型：int8（除 sys_config 外，日志表用 bigserial）
--   - 时间精度：timestamp(0)，默认 CURRENT_TIMESTAMP
--   - 软删除：deleted_at 非 NULL 即已删除，唯一索引均加 WHERE 条件
--   - 无外键约束：沿用 basic.sql 设计决策
--   - RLS：每张业务表均有租户隔离策略，FORCE ROW LEVEL SECURITY
--   - 授权：扩展 app_u 权限覆盖新增表
-- ============================================================================

-- ============================================================================
-- 1. 功能权限（补全 RBAC 的功能权限维度）
--    现有 sys_role 仅定义数据范围 data_scope，缺乏操作权限控制。
--    sys_menu 定义菜单/按钮/API 权限点，通过 sys_role_menu 绑定到角色。
-- ============================================================================

-- 1a. sys_menu — 菜单/权限树
-- menu_type: 1-目录 2-菜单 3-按钮（操作权限点）
CREATE TABLE public.sys_menu
(
    id              int8                                                   NOT NULL,
    status          int2         DEFAULT 1                                 NOT NULL,
    "name"          varchar(64)                                            NOT NULL,
    permission_code varchar(128)                                           NOT NULL,
    parent_id       int8                                                   NULL,
    menu_type       int2         DEFAULT 1                                 NOT NULL,
    icon            varchar(128)                                           NULL,
    route_path      varchar(256)                                           NULL,
    component       varchar(256)                                           NULL,
    permission_expr varchar(256)                                           NULL,
    sort_order      int4         DEFAULT 0                                 NOT NULL,
    remark          varchar(512)                                           NULL,
    created_by      int8                                                   NOT NULL,
    created_at      timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    updated_by      int8                                                   NOT NULL,
    updated_at      timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    deleted_at      timestamp(0) DEFAULT NULL::timestamp without time zone NULL,
    tenant_id       varchar(16)                                            NOT NULL,
    CONSTRAINT sys_menu_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX sys_menu_tenant_code_un ON public.sys_menu USING btree (tenant_id, permission_code) WHERE deleted_at IS NULL;
COMMENT ON TABLE public.sys_menu IS '菜单/权限表，定义系统功能菜单和操作权限的树形结构，通过 sys_role_menu 与角色关联';

COMMENT ON COLUMN public.sys_menu.id IS '菜单 ID';
COMMENT ON COLUMN public.sys_menu.status IS '数据状态，0：禁用、1：启用';
COMMENT ON COLUMN public.sys_menu."name" IS '菜单/权限名称';
COMMENT ON COLUMN public.sys_menu.permission_code IS '权限编码（租户内唯一），应用层通过此编码匹配权限，命名如 sys:user:create、sys:user:delete';
COMMENT ON COLUMN public.sys_menu.parent_id IS '父级菜单 ID，NULL 为根菜单/顶级权限分组';
COMMENT ON COLUMN public.sys_menu.menu_type IS '菜单类型：1-目录 2-菜单 3-按钮（操作权限点）';
COMMENT ON COLUMN public.sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN public.sys_menu.route_path IS '前端路由路径';
COMMENT ON COLUMN public.sys_menu.component IS '前端组件路径';
COMMENT ON COLUMN public.sys_menu.permission_expr IS '权限表达式，应用层 SPEL 匹配用';
COMMENT ON COLUMN public.sys_menu.sort_order IS '排序号';
COMMENT ON COLUMN public.sys_menu.remark IS '备注';
COMMENT ON COLUMN public.sys_menu.created_by IS '创建人';
COMMENT ON COLUMN public.sys_menu.created_at IS '创建时间';
COMMENT ON COLUMN public.sys_menu.updated_by IS '更新人';
COMMENT ON COLUMN public.sys_menu.updated_at IS '更新时间';
COMMENT ON COLUMN public.sys_menu.deleted_at IS '删除时间';
COMMENT ON COLUMN public.sys_menu.tenant_id IS '租户 ID';

-- 1b. sys_role_menu — 角色-菜单映射
CREATE TABLE public.sys_role_menu
(
    role_id   int8        NOT NULL,
    menu_id   int8        NOT NULL,
    tenant_id varchar(16) NOT NULL,
    CONSTRAINT sys_role_menu_pkey PRIMARY KEY (role_id, menu_id)
);
CREATE INDEX idx_srm_tenant ON public.sys_role_menu USING btree (tenant_id);
CREATE INDEX idx_srm_menu_id ON public.sys_role_menu USING btree (menu_id);
COMMENT ON TABLE public.sys_role_menu IS '角色-菜单/权限映射表，多对多关联角色与菜单权限点';

COMMENT ON COLUMN public.sys_role_menu.role_id IS '角色 ID，关联 sys_role.id';
COMMENT ON COLUMN public.sys_role_menu.menu_id IS '菜单/权限 ID，关联 sys_menu.id';
COMMENT ON COLUMN public.sys_role_menu.tenant_id IS '租户 ID';


-- ============================================================================
-- 2. 审计日志
--    种子数据的"审计员"角色需要真实数据支撑，新增登录日志和操作日志表。
--    日志表为追加写入（append-only），永不更新，因此省略 updated_by/updated_at/deleted_at。
--    日志量较大，使用 bigserial 自增主键。
-- ============================================================================

-- 2a. sys_login_log — 登录日志
CREATE TABLE public.sys_login_log
(
    id             bigserial                              NOT NULL,
    user_id        int8                                   NOT NULL,
    username       varchar(256)                           NOT NULL,
    tenant_id      varchar(16)                            NOT NULL,
    ip_address     varchar(64)                            NULL,
    user_agent     varchar(512)                           NULL,
    login_type     varchar(32)  DEFAULT 'password'        NOT NULL,
    is_success     boolean      DEFAULT true              NOT NULL,
    failure_reason varchar(256)                           NULL,
    login_at       timestamp(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by     int8                                   NOT NULL,
    created_at     timestamp(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT sys_login_log_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_login_log_tenant_user ON public.sys_login_log USING btree (tenant_id, user_id);
CREATE INDEX idx_login_log_tenant_time ON public.sys_login_log USING btree (tenant_id, login_at DESC);
COMMENT ON TABLE public.sys_login_log IS '登录日志表，记录用户登录尝试（含失败记录），追加写入不可变更';

COMMENT ON COLUMN public.sys_login_log.id IS '日志 ID，自增序列';
COMMENT ON COLUMN public.sys_login_log.user_id IS '用户 ID';
COMMENT ON COLUMN public.sys_login_log.username IS '用户名（冗余，便于快速查看）';
COMMENT ON COLUMN public.sys_login_log.tenant_id IS '租户 ID';
COMMENT ON COLUMN public.sys_login_log.ip_address IS '登录 IP 地址';
COMMENT ON COLUMN public.sys_login_log.user_agent IS '浏览器/客户端 User-Agent';
COMMENT ON COLUMN public.sys_login_log.login_type IS '登录方式：password-密码登录 sms-短信验证码 oauth-第三方授权 refresh_token-刷新令牌';
COMMENT ON COLUMN public.sys_login_log.is_success IS '是否登录成功';
COMMENT ON COLUMN public.sys_login_log.failure_reason IS '失败原因：如密码错误、账号已禁用、租户已过期、验证码错误';
COMMENT ON COLUMN public.sys_login_log.login_at IS '登录时间';
COMMENT ON COLUMN public.sys_login_log.created_by IS '创建人/操作用户';
COMMENT ON COLUMN public.sys_login_log.created_at IS '创建时间';

-- 2b. sys_operation_log — 操作日志
CREATE TABLE public.sys_operation_log
(
    id             bigserial                              NOT NULL,
    user_id        int8                                   NOT NULL,
    username       varchar(256)                           NOT NULL,
    tenant_id      varchar(16)                            NOT NULL,
    operation_type varchar(64)                            NOT NULL,
    target_table   varchar(64)                            NULL,
    target_id      varchar(64)                            NULL,
    old_value      text                                   NULL,
    new_value      text                                   NULL,
    ip_address     varchar(64)                            NULL,
    user_agent     varchar(512)                           NULL,
    api_path       varchar(512)                           NULL,
    http_method    varchar(16)                            NULL,
    duration_ms    int4                                   NULL,
    result_code    varchar(32)                            NULL,
    result_msg     varchar(512)                           NULL,
    request_id     varchar(64)                            NULL,
    operated_at    timestamp(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by     int8                                   NOT NULL,
    created_at     timestamp(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT sys_operation_log_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_operation_log_tenant_user ON public.sys_operation_log USING btree (tenant_id, user_id);
CREATE INDEX idx_operation_log_tenant_time ON public.sys_operation_log USING btree (tenant_id, operated_at DESC);
CREATE INDEX idx_operation_log_type ON public.sys_operation_log USING btree (tenant_id, operation_type);
COMMENT ON TABLE public.sys_operation_log IS '操作日志表，记录用户对系统数据的操作行为，追加写入不可变更';

COMMENT ON COLUMN public.sys_operation_log.id IS '日志 ID，自增序列';
COMMENT ON COLUMN public.sys_operation_log.user_id IS '操作用户 ID';
COMMENT ON COLUMN public.sys_operation_log.username IS '用户名（冗余）';
COMMENT ON COLUMN public.sys_operation_log.tenant_id IS '租户 ID';
COMMENT ON COLUMN public.sys_operation_log.operation_type IS '操作类型：CREATE/UPDATE/DELETE/LOGIN/EXPORT/IMPORT/BATCH_DELETE 等';
COMMENT ON COLUMN public.sys_operation_log.target_table IS '操作目标表名';
COMMENT ON COLUMN public.sys_operation_log.target_id IS '操作目标记录 ID';
COMMENT ON COLUMN public.sys_operation_log.old_value IS '操作前数据（JSON 格式）';
COMMENT ON COLUMN public.sys_operation_log.new_value IS '操作后数据（JSON 格式）';
COMMENT ON COLUMN public.sys_operation_log.ip_address IS '请求 IP 地址';
COMMENT ON COLUMN public.sys_operation_log.user_agent IS '浏览器/客户端 User-Agent';
COMMENT ON COLUMN public.sys_operation_log.api_path IS 'API 路径';
COMMENT ON COLUMN public.sys_operation_log.http_method IS 'HTTP 方法：GET/POST/PUT/DELETE/PATCH';
COMMENT ON COLUMN public.sys_operation_log.duration_ms IS '请求耗时（毫秒）';
COMMENT ON COLUMN public.sys_operation_log.result_code IS '结果码：200/400/403/404/500 等';
COMMENT ON COLUMN public.sys_operation_log.result_msg IS '结果消息';
COMMENT ON COLUMN public.sys_operation_log.request_id IS '请求追踪 ID，用于关联同一请求的多个操作';
COMMENT ON COLUMN public.sys_operation_log.operated_at IS '操作时间';
COMMENT ON COLUMN public.sys_operation_log.created_by IS '创建人/操作用户';
COMMENT ON COLUMN public.sys_operation_log.created_at IS '创建时间';


-- ============================================================================
-- 3. 会话管理
--    存储访问令牌和刷新令牌的哈希，支持服务端会话撤销。
--    令牌字段仅存哈希值，不存明文令牌，降低泄露风险。
-- ============================================================================

-- sys_session — 用户会话/令牌
CREATE TABLE public.sys_session
(
    id                 int8                                   NOT NULL,
    status             int2         DEFAULT 1                 NOT NULL,
    user_id            int8                                   NOT NULL,
    tenant_id          varchar(16)                            NOT NULL,
    token_hash         varchar(128)                           NOT NULL,
    refresh_token_hash varchar(128)                           NULL,
    expires_at         timestamp(0)                           NOT NULL,
    refresh_expires_at timestamp(0)                           NULL,
    last_activity_at   timestamp(0)                           NULL,
    device_info        varchar(512)                           NULL,
    ip_address         varchar(64)                            NULL,
    is_revoked         boolean      DEFAULT false             NOT NULL,
    created_by         int8                                   NOT NULL,
    created_at         timestamp(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by         int8                                   NOT NULL,
    updated_at         timestamp(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT sys_session_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX sys_session_token_hash_un ON public.sys_session USING btree (token_hash);
CREATE UNIQUE INDEX sys_session_refresh_token_hash_un ON public.sys_session USING btree (refresh_token_hash) WHERE refresh_token_hash IS NOT NULL;
CREATE INDEX idx_session_tenant_user ON public.sys_session USING btree (tenant_id, user_id);
COMMENT ON TABLE public.sys_session IS '用户会话/令牌表，管理登录访问令牌和刷新令牌，支持服务端主动撤销';

COMMENT ON COLUMN public.sys_session.id IS '会话 ID';
COMMENT ON COLUMN public.sys_session.status IS '数据状态，0：禁用、1：启用';
COMMENT ON COLUMN public.sys_session.user_id IS '用户 ID';
COMMENT ON COLUMN public.sys_session.tenant_id IS '租户 ID';
COMMENT ON COLUMN public.sys_session.token_hash IS '访问令牌哈希（SHA-256），用于查找和验证令牌，不存明文';
COMMENT ON COLUMN public.sys_session.refresh_token_hash IS '刷新令牌哈希，用于令牌刷新轮换';
COMMENT ON COLUMN public.sys_session.expires_at IS '访问令牌过期时间';
COMMENT ON COLUMN public.sys_session.refresh_expires_at IS '刷新令牌过期时间';
COMMENT ON COLUMN public.sys_session.last_activity_at IS '最后活跃时间，用于检测僵尸会话';
COMMENT ON COLUMN public.sys_session.device_info IS '设备信息：操作系统、浏览器、设备型号等';
COMMENT ON COLUMN public.sys_session.ip_address IS '登录时 IP 地址';
COMMENT ON COLUMN public.sys_session.is_revoked IS '是否已主动撤销：true 后即使令牌未过期也不可用';
COMMENT ON COLUMN public.sys_session.created_by IS '创建人';
COMMENT ON COLUMN public.sys_session.created_at IS '创建时间';
COMMENT ON COLUMN public.sys_session.updated_by IS '更新人';
COMMENT ON COLUMN public.sys_session.updated_at IS '更新时间';


-- ============================================================================
-- 4. 系统全局配置
--    全局 key-value 配置，不绑定租户，无 RLS。
--    由平台超级管理员维护，应用层启动时读取。
-- ============================================================================

-- sys_config — 系统全局配置
CREATE TABLE public.sys_config
(
    id         int8                                                   NOT NULL,
    status     int2         DEFAULT 1                                 NOT NULL,
    "name"     varchar(128)                                           NOT NULL,
    config_key varchar(128)                                           NOT NULL,
    value      text                                                   NULL,
    value_type varchar(32)  DEFAULT 'string'                          NOT NULL,
    remark     varchar(512)                                           NULL,
    created_by int8                                                   NOT NULL,
    created_at timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    updated_by int8                                                   NOT NULL,
    updated_at timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    deleted_at timestamp(0) DEFAULT NULL::timestamp without time zone NULL,
    CONSTRAINT sys_config_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX sys_config_key_un ON public.sys_config USING btree (config_key) WHERE deleted_at IS NULL;
COMMENT ON TABLE public.sys_config IS '系统全局配置表，存储平台级系统参数，不绑定租户，所有租户共享';

COMMENT ON COLUMN public.sys_config.id IS '配置 ID';
COMMENT ON COLUMN public.sys_config.status IS '数据状态，0：禁用、1：启用';
COMMENT ON COLUMN public.sys_config."name" IS '配置名称';
COMMENT ON COLUMN public.sys_config.config_key IS '配置键（唯一），如 smtp.host、jwt.secret、session.timeout';
COMMENT ON COLUMN public.sys_config.value IS '配置值';
COMMENT ON COLUMN public.sys_config.value_type IS '值类型：string/integer/boolean/float/json';
COMMENT ON COLUMN public.sys_config.remark IS '备注';
COMMENT ON COLUMN public.sys_config.created_by IS '创建人';
COMMENT ON COLUMN public.sys_config.created_at IS '创建时间';
COMMENT ON COLUMN public.sys_config.updated_by IS '更新人';
COMMENT ON COLUMN public.sys_config.updated_at IS '更新时间';
COMMENT ON COLUMN public.sys_config.deleted_at IS '删除时间';


-- ============================================================================
-- 5. 租户配置
--    每个租户的自定义配置参数，有 RLS 租户隔离。
--    用于存储租户级别的个性化设置，覆盖全局配置的默认值。
-- ============================================================================

-- sys_tenant_config — 租户配置
CREATE TABLE public.sys_tenant_config
(
    id         int8                                                   NOT NULL,
    status     int2         DEFAULT 1                                 NOT NULL,
    "name"     varchar(128)                                           NOT NULL,
    config_key varchar(128)                                           NOT NULL,
    value      text                                                   NULL,
    value_type varchar(32)  DEFAULT 'string'                          NOT NULL,
    remark     varchar(512)                                           NULL,
    created_by int8                                                   NOT NULL,
    created_at timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    updated_by int8                                                   NOT NULL,
    updated_at timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    deleted_at timestamp(0) DEFAULT NULL::timestamp without time zone NULL,
    tenant_id  varchar(16)                                            NOT NULL,
    CONSTRAINT sys_tenant_config_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX sys_tenant_config_key_un ON public.sys_tenant_config USING btree (tenant_id, config_key) WHERE deleted_at IS NULL;
COMMENT ON TABLE public.sys_tenant_config IS '租户配置表，存储各租户的自定义配置参数，覆盖系统全局配置的默认值';

COMMENT ON COLUMN public.sys_tenant_config.id IS '配置 ID';
COMMENT ON COLUMN public.sys_tenant_config.status IS '数据状态，0：禁用、1：启用';
COMMENT ON COLUMN public.sys_tenant_config."name" IS '配置名称';
COMMENT ON COLUMN public.sys_tenant_config.config_key IS '配置键（租户内唯一）';
COMMENT ON COLUMN public.sys_tenant_config.value IS '配置值';
COMMENT ON COLUMN public.sys_tenant_config.value_type IS '值类型：string/integer/boolean/float/json';
COMMENT ON COLUMN public.sys_tenant_config.remark IS '备注';
COMMENT ON COLUMN public.sys_tenant_config.created_by IS '创建人';
COMMENT ON COLUMN public.sys_tenant_config.created_at IS '创建时间';
COMMENT ON COLUMN public.sys_tenant_config.updated_by IS '更新人';
COMMENT ON COLUMN public.sys_tenant_config.updated_at IS '更新时间';
COMMENT ON COLUMN public.sys_tenant_config.deleted_at IS '删除时间';
COMMENT ON COLUMN public.sys_tenant_config.tenant_id IS '租户 ID';


-- ============================================================================
-- 6. 功能特性
--    租户级别的功能开关，控制哪些功能对特定租户开放。
--    支持灰度发布、按租户控制功能权限（如导出、SSO、API 访问等）。
-- ============================================================================

-- sys_feature_flag — 功能特性
CREATE TABLE public.sys_feature_flag
(
    id          int8                                                   NOT NULL,
    status      int2         DEFAULT 1                                 NOT NULL,
    "name"      varchar(128)                                           NOT NULL,
    flag_key    varchar(128)                                           NOT NULL,
    description varchar(512)                                           NULL,
    is_enabled  boolean      DEFAULT false                             NOT NULL,
    remark      varchar(512)                                           NULL,
    created_by  int8                                                   NOT NULL,
    created_at  timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    updated_by  int8                                                   NOT NULL,
    updated_at  timestamp(0) DEFAULT CURRENT_TIMESTAMP                 NOT NULL,
    deleted_at  timestamp(0) DEFAULT NULL::timestamp without time zone NULL,
    tenant_id   varchar(16)                                            NOT NULL,
    CONSTRAINT sys_feature_flag_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX sys_feature_flag_tenant_key_un ON public.sys_feature_flag USING btree (tenant_id, flag_key) WHERE deleted_at IS NULL;
COMMENT ON TABLE public.sys_feature_flag IS '功能特性表，控制各租户的功能开关，支持灰度发布和按租户授权';

COMMENT ON COLUMN public.sys_feature_flag.id IS '特性 ID';
COMMENT ON COLUMN public.sys_feature_flag.status IS '数据状态，0：禁用、1：启用';
COMMENT ON COLUMN public.sys_feature_flag."name" IS '特性名称';
COMMENT ON COLUMN public.sys_feature_flag.flag_key IS '特性键（租户内唯一），如 export_enabled、sso_enabled、api_access、audit_log';
COMMENT ON COLUMN public.sys_feature_flag.description IS '特性描述，说明该功能的作用和使用场景';
COMMENT ON COLUMN public.sys_feature_flag.is_enabled IS '是否启用：true-开启功能 false-关闭功能';
COMMENT ON COLUMN public.sys_feature_flag.remark IS '备注';
COMMENT ON COLUMN public.sys_feature_flag.created_by IS '创建人';
COMMENT ON COLUMN public.sys_feature_flag.created_at IS '创建时间';
COMMENT ON COLUMN public.sys_feature_flag.updated_by IS '更新人';
COMMENT ON COLUMN public.sys_feature_flag.updated_at IS '更新时间';
COMMENT ON COLUMN public.sys_feature_flag.deleted_at IS '删除时间';
COMMENT ON COLUMN public.sys_feature_flag.tenant_id IS '租户 ID';


-- ============================================================================
-- RLS 策略
--    每张带 tenant_id 的租户隔离表均需 RLS 策略。
--    sys_config 为全局配置，无 tenant_id，不启用 RLS。
-- ============================================================================

-- 1. sys_menu
CREATE POLICY sys_menu_tenant_isolation ON public.sys_menu
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));

-- 2. sys_role_menu
CREATE POLICY sys_role_menu_tenant_isolation ON public.sys_role_menu
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));

-- 3. sys_login_log
CREATE POLICY sys_login_log_tenant_isolation ON public.sys_login_log
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));

-- 4. sys_operation_log
CREATE POLICY sys_operation_log_tenant_isolation ON public.sys_operation_log
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));

-- 5. sys_session
CREATE POLICY sys_session_tenant_isolation ON public.sys_session
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));

-- 6. sys_tenant_config
CREATE POLICY sys_tenant_config_tenant_isolation ON public.sys_tenant_config
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));

-- 7. sys_feature_flag
CREATE POLICY sys_feature_flag_tenant_isolation ON public.sys_feature_flag
    USING (tenant_id = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true));


-- ============================================================================
-- RLS 启用
-- ============================================================================

-- 1. sys_menu
ALTER TABLE public.sys_menu
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_menu
    FORCE ROW LEVEL SECURITY;

-- 2. sys_role_menu
ALTER TABLE public.sys_role_menu
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_role_menu
    FORCE ROW LEVEL SECURITY;

-- 3. sys_login_log
ALTER TABLE public.sys_login_log
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_login_log
    FORCE ROW LEVEL SECURITY;

-- 4. sys_operation_log
ALTER TABLE public.sys_operation_log
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_operation_log
    FORCE ROW LEVEL SECURITY;

-- 5. sys_session
ALTER TABLE public.sys_session
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_session
    FORCE ROW LEVEL SECURITY;

-- 6. sys_tenant_config
ALTER TABLE public.sys_tenant_config
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_tenant_config
    FORCE ROW LEVEL SECURITY;

-- 7. sys_feature_flag
ALTER TABLE public.sys_feature_flag
    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sys_feature_flag
    FORCE ROW LEVEL SECURITY;


-- ============================================================================
-- 授权
--    继承 basic.sql 的授权策略：app_u 用户对新表拥有完整 CRUD 权限。
--    bigserial 序列需要单独的 USAGE, SELECT 权限。
--    sys_config 为全局配置，也授予 app_u 读取权限（应用层需要）。
-- ============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_menu TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_role_menu TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_login_log TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_operation_log TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_session TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_config TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_tenant_config TO app_u;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sys_feature_flag TO app_u;

GRANT USAGE, SELECT ON SEQUENCE public.sys_login_log_id_seq TO app_u;
GRANT USAGE, SELECT ON SEQUENCE public.sys_operation_log_id_seq TO app_u;
