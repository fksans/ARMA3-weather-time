#include "..\script_component.hpp"
/*
 * 时间 / 天气过渡界面按钮 / 事件的统一处理。
 *
 * Arguments:
 * 0: 动作 <STRING>
 * 1: 参数 <ANY>（快捷时间："sunrise" / "noon" / "sunset" / "midnight"；天气预设：序号）
 */

params [["_action", "", [""]], ["_arg", ""]];

private _display = uiNamespace getVariable ["ztw_display", displayNull];
if (isNull _display) exitWith {};

switch (_action) do {
    case "close": {
        _display closeDisplay 2;
    };

    // ---- 快捷时间：填进「目标时间」并切到「到指定时间」 ----
    case "presetTime": {
        private _hours = switch (_arg) do {
            case "noon": {12};
            case "midnight": {0};
            default {
                // 按当前地图纬度和日期计算；极昼 / 极夜时返回负数
                (date call BIS_fnc_sunriseSunsetTime) params ["_sunrise", "_sunset"];
                if (_sunrise < 0 || _sunset < 0) then {-1} else {[_sunset, _sunrise] select (_arg == "sunrise")};
            };
        };
        if (_hours < 0) exitWith {
            [localize "STR_ZTW_NoSunriseSunset", [1, 0.4, 0.4, 1]] call ztw_fnc_ui_setStatus;
        };
        (_display displayCtrl IDC_ZTW_TARGET_TIME) ctrlSetText ([_hours] call ztw_fnc_formatClock);
        (_display displayCtrl IDC_ZTW_MODE) lbSetCurSel 0;
    };

    // ---- 天气 ----
    case "weatherPreset": {
        // 第 0 项是「选择预设…」
        if (_arg < 1) exitWith {};
        {
            (_display displayCtrl (IDC_ZTW_WEATHER_CHECK + _forEachIndex)) cbSetChecked true;
            (_display displayCtrl (IDC_ZTW_WEATHER_EDIT + _forEachIndex)) ctrlSetText str _x;
        } forEach ((WEATHER_PRESETS select (_arg - 1)) select 1);
    };
    case "readWeather": {
        {
            (_display displayCtrl (IDC_ZTW_WEATHER_EDIT + _forEachIndex)) ctrlSetText (_x toFixed 2);
        } forEach [overcast, fog, rain, windStr, lightnings, waves];
        [localize "STR_ZTW_StatusReadWeather"] call ztw_fnc_ui_setStatus;
    };

    // ---- 开始 / 停止 ----
    case "start": {
        private _params = call ztw_fnc_ui_readParams;
        if (_params isEqualType "") exitWith {
            [_params, [1, 0.4, 0.4, 1]] call ztw_fnc_ui_setStatus;
        };
        _params params ["_hours", "_duration", "_ease", "_weather"];

        _params call ztw_fnc_transition;

        private _text = if (_hours == 0) then {
            format [localize "STR_ZTW_StatusWeatherOnly", _duration]
        } else {
            format [localize "STR_ZTW_StatusStarted", [dayTime + _hours] call ztw_fnc_formatClock, _duration]
        };
        if (_weather isNotEqualTo []) then {
            _text = _text + localize "STR_ZTW_StatusWithWeather";
        };
        [_text] call ztw_fnc_ui_setStatus;
    };
    case "stop": {
        [-1] call ztw_fnc_transition;
        [localize "STR_ZTW_StatusStopped"] call ztw_fnc_ui_setStatus;
    };
};

[] call ztw_fnc_ui_update;
