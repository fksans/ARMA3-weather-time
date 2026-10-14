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

#include "ui_defines.hpp"
