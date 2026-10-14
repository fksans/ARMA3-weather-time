#include "..\script_component.hpp"
/*
 * 在时间 / 天气过渡界面的标题栏右侧显示一条状态消息。
 *
 * Arguments:
 * 0: 文本 <STRING>
 * 1: 颜色 <ARRAY> (default: 黄色)
 */

params [["_text", "", [""]], ["_color", [1, 0.85, 0.4, 1], [[]], 4]];

private _display = uiNamespace getVariable ["ztw_display", displayNull];
if (isNull _display) exitWith {};

private _ctrl = _display displayCtrl IDC_ZTW_STATUS;
_ctrl ctrlSetText _text;
_ctrl ctrlSetTextColor _color;
