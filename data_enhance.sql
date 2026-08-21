-- ======================================================================
-- 业务增强种子数据
-- 配合 enhance.sql 使用，为新增表填充示例数据
-- 依赖于 data.sql 中已存在的租户/角色/用户
-- ======================================================================

-- ======================================================================
-- 1. 菜单/权限表 (sys_menu)
--    为默认租户 t-super-01 构建标准的后台管理菜单树
--    菜单结构：系统管理 → 用户管理/角色管理/菜单管理/租户管理/字典管理
--                      审计管理 → 操作日志/登录日志
--                      配置管理 → 系统配置/租户配置/功能特性
-- ======================================================================

-- 一级目录：系统管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (201, 1, '系统管理', 'sys:manage', NULL, 1, 'setting', '/system', NULL, 1, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：用户管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (202, 1, '用户管理', 'sys:user', 201, 2, 'user', '/system/user', 'system/user/index', 1, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (203, 1, '用户查询', 'sys:user:query', 202, 3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (204, 1, '用户新增', 'sys:user:create', 202, 3, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (205, 1, '用户编辑', 'sys:user:update', 202, 3, 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (206, 1, '用户删除', 'sys:user:delete', 202, 3, 4, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-重置密码
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (207, 1, '重置密码', 'sys:user:reset-pwd', 202, 3, 5, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-分配角色
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (208, 1, '分配角色', 'sys:user:assign-role', 202, 3, 6, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：角色管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (209, 1, '角色管理', 'sys:role', 201, 2, 'role', '/system/role', 'system/role/index', 2, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：角色管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (210, 1, '角色查询', 'sys:role:query', 209, 3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：角色管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (211, 1, '角色新增', 'sys:role:create', 209, 3, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：角色管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (212, 1, '角色编辑', 'sys:role:update', 209, 3, 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：角色管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (213, 1, '角色删除', 'sys:role:delete', 209, 3, 4, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：菜单管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (214, 1, '菜单管理', 'sys:menu', 201, 2, 'menu', '/system/menu', 'system/menu/index', 3, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：菜单管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (215, 1, '菜单查询', 'sys:menu:query', 214, 3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：菜单管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (216, 1, '菜单新增', 'sys:menu:create', 214, 3, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：菜单管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (217, 1, '菜单编辑', 'sys:menu:update', 214, 3, 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：菜单管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (218, 1, '菜单删除', 'sys:menu:delete', 214, 3, 4, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：租户管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (219, 1, '租户管理', 'sys:tenant', 201, 2, 'tenant', '/system/tenant', 'system/tenant/index', 4, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：租户管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (220, 1, '租户查询', 'sys:tenant:query', 219, 3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：租户管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (221, 1, '租户新增', 'sys:tenant:create', 219, 3, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：租户管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (222, 1, '租户编辑', 'sys:tenant:update', 219, 3, 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：租户管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (223, 1, '租户删除', 'sys:tenant:delete', 219, 3, 4, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：字典管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (224, 1, '字典管理', 'sys:dict', 201, 2, 'dict', '/system/dict', 'system/dict/index', 5, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：字典管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (225, 1, '字典查询', 'sys:dict:query', 224, 3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：字典管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (226, 1, '字典新增', 'sys:dict:create', 224, 3, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：字典管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (227, 1, '字典编辑', 'sys:dict:update', 224, 3, 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：字典管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (228, 1, '字典删除', 'sys:dict:delete', 224, 3, 4, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 一级目录：审计管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (229, 1, '审计管理', 'sys:audit', NULL, 1, 'audit', '/audit', NULL, 2, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：操作日志
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (230, 1, '操作日志', 'sys:audit:operation-log', 229, 2, 'operation-log', '/audit/operation-log',
        'audit/operation-log/index', 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：登录日志
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (231, 1, '登录日志', 'sys:audit:login-log', 229, 2, 'login-log', '/audit/login-log', 'audit/login-log/index', 2,
        1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 一级目录：配置管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (232, 1, '配置管理', 'sys:config', NULL, 1, 'config', '/config', NULL, 3, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：系统配置
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (233, 1, '系统配置', 'sys:config:global', 232, 2, 'global-config', '/config/global', 'config/global/index', 1, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：租户配置
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (234, 1, '租户配置', 'sys:config:tenant', 232, 2, 'tenant-config', '/config/tenant', 'config/tenant/index', 2, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 二级菜单：功能特性
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (235, 1, '功能特性', 'sys:config:feature-flag', 232, 2, 'feature-flag', '/config/feature-flag',
        'config/feature-flag/index', 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 一级目录：部门管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (236, 1, '部门管理', 'sys:dept', NULL, 1, 'dept', '/dept', 'dept/index', 4, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：部门管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (237, 1, '部门查询', 'sys:dept:query', 236, 3, 1, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：部门管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (238, 1, '部门新增', 'sys:dept:create', 236, 3, 2, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：部门管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (239, 1, '部门编辑', 'sys:dept:update', 236, 3, 3, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：部门管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (240, 1, '部门删除', 'sys:dept:delete', 236, 3, 4, 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 一级目录：用户组管理
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (241, 1, '用户组管理', 'sys:user-group', NULL, 1, 'group', '/user-group', 'user-group/index', 5, 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户组管理-查询
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (242, 1, '用户组查询', 'sys:user-group:query', 241, 3, 1, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户组管理-新增
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (243, 1, '用户组新增', 'sys:user-group:create', 241, 3, 2, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户组管理-编辑
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (244, 1, '用户组编辑', 'sys:user-group:update', 241, 3, 3, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户组管理-删除
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (245, 1, '用户组删除', 'sys:user-group:delete', 241, 3, 4, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- ===========================
-- 1b. 演示租户菜单副本 (t-demo-01)
--     菜单为租户数据（带 tenant_id + RLS），租户开通时从平台模板复制所需菜单子树。
--     演示租户管理员 (105) 只需：系统管理目录 + 用户/字典管理查询与新增编辑 + 部门管理。
--     ID 段使用 12xx，与 t-super-01 的 2xx 模板区分。
-- ===========================

-- 一级目录：系统管理（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1201, 1, '系统管理', 'sys:manage', NULL, 1, 'setting', '/system', NULL, 1, 1, '2026-06-02 09:00:00.000', 1,
        '2026-06-02 09:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 二级菜单：用户管理（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1202, 1, '用户管理', 'sys:user', 1201, 2, 'user', '/system/user', 'system/user/index', 1, 1,
        '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-查询（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1203, 1, '用户查询', 'sys:user:query', 1202, 3, 1, 1, '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000',
        NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-新增（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1204, 1, '用户新增', 'sys:user:create', 1202, 3, 2, 1, '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000',
        NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 三级按钮：用户管理-编辑（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1205, 1, '用户编辑', 'sys:user:update', 1202, 3, 3, 1, '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000',
        NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 二级菜单：字典管理（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1224, 1, '字典管理', 'sys:dict', 1201, 2, 'dict', '/system/dict', 'system/dict/index', 5, 1,
        '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 三级按钮：字典管理-查询（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1225, 1, '字典查询', 'sys:dict:query', 1224, 3, 1, 1, '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000',
        NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 一级目录：部门管理（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, icon, route_path, component,
                             sort_order, created_by, created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1236, 1, '部门管理', 'sys:dept', NULL, 1, 'dept', '/dept', 'dept/index', 4, 1, '2026-06-02 09:00:00.000', 1,
        '2026-06-02 09:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

-- 三级按钮：部门管理-查询（演示租户）
INSERT INTO public.sys_menu (id, status, "name", permission_code, parent_id, menu_type, sort_order, created_by,
                             created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1237, 1, '部门查询', 'sys:dept:query', 1236, 3, 1, 1, '2026-06-02 09:00:00.000', 1, '2026-06-02 09:00:00.000',
        NULL, 't-demo-01') ON CONFLICT DO NOTHING;


-- ======================================================================
-- 2. 角色-菜单映射表 (sys_role_menu)
--    为已有角色分配菜单权限
-- ======================================================================

-- 超级管理员 (101) → 全部菜单
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 201, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 202, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 203, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 204, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 205, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 206, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 207, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 208, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 209, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 210, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 211, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 212, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 213, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 214, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 215, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 216, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 217, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 218, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 219, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 220, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 221, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 222, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 223, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 224, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 225, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 226, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 227, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 228, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 229, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 230, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 231, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 232, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 233, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 234, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 235, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 236, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 237, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 238, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 239, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 240, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 241, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 242, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 243, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 244, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (101, 245, 't-super-01', 1) ON CONFLICT DO NOTHING;

-- 部门管理员 (102) → 系统管理目录 + 用户管理查询/新增/编辑 + 部门管理全部
-- 一级目录 201 必须分配，否则子菜单成为孤儿节点，前端无法构建菜单树
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 201, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 202, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 203, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 204, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 205, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 207, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 236, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 237, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 238, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (102, 239, 't-super-01', 1) ON CONFLICT DO NOTHING;

-- 普通用户 (103) → 系统管理目录 + 仅用户管理查询 + 部门查询
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (103, 201, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (103, 202, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (103, 203, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (103, 236, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (103, 237, 't-super-01', 1) ON CONFLICT DO NOTHING;

-- 审计员 (104) → 审计管理全部菜单（只读，无写权限按钮）+ 系统管理目录
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 229, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 230, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 231, 't-super-01', 1) ON CONFLICT DO NOTHING;
-- 审计员还可以看用户管理和字典的查询
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 201, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 202, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 203, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 224, 't-super-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (104, 225, 't-super-01', 1) ON CONFLICT DO NOTHING;

-- 演示租户管理员 (105) → 演示租户自身的菜单副本 (12xx)：
-- 系统管理目录 + 用户管理查询/新增/编辑 + 字典查询 + 部门管理
-- 注意：不可映射 t-super-01 的 2xx 菜单，RLS 下跨租户 JOIN 不可见
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1201, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1202, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1203, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1204, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1205, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1224, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1225, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1236, 't-demo-01', 1) ON CONFLICT DO NOTHING;
INSERT INTO public.sys_role_menu (role_id, menu_id, tenant_id, created_by)
VALUES (105, 1237, 't-demo-01', 1) ON CONFLICT DO NOTHING;


-- ======================================================================
-- 3. 登录日志 (sys_login_log) — 示例数据
-- ======================================================================

INSERT INTO public.sys_login_log (user_id, username, tenant_id, ip_address, user_agent, login_type, is_success,
                                  failure_reason, login_at, created_by, created_at)
VALUES (1, 'admin', 't-super-01', '192.168.1.100', 'Mozilla/5.0 Chrome/120.0', 'password', true, NULL,
        '2026-06-30 08:00:00.000', 1, '2026-06-30 08:00:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_login_log (user_id, username, tenant_id, ip_address, user_agent, login_type, is_success,
                                  failure_reason, login_at, created_by, created_at)
VALUES (2, 'zhangsan', 't-super-01', '192.168.1.101', 'Mozilla/5.0 Chrome/120.0', 'password', true, NULL,
        '2026-06-30 08:30:00.000', 2, '2026-06-30 08:30:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_login_log (user_id, username, tenant_id, ip_address, user_agent, login_type, is_success,
                                  failure_reason, login_at, created_by, created_at)
VALUES (3, 'lisi', 't-super-01', '192.168.1.102', 'Mozilla/5.0 Firefox/121.0', 'password', false, '密码错误',
        '2026-06-30 09:00:00.000', 3, '2026-06-30 09:00:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_login_log (user_id, username, tenant_id, ip_address, user_agent, login_type, is_success,
                                  failure_reason, login_at, created_by, created_at)
VALUES (3, 'lisi', 't-super-01', '192.168.1.102', 'Mozilla/5.0 Firefox/121.0', 'password', true, NULL,
        '2026-06-30 09:01:00.000', 3, '2026-06-30 09:01:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_login_log (user_id, username, tenant_id, ip_address, user_agent, login_type, is_success,
                                  failure_reason, login_at, created_by, created_at)
VALUES (5, 'zhaoliu', 't-demo-01', '10.0.0.50', 'Mozilla/5.0 Safari/17.0', 'password', true, NULL,
        '2026-06-30 10:00:00.000', 5, '2026-06-30 10:00:00.000') ON CONFLICT DO NOTHING;


-- ======================================================================
-- 4. 操作日志 (sys_operation_log) — 示例数据
-- ======================================================================

INSERT INTO public.sys_operation_log (user_id, username, tenant_id, operation_type, target_table, target_id, old_value,
                                      new_value, ip_address, api_path, http_method, duration_ms, result_code,
                                      request_id, operated_at, created_by, created_at)
VALUES (1, 'admin', 't-super-01', 'CREATE', 'sys_user', '2',
        NULL,
        '{"name":"zhangsan","nickname":"张三","dept_id":2}',
        '192.168.1.100', '/api/system/user', 'POST', 45, '200', 'req-001', '2026-06-01 10:05:00.000', 1,
        '2026-06-01 10:05:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_operation_log (user_id, username, tenant_id, operation_type, target_table, target_id, old_value,
                                      new_value, ip_address, api_path, http_method, duration_ms, result_code,
                                      request_id, operated_at, created_by, created_at)
VALUES (1, 'admin', 't-super-01', 'UPDATE', 'sys_role', '103',
        '{"data_scope":1}',
        '{"data_scope":1,"remark":"默认角色"}',
        '192.168.1.100', '/api/system/role/103', 'PUT', 30, '200', 'req-002', '2026-06-01 10:10:00.000', 1,
        '2026-06-01 10:10:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_operation_log (user_id, username, tenant_id, operation_type, target_table, target_id, old_value,
                                      new_value, ip_address, api_path, http_method, duration_ms, result_code,
                                      request_id, operated_at, created_by, created_at)
VALUES (1, 'admin', 't-super-01', 'DELETE', 'sys_user', '99',
        '{"name":"temp_user","nickname":"临时用户"}',
        NULL,
        '192.168.1.100', '/api/system/user/99', 'DELETE', 20, '200', 'req-003', '2026-06-01 11:00:00.000', 1,
        '2026-06-01 11:00:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_operation_log (user_id, username, tenant_id, operation_type, target_table, target_id, old_value,
                                      new_value, ip_address, api_path, http_method, duration_ms, result_code,
                                      request_id, operated_at, created_by, created_at)
VALUES (1, 'admin', 't-super-01', 'ASSIGN_ROLE', 'sys_user_role_mapping', '2',
        NULL,
        '{"user_id":2,"role_ids":[103]}',
        '192.168.1.100', '/api/system/user/2/roles', 'POST', 15, '200', 'req-004', '2026-06-01 11:05:00.000', 1,
        '2026-06-01 11:05:00.000') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_operation_log (user_id, username, tenant_id, operation_type, target_table, target_id, old_value,
                                      new_value, ip_address, api_path, http_method, duration_ms, result_code,
                                      request_id, operated_at, created_by, created_at)
VALUES (1, 'admin', 't-super-01', 'LOGIN', NULL, NULL,
        NULL, NULL,
        '192.168.1.100', '/api/auth/login', 'POST', 120, '200', 'req-005', '2026-06-30 08:00:00.000', 1,
        '2026-06-30 08:00:00.000') ON CONFLICT DO NOTHING;


-- ======================================================================
-- 5. 系统全局配置 (sys_config)
-- ======================================================================

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (1, 1, '会话超时时间', 'session.timeout', '1800', 'integer', '用户会话超时时间（秒），默认 30 分钟', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL) ON CONFLICT DO NOTHING;

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (2, 1, '刷新令牌过期时间', 'session.refresh-timeout', '604800', 'integer', '刷新令牌过期时间（秒），默认 7 天', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL) ON CONFLICT DO NOTHING;

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (3, 1, '密码错误锁定阈值', 'auth.lockout-threshold', '5', 'integer',
        '连续密码错误次数超过此值将锁定账号，0 表示不锁定', 1, '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000',
        NULL) ON CONFLICT DO NOTHING;

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (4, 1, '密码错误锁定时长', 'auth.lockout-duration', '1800', 'integer', '账号锁定持续时间（秒），默认 30 分钟', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL) ON CONFLICT DO NOTHING;

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (5, 1, '密码最小长度', 'auth.password-min-length', '6', 'integer', '用户密码最小长度要求', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL) ON CONFLICT DO NOTHING;

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (6, 1, 'SMTP 主机', 'smtp.host', 'smtp.example.com', 'string', '邮件发送服务器地址', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL) ON CONFLICT DO NOTHING;

INSERT INTO public.sys_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                               updated_by, updated_at, deleted_at)
VALUES (7, 1, '系统名称', 'system.name', '基础多租户管理系统', 'string', '系统显示名称', 1, '2026-06-01 10:00:00.000',
        1, '2026-06-01 10:00:00.000', NULL) ON CONFLICT DO NOTHING;


-- ======================================================================
-- 6. 租户配置 (sys_tenant_config)
--    为默认租户设置部分个性化配置
-- ======================================================================

INSERT INTO public.sys_tenant_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                                      updated_by, updated_at, deleted_at, tenant_id)
VALUES (1, 1, '租户 Logo', 'tenant.logo', '/logo/default.png', 'string', '租户 Logo 路径', 1, '2026-06-01 10:00:00.000',
        1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_tenant_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                                      updated_by, updated_at, deleted_at, tenant_id)
VALUES (2, 1, '租户显示名称', 'tenant.display-name', '默认租户', 'string', '租户在界面上的显示名称', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_tenant_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                                      updated_by, updated_at, deleted_at, tenant_id)
VALUES (3, 1, '演示租户显示名称', 'tenant.display-name', '演示环境', 'string', '租户在界面上的显示名称', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_tenant_config (id, status, "name", config_key, value, value_type, remark, created_by, created_at,
                                      updated_by, updated_at, deleted_at, tenant_id)
VALUES (4, 1, '会话超时', 'session.timeout', '3600', 'integer', '租户级会话超时覆盖全局配置（秒）', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;


-- ======================================================================
-- 7. 功能特性 (sys_feature_flag)
--    控制各租户的功能开关
-- ======================================================================

-- 默认租户 — 开启全部功能
INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1, 1, '数据导出', 'export_enabled', '是否允许租户导出数据（Excel/CSV）', true, '默认租户开启导出功能', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (2, 1, 'API 访问', 'api_access', '是否允许租户通过 API 密钥访问系统', true, '默认租户开启 API 访问', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (3, 1, 'SSO 单点登录', 'sso_enabled', '是否允许租户配置 SSO 单点登录', true, '默认租户开启 SSO', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (4, 1, '审计日志', 'audit_log', '是否启用操作日志记录', true, '默认租户开启审计日志', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- 演示租户 — 有限功能
INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (5, 1, '数据导出', 'export_enabled', '是否允许租户导出数据', true, '演示租户开启导出功能', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (6, 1, 'API 访问', 'api_access', '是否允许租户通过 API 密钥访问系统', false, '演示租户关闭 API 访问', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (7, 1, 'SSO 单点登录', 'sso_enabled', '是否允许租户配置 SSO', false, '演示租户关闭 SSO', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_feature_flag (id, status, "name", flag_key, description, is_enabled, remark, created_by,
                                     created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (8, 1, '审计日志', 'audit_log', '是否启用操作日志记录', true, '演示租户开启审计日志', 1,
        '2026-06-01 10:00:00.000', 1, '2026-06-01 10:00:00.000', NULL, 't-demo-01') ON CONFLICT DO NOTHING;


-- ======================================================================
-- 8. 通用翻译 (sys_translation)
--    为默认租户 t-super-01 提供 en-US（英文）翻译种子数据。
--    应用层查询时先按用户语言偏好匹配，未命中则回退原始值（中文）。
-- ======================================================================

-- ===========================
-- 8a. 菜单名称翻译 (sys_menu.name → en-US)
-- ===========================
INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (1, 1, 'sys_menu', 201, 'name', 'en-US', 'System Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (2, 1, 'sys_menu', 202, 'name', 'en-US', 'User Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (3, 1, 'sys_menu', 203, 'name', 'en-US', 'User Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (4, 1, 'sys_menu', 204, 'name', 'en-US', 'User Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (5, 1, 'sys_menu', 205, 'name', 'en-US', 'User Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (6, 1, 'sys_menu', 206, 'name', 'en-US', 'User Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (7, 1, 'sys_menu', 207, 'name', 'en-US', 'Reset Password', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (8, 1, 'sys_menu', 208, 'name', 'en-US', 'Assign Role', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (9, 1, 'sys_menu', 209, 'name', 'en-US', 'Role Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (10, 1, 'sys_menu', 210, 'name', 'en-US', 'Role Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (11, 1, 'sys_menu', 211, 'name', 'en-US', 'Role Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (12, 1, 'sys_menu', 212, 'name', 'en-US', 'Role Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (13, 1, 'sys_menu', 213, 'name', 'en-US', 'Role Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (14, 1, 'sys_menu', 214, 'name', 'en-US', 'Menu Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (15, 1, 'sys_menu', 215, 'name', 'en-US', 'Menu Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (16, 1, 'sys_menu', 216, 'name', 'en-US', 'Menu Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (17, 1, 'sys_menu', 217, 'name', 'en-US', 'Menu Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (18, 1, 'sys_menu', 218, 'name', 'en-US', 'Menu Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (19, 1, 'sys_menu', 219, 'name', 'en-US', 'Tenant Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (20, 1, 'sys_menu', 220, 'name', 'en-US', 'Tenant Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (21, 1, 'sys_menu', 221, 'name', 'en-US', 'Tenant Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (22, 1, 'sys_menu', 222, 'name', 'en-US', 'Tenant Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (23, 1, 'sys_menu', 223, 'name', 'en-US', 'Tenant Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (24, 1, 'sys_menu', 224, 'name', 'en-US', 'Dictionary Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (25, 1, 'sys_menu', 225, 'name', 'en-US', 'Dictionary Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (26, 1, 'sys_menu', 226, 'name', 'en-US', 'Dictionary Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (27, 1, 'sys_menu', 227, 'name', 'en-US', 'Dictionary Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (28, 1, 'sys_menu', 228, 'name', 'en-US', 'Dictionary Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (29, 1, 'sys_menu', 229, 'name', 'en-US', 'Audit Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (30, 1, 'sys_menu', 230, 'name', 'en-US', 'Operation Log', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (31, 1, 'sys_menu', 231, 'name', 'en-US', 'Login Log', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (32, 1, 'sys_menu', 232, 'name', 'en-US', 'Configuration Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (33, 1, 'sys_menu', 233, 'name', 'en-US', 'System Config', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (34, 1, 'sys_menu', 234, 'name', 'en-US', 'Tenant Config', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (35, 1, 'sys_menu', 235, 'name', 'en-US', 'Feature Flags', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (36, 1, 'sys_menu', 236, 'name', 'en-US', 'Department Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (37, 1, 'sys_menu', 237, 'name', 'en-US', 'Department Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (38, 1, 'sys_menu', 238, 'name', 'en-US', 'Department Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (39, 1, 'sys_menu', 239, 'name', 'en-US', 'Department Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (40, 1, 'sys_menu', 240, 'name', 'en-US', 'Department Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (41, 1, 'sys_menu', 241, 'name', 'en-US', 'User Group Management', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (42, 1, 'sys_menu', 242, 'name', 'en-US', 'User Group Query', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (43, 1, 'sys_menu', 243, 'name', 'en-US', 'User Group Create', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (44, 1, 'sys_menu', 244, 'name', 'en-US', 'User Group Edit', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (45, 1, 'sys_menu', 245, 'name', 'en-US', 'User Group Delete', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- ===========================
-- 8b. 字典标签翻译 (sys_dict_data.label → en-US)
--     覆盖 sys_data_scope、sys_role_type、sys_data_status 三种字典类型
-- ===========================
INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (46, 1, 'sys_dict_data', 1, 'label', 'en-US', 'Only Self', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (47, 1, 'sys_dict_data', 2, 'label', 'en-US', 'Current Dept', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (48, 1, 'sys_dict_data', 3, 'label', 'en-US', 'Dept & Sub-depts', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (49, 1, 'sys_dict_data', 4, 'label', 'en-US', 'Specified Users', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (50, 1, 'sys_dict_data', 5, 'label', 'en-US', 'Specified Depts', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (51, 1, 'sys_dict_data', 6, 'label', 'en-US', 'User Group', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (52, 1, 'sys_dict_data', 7, 'label', 'en-US', 'All Tenant', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (53, 1, 'sys_dict_data', 8, 'label', 'en-US', 'System Preset', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (54, 1, 'sys_dict_data', 9, 'label', 'en-US', 'Tenant Custom', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (55, 1, 'sys_dict_data', 10, 'label', 'en-US', 'Enabled', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (56, 1, 'sys_dict_data', 11, 'label', 'en-US', 'Disabled', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

-- ===========================
-- 8c. 系统配置名称翻译 (sys_config.name → en-US)
--     配置名称仅管理界面可见，也提供翻译以保持国际化一致性
-- ===========================
INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (57, 1, 'sys_config', 1, 'name', 'en-US', 'Session Timeout', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (58, 1, 'sys_config', 2, 'name', 'en-US', 'Refresh Token Timeout', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (59, 1, 'sys_config', 3, 'name', 'en-US', 'Password Lockout Threshold', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (60, 1, 'sys_config', 4, 'name', 'en-US', 'Password Lockout Duration', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (61, 1, 'sys_config', 5, 'name', 'en-US', 'Password Min Length', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (62, 1, 'sys_config', 6, 'name', 'en-US', 'SMTP Host', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;

INSERT INTO public.sys_translation (id, status, table_name, row_id, column_name, locale, value, remark, created_by,
                                    created_at, updated_by, updated_at, deleted_at, tenant_id)
VALUES (63, 1, 'sys_config', 7, 'name', 'en-US', 'System Name', NULL, 1, '2026-06-01 10:00:00.000', 1,
        '2026-06-01 10:00:00.000', NULL, 't-super-01') ON CONFLICT DO NOTHING;
