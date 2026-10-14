#include "..\script_component.hpp"
/*
 * 天气立即生效：所有机器（服务器 + 每位玩家）跳过剩下的天气渐变，直接到达目标天气，
 * 有画面的机器再刷新一次云层画面。天气卡住不变（例如雷暴切晴天后画面仍然漆黑）时使用。
 * forceWeatherChange / simulWeatherSync 都会让画面卡一下。
 * 和 ztw_fnc_transition 一样通过 ZEN 的 "zen_common_execute" 事件发送。
 */

["zen_common_execute", [{
    forceWeatherChange;
    if (hasInterface) then {simulWeatherSync};
}, []]] call CBA_fnc_globalEvent;
