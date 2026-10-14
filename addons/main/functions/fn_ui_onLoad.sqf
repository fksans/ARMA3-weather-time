#include "..\script_component.hpp"
/*
 * 时间 / 天气过渡界面 onLoad：初始化控件、绑定事件、启动「现在」一行的刷新。
 *
 * Arguments:
 * 0: Display <DISPLAY>
 */

params ["_display"];

uiNamespace setVariable ["ztw_display", _display];

// ---- 方式：到指定时间 / 前进小时数 ----
private _ctrlMode = _display displayCtrl IDC_ZTW_MODE;
_ctrlMode lbSetCurSel (uiNamespace getVariable ["ztw_lastMode", 0]);
_ctrlMode ctrlAddEventHandler ["ToolBoxSelChanged", {
    params ["", "_index"];
    uiNamespace setVariable ["ztw_lastMode", _index];
    [] call ztw_fnc_ui_update;
}];

// 目标时间默认为下一个整点
(_display displayCtrl IDC_ZTW_TARGET_TIME) ctrlSetText (uiNamespace getVariable ["ztw_lastTarget", [floor dayTime + 1] call ztw_fnc_formatClock]);
(_display displayCtrl IDC_ZTW_SKIP_HOURS) ctrlSetText (uiNamespace getVariable ["ztw_lastSkip", "1"]);
(_display displayCtrl IDC_ZTW_DURATION) ctrlSetText str (profileNamespace getVariable [PROFILE_DURATION, 20]);

// ---- 曲线 ----
private _ctrlEase = _display displayCtrl IDC_ZTW_EASE;
_ctrlEase lbAdd localize "STR_ZTW_EaseLinear";
_ctrlEase lbAdd localize "STR_ZTW_EaseInOut";
_ctrlEase lbSetCurSel ([0, 1] select (profileNamespace getVariable [PROFILE_EASE, true]));

// ---- 天气：默认填当前值、都不勾选（只跳时间） ----
{
    (_display displayCtrl (IDC_ZTW_WEATHER_EDIT + _forEachIndex)) ctrlSetText (_x toFixed 2);
} forEach [overcast, fog, rain, windStr, lightnings, waves];

private _ctrlPreset = _display displayCtrl IDC_ZTW_WEATHER_PRESET;
_ctrlPreset lbAdd localize "STR_ZTW_WeatherPresetPick";
{
    _ctrlPreset lbAdd (_x select 0);
} forEach WEATHER_PRESETS;
_ctrlPreset lbSetCurSel 0;
_ctrlPreset ctrlAddEventHandler ["LBSelChanged", {
    params ["", "_index"];
    ["weatherPreset", _index] call ztw_fnc_ui_action;
}];

// ---- 输入变化时刷新预览 ----
{
    (_display displayCtrl _x) ctrlAddEventHandler ["KeyUp", {[] call ztw_fnc_ui_update}];
} forEach [IDC_ZTW_TARGET_TIME, IDC_ZTW_SKIP_HOURS, IDC_ZTW_DURATION];

// ---- 按钮 ----
{
    _x params ["_idc", "_action", ["_arg", ""]];
    private _ctrl = _display displayCtrl _idc;
    _ctrl setVariable ["ztw_action", [_action, _arg]];
    _ctrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        (_ctrl getVariable "ztw_action") call ztw_fnc_ui_action;
    }];
} forEach [
    [IDC_ZTW_CLOSE, "close"],
    [IDC_ZTW_SUNRISE, "presetTime", "sunrise"],
    [IDC_ZTW_NOON, "presetTime", "noon"],
    [IDC_ZTW_SUNSET, "presetTime", "sunset"],
    [IDC_ZTW_MIDNIGHT, "presetTime", "midnight"],
    [IDC_ZTW_READ_WEATHER, "readWeather"],
    [IDC_ZTW_START, "start"],
    [IDC_ZTW_STOP, "stop"]
];

(_display displayCtrl IDC_ZTW_HINT) ctrlSetStructuredText parseText localize "STR_ZTW_Hint";

[] call ztw_fnc_ui_update;

[{
    params ["", "_handle"];
    private _display = uiNamespace getVariable ["ztw_display", displayNull];
    if (isNull _display) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    // 界面打开期间失去 curator 身份（被收回 Zeus）则直接关闭
    if !(call ztw_fnc_canOpen) exitWith {
        _display closeDisplay 2;
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    [] call ztw_fnc_ui_update;
}, 0.25] call CBA_fnc_addPerFrameHandler;
