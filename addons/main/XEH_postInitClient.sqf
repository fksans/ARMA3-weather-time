#include "script_component.hpp"
/*
 * 客户端初始化：入口（ZEN 模块 / ZEN 右键菜单 / CBA 快捷键）。
 * 本模组只在 Zeus 自己的客户端加载，其他玩家和服务器不需要安装。
 */

if (!hasInterface) exitWith {};

// ---- 入口 1：ZEN 自定义模块 ----
[
    localize "STR_ZTW_ModuleCategory",
    localize "STR_ZTW_ModuleName",
    {[] call ztw_fnc_open},
    "\a3\ui_f\data\igui\cfg\simpleTasks\types\wait_ca.paa"
] call zen_custom_modules_fnc_register;

// ---- 入口 2：ZEN 右键菜单 ----
private _action = [
    "ztw_open",
    localize "STR_ZTW_ContextMenu",
    "\a3\ui_f\data\igui\cfg\simpleTasks\types\wait_ca.paa",
    {[] call ztw_fnc_open},
    {call ztw_fnc_canOpen}
] call zen_context_menu_fnc_createAction;
[_action, [], 0] call zen_context_menu_fnc_addAction;

// ---- 入口 3：CBA 快捷键（默认 Ctrl+Shift+T，可在 设置→控制→插件设置 中修改） ----
[
    "Zeus Time & Weather",
    "ztw_open",
    [localize "STR_ZTW_KeybindOpen", localize "STR_ZTW_KeybindOpenTooltip"],
    {
        if (call ztw_fnc_canOpen) then {
            [] call ztw_fnc_open;
            true
        } else {
            false
        };
    },
    "",
    [0x14, [true, true, false]] // DIK_T, [Shift, Ctrl, Alt]
] call CBA_fnc_addKeybind;
