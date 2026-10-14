#include "..\script_component.hpp"
/*
 * 时间 / 天气过渡：让所有机器（服务器 + 每位玩家 + 无头客户端）同时执行同一段过渡代码。
 *
 * 为什么不直接在服务器上 skipTime / setDate：
 * - 服务器一次性跳时间，客户端要等下一次时间同步（几秒一次）才跳过去，画面是"啪"地一下切换；
 * - 天气命令（setOvercast 等）的效果只在本机，体积云又不能瞬间改变，原版只能等很久才看得到。
 * 所以这里在每台机器上用 skipTime 每帧推进一小段时间（太阳、阴影平滑移动），所有机器步调一致，
 * 服务器的同步不会把客户端拉回去。
 *
 * 天气跟着时间轴走：天气（尤其是云）只会随游戏时间的正常流逝变化，每帧一小段的 skipTime 带不动它
 * （实测从雷暴切到晴天，云量几乎不动，画面一直漆黑）。所以天气的过渡时间设成过渡期间实际流逝的
 * 游戏时间（过渡时长 × 时间倍率），天气在这几秒里和太阳一起变；过渡结束时每台机器再执行一次
 * forceWeatherChange，把还没变完的部分直接设到目标值，保证结束时天气一定到位（这一下画面会卡一下）。
 *
 * 其他玩家和服务器没有安装本模组，代码通过 ZEN 的 "zen_common_execute" 事件发送（ZEN 在每台机器上都
 * 注册了这个事件，它自己的「执行代码」模块就用它），不受 CfgRemoteExec 白名单影响，只能用引擎命令。
 * 服务器也必须加载 ZEN，否则服务器时间不变，客户端会被同步回去。
 *
 * Arguments:
 * 0: 前进的小时数 <NUMBER>，0 = 只改天气；小于 0 = 停止正在进行的过渡
 * 1: 过渡时长（现实秒） <NUMBER>
 * 2: 缓入缓出 <BOOL>
 * 3: 天气目标 <ARRAY> [[名称, 0..1], ...]，名称见 WEATHER_KEYS
 *
 * Example:
 * [6, 20, true, [["overcast", 0.8], ["rain", 0.5]]] call ztw_fnc_transition
 * [-1] call ztw_fnc_transition // 停止
 */

params [["_hours", 0, [0]], ["_duration", 20, [0]], ["_ease", true, [true]], ["_weather", [], [[]]]];

private _token = "";
if (_hours >= 0) then {
    _token = format ["%1_%2", diag_tickTime, floor random 1e6];
};

// 这段代码会在其他玩家和服务器上执行，只能用引擎命令，不能调用本模组的函数。
["zen_common_execute", [{
    params ["_token", "_hours", "_duration", "_ease", "_weather"];

    private _fnc_get = {
        switch (_this) do {
            case "overcast": {overcast};
            case "fog": {fog};
            case "rain": {rain};
            case "windStr": {windStr};
            case "lightnings": {lightnings};
            case "waves": {waves};
            default {0};
        };
    };
    private _fnc_set = {
        params ["_name", "_time", "_value"];
        switch (_name) do {
            case "overcast": {_time setOvercast _value};
            case "fog": {
                // 保留任务设置的雾衰减 / 雾高度，只改浓度
                fogParams params ["", "_decay", "_base"];
                _time setFog [_value, _decay, _base];
            };
            case "rain": {_time setRain _value};
            case "windStr": {_time setWindStr _value};
            case "lightnings": {_time setLightnings _value};
            case "waves": {_time setWaves _value};
        };
    };

    // 上一次过渡还没结束：把它的天气目标改成当前值，停在这里（否则会继续慢慢变过去）
    if (missionNamespace getVariable ["ztw_token", ""] != "") then {
        {
            [_x, 1, _x call _fnc_get] call _fnc_set;
        } forEach (missionNamespace getVariable ["ztw_weather", []]);
    };

    // 每帧的处理器发现 token 变了就会自己移除
    missionNamespace setVariable ["ztw_token", _token];
    missionNamespace setVariable ["ztw_weather", _weather apply {_x select 0}];
    if (_token == "") exitWith {};
    missionNamespace setVariable ["ztw_progress", 0];
    // 已经跳过的小时数。不放在 _thisArgs 里：不依赖引擎每帧传进来的是不是同一个数组
    missionNamespace setVariable ["ztw_applied", 0];

    // 天气的过渡时间：过渡期间正常流逝的游戏时间（秒）。skipTime 跳过的时间不算，见文件开头
    private _transition = 1 max (_duration * timeMultiplier);
    {
        _x params ["_name", "_value"];
        [_name, _transition, _value] call _fnc_set;
    } forEach _weather;

    addMissionEventHandler ["EachFrame", {
        _thisArgs params ["_token", "_hours", "_duration", "_ease", "_start", "_forceWeather"];
        if (missionNamespace getVariable ["ztw_token", ""] != _token) exitWith {
            removeMissionEventHandler [_thisEvent, _thisEventHandler];
        };

        private _progress = 1 min ((diag_tickTime - _start) / _duration);
        missionNamespace setVariable ["ztw_progress", _progress];
        if (_ease) then {
            _progress = _progress * _progress * (3 - 2 * _progress);
        };

        // 按进度算出"到现在应该一共跳过多少"，减去已经跳过的，误差不会累积；最后一帧正好补齐
        private _step = _hours * _progress - (missionNamespace getVariable ["ztw_applied", 0]);
        if (_step > 0) then {
            skipTime _step;
            missionNamespace setVariable ["ztw_applied", _hours * _progress];
        };

        if (_progress >= 1) then {
            // 天气直接到位，并让云层画面跟上
            if (_forceWeather) then {
                forceWeatherChange;
                if (hasInterface) then {simulWeatherSync};
            };
            missionNamespace setVariable ["ztw_token", ""];
            removeMissionEventHandler [_thisEvent, _thisEventHandler];
        };
    }, [_token, _hours, 1 max _duration, _ease, diag_tickTime, _weather isNotEqualTo []]];
}, [_token, 0 max _hours, _duration, _ease, _weather]]] call CBA_fnc_globalEvent;

_token
