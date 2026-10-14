#include "..\script_component.hpp"
/*
 * 打开时间 / 天气过渡界面。
 * Zeus 界面（display 312）打开时作为其子 display 弹出，这样 Zeus 界面保持打开，
 * 关掉窗口就回到 Zeus；不在 Zeus 界面时以普通 dialog 打开。
 *
 * Return Value:
 * 是否允许打开 <BOOL>
 */

if !(call ztw_fnc_canOpen) exitWith {
    systemChat localize "STR_ZTW_NotCurator";
    false
};

// 下一帧再创建：避免和 ZEN 右键菜单关闭、模块放置等同一帧的 UI 操作冲突
[{
    if (!isNull (uiNamespace getVariable ["ztw_display", displayNull])) exitWith {};
    if !(call ztw_fnc_canOpen) exitWith {};

    private _curatorDisplay = findDisplay 312;
    if (isNull _curatorDisplay) then {
        createDialog "ztw_display";
    } else {
        _curatorDisplay createDisplay "ztw_display";
    };
}] call CBA_fnc_execNextFrame;

true
