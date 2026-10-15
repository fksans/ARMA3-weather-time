#include "..\script_component.hpp"
/*
 * 天气立即生效：所有机器（服务器 + 每位玩家）跳过正在进行的过渡里剩下的天气渐变，直接到达目标，
 * 有画面的机器再刷新一次云层画面。天气卡住不变（例如雷暴切晴天后画面仍然漆黑）时使用。
 * forceWeatherChange / simulWeatherSync 都会让画面卡一下。
 *
 * forceWeatherChange 会把所有天气拉到「预报值」，而引擎在对局中会自己随机改预报（可能是浓雾），
 * 所以先把不属于正在进行的过渡的天气项都锁成当前值；没有过渡在进行时就全部锁住，只刷新画面。
 * 和 ztw_fnc_transition 一样通过 ZEN 的 "zen_common_execute" 事件发送。
 */

["zen_common_execute", [{
    private _fnc_get = WEATHER_FNC_GET;
    private _fnc_set = WEATHER_FNC_SET;
    private _fnc_pinOthers = WEATHER_FNC_PIN_OTHERS;

    private _keep = [];
    if (missionNamespace getVariable ["ztw_token", ""] != "") then {
        _keep = missionNamespace getVariable ["ztw_weather", []];
    };
    _keep call _fnc_pinOthers;
    forceWeatherChange;
    if (hasInterface) then {simulWeatherSync};
}, []]] call CBA_fnc_globalEvent;
