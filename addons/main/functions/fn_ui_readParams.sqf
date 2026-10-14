#include "..\script_component.hpp"
/*
 * 读取时间 / 天气过渡界面的设置。
 *
 * Return Value:
 * 成功：[前进小时数 >= 0, 过渡时长（现实秒）1..600, 缓入缓出, 天气目标 [[名称, 0..1], ...]] <ARRAY>
 * 失败：错误提示 <STRING>
 */

private _display = uiNamespace getVariable ["ztw_display", displayNull];
if (isNull _display) exitWith {""};

// ---- 时间 ----
private _hours = 0;
private _error = "";
if (lbCurSel (_display displayCtrl IDC_ZTW_MODE) == 1) then {
    _hours = [ctrlText (_display displayCtrl IDC_ZTW_SKIP_HOURS)] call ztw_fnc_parseClock;
    if (_hours < 0 || _hours > 240) then {
        _error = localize "STR_ZTW_ErrorSkipHours";
    };
} else {
    private _target = [ctrlText (_display displayCtrl IDC_ZTW_TARGET_TIME)] call ztw_fnc_parseClock;
    if (_target < 0 || _target > 24) then {
        _error = localize "STR_ZTW_ErrorTargetTime";
    } else {
        // 只往后走，到下一次出现这个时间；和现在相同（不到半分钟）时不跳时间，只改天气
        _hours = ((_target - dayTime) % 24 + 24) % 24;
        if (_hours < 1 / 120 || _hours > 24 - 1 / 120) then {_hours = 0};
    };
};
if (_error != "") exitWith {_error};

// ---- 过渡时长 / 曲线 ----
private _durationText = trim ctrlText (_display displayCtrl IDC_ZTW_DURATION);
private _duration = parseNumber _durationText;
if (_durationText == "" || _duration < 1 || _duration > 600) exitWith {
    localize "STR_ZTW_ErrorDuration"
};
private _ease = lbCurSel (_display displayCtrl IDC_ZTW_EASE) != 0;

// ---- 天气：只取勾选的项 ----
private _weather = [];
{
    if (cbChecked (_display displayCtrl (IDC_ZTW_WEATHER_CHECK + _forEachIndex))) then {
        private _text = trim ctrlText (_display displayCtrl (IDC_ZTW_WEATHER_EDIT + _forEachIndex));
        private _value = parseNumber _text;
        if (_text == "" || _value < 0 || _value > 1) exitWith {
            _error = format [localize "STR_ZTW_ErrorWeather", localize format ["STR_ZTW_%1", ["Overcast", "Fog", "Rain", "Wind", "Lightnings", "Waves"] select _forEachIndex]];
        };
        _weather pushBack [_x, _value];
    };
    if (_error != "") exitWith {};
} forEach WEATHER_KEYS;
if (_error != "") exitWith {_error};

if (_hours == 0 && _weather isEqualTo []) exitWith {
    localize "STR_ZTW_ErrorNothing"
};

[_hours, _duration, _ease, _weather]
