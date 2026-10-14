#include "..\script_component.hpp"
/*
 * "HH:MM" / "H" / "2.5" -> 小时数。
 *
 * Arguments:
 * 0: 文本 <STRING>
 *
 * Return Value:
 * 小时 <NUMBER>，格式不对时为 -1
 */

params [["_text", "", [""]]];

_text = trim _text;
if (_text == "") exitWith {-1};

private _parts = _text splitString ":";
if (count _parts > 2) exitWith {-1};
// 每一段只能有数字和小数点（parseNumber 遇到其他字符会返回 0，看不出是填错了）
if (_parts findIf {(_x splitString "0123456789.") isNotEqualTo []} != -1) exitWith {-1};

private _hours = parseNumber (_parts select 0);
private _minutes = parseNumber (_parts param [1, "0"]);
if (_minutes >= 60) exitWith {-1};

_hours + _minutes / 60
