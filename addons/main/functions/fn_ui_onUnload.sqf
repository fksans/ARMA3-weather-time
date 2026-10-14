#include "..\script_component.hpp"
/*
 * 时间 / 天气过渡界面 onUnload：记住过渡时长、曲线（profileNamespace）和本次输入（uiNamespace）。
 *
 * Arguments:
 * 0: Display <DISPLAY>
 */

params ["_display"];

uiNamespace setVariable ["ztw_lastTarget", ctrlText (_display displayCtrl IDC_ZTW_TARGET_TIME)];
uiNamespace setVariable ["ztw_lastSkip", ctrlText (_display displayCtrl IDC_ZTW_SKIP_HOURS)];

private _duration = parseNumber ctrlText (_display displayCtrl IDC_ZTW_DURATION);
profileNamespace setVariable [PROFILE_DURATION, 1 max _duration min 600];
profileNamespace setVariable [PROFILE_EASE, lbCurSel (_display displayCtrl IDC_ZTW_EASE) != 0];
saveProfileNamespace;

uiNamespace setVariable ["ztw_display", displayNull];
