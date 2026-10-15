// Zeus Time & Weather - shared macros (config + SQF)
// 不依赖 CBA 的宏头文件，保持构建时无需额外 include。

#include "script_version.hpp"

#define PREFIX ztw
#define COMPONENT main
#define ADDON ztw_main
#define ADDON_PATH \z\ztw\addons\main

#define QUOTE(var) #var
#define DOUBLES(var1,var2) var1##_##var2

// profileNamespace 变量名（统一前缀，避免和其他模组冲突）
#define PROFILE_DURATION "ztw_duration"
#define PROFILE_EASE "ztw_ease"

// 界面上的天气项，顺序和 IDC_ZTW_WEATHER_CHECK / _EDIT 的序号一致
#define WEATHER_KEYS ["overcast", "fog", "rain", "windStr", "lightnings", "waves"]

// 天气预设：[名称, [云量, 雾, 雨, 风力, 闪电, 海浪]]
#define WEATHER_PRESETS [ \
    [localize "STR_ZTW_PresetClear", [0.05, 0, 0, 0.1, 0, 0.1]], \
    [localize "STR_ZTW_PresetCloudy", [0.5, 0, 0, 0.3, 0, 0.3]], \
    [localize "STR_ZTW_PresetOvercast", [0.75, 0.05, 0, 0.4, 0.1, 0.4]], \
    [localize "STR_ZTW_PresetRain", [0.85, 0.08, 0.6, 0.5, 0.2, 0.5]], \
    [localize "STR_ZTW_PresetStorm", [1, 0.1, 1, 0.9, 0.9, 0.9]], \
    [localize "STR_ZTW_PresetFog", [0.4, 0.4, 0, 0.05, 0, 0.1]] \
]

// ---- 天气读写（在其他玩家和服务器上执行，只能用引擎命令） ----
// _x call WEATHER_FNC_GET -> 当前值；[名称, 过渡秒数, 值] call WEATHER_FNC_SET 设定目标（预报）值
#define WEATHER_FNC_GET { \
    switch (_this) do { \
        case "overcast": {overcast}; \
        case "fog": {fog}; \
        case "rain": {rain}; \
        case "windStr": {windStr}; \
        case "lightnings": {lightnings}; \
        case "waves": {waves}; \
        default {0}; \
    }; \
}
#define WEATHER_FNC_SET { \
    params ["_name", "_time", "_value"]; \
    switch (_name) do { \
        case "overcast": {_time setOvercast _value}; \
        case "fog": { \
            fogParams params ["", "_decay", "_base"]; \
            _time setFog [_value, _decay, _base]; \
        }; \
        case "rain": {_time setRain _value}; \
        case "windStr": {_time setWindStr _value}; \
        case "lightnings": {_time setLightnings _value}; \
        case "waves": {_time setWaves _value}; \
    }; \
}
// [要保留的名称...] call WEATHER_FNC_PIN_OTHERS：其余天气项的预报锁成当前值（需要 _fnc_get / _fnc_set）。
// forceWeatherChange 会把所有天气直接拉到预报值，而引擎在对局中会自己随机改预报（对局越久，
// 越可能随机出浓雾）；不先锁住，没勾选的雾也会被拉成浓雾。
#define WEATHER_FNC_PIN_OTHERS { \
    private _keep = _this; \
    { \
        if !(_x in _keep) then {[_x, 0, _x call _fnc_get] call _fnc_set}; \
    } forEach WEATHER_KEYS; \
}

#include "ui_defines.hpp"
