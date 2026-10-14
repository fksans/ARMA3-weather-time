#include "..\script_component.hpp"
/*
 * 小时数 -> "HH:MM"（四舍五入到分钟）。
 *
 * Arguments:
 * 0: 小时 <NUMBER>
 * 1: 超过 24 小时时按天折回（时钟时间） <BOOL> (default: true)；false 用于时长，例如 "30:00"
 *
 * Return Value:
 * 文本 <STRING>
 */

params [["_hours", 0, [0]], ["_wrap", true, [true]]];

private _minutes = round (_hours * 60);
if (_wrap) then {
    _minutes = (_minutes % 1440 + 1440) % 1440;
};
_minutes = 0 max _minutes;
private _h = floor (_minutes / 60);
private _m = _minutes % 60;

format ["%1%2:%3%4", ["", "0"] select (_h < 10), _h, ["", "0"] select (_m < 10), _m]
