#include "..\script_component.hpp"
/*
 * 当前玩家是否可以打开时间 / 天气过渡界面（必须是 curator）。
 *
 * Return Value:
 * 可以打开 <BOOL>
 */

hasInterface && {!isNull getAssignedCuratorLogic player}
