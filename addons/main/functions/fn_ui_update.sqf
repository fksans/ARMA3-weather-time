#include "..\script_component.hpp"
/*
 * 刷新时间 / 天气过渡界面的「现在」一行和预览（界面打开时每 0.25 秒调用一次，输入变化时也会调用）。
 */

private _display = uiNamespace getVariable ["ztw_display", displayNull];
if (isNull _display) exitWith {};

// ---- 现在的时间 / 天气 / 过渡进度 ----
private _current = format [
    localize "STR_ZTW_Current",
    [dayTime] call ztw_fnc_formatClock,
    overcast toFixed 2,
    fog toFixed 2,
    rain toFixed 2,
    windStr toFixed 2,
    lightnings toFixed 2,
    waves toFixed 2
];
private _active = missionNamespace getVariable ["ztw_token", ""] != "";
if (_active) then {
    _current = _current + " · " + format [localize "STR_ZTW_Progress", round (100 * (missionNamespace getVariable ["ztw_progress", 0]))];
};
(_display displayCtrl IDC_ZTW_CURRENT) ctrlSetText _current;
(_display displayCtrl IDC_ZTW_STOP) ctrlEnable _active;

// ---- 预览：会跳到几点 ----
private _ctrlPreview = _display displayCtrl IDC_ZTW_PREVIEW;
private _params = call ztw_fnc_ui_readParams;
if (_params isEqualType "") exitWith {
    _ctrlPreview ctrlSetText _params;
    _ctrlPreview ctrlSetTextColor [1, 0.4, 0.4, 1];
};

_params params ["_hours", "_duration"];
_ctrlPreview ctrlSetTextColor [1, 0.85, 0.4, 1];
if (_hours == 0) then {
    _ctrlPreview ctrlSetText format [localize "STR_ZTW_PreviewWeatherOnly", _duration];
} else {
    _ctrlPreview ctrlSetText format [
        localize "STR_ZTW_Preview",
        [dayTime] call ztw_fnc_formatClock,
        [dayTime + _hours] call ztw_fnc_formatClock,
        [_hours, false] call ztw_fnc_formatClock,
        _duration
    ];
};
