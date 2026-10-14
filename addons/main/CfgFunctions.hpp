class CfgFunctions {
    class PREFIX {
        tag = QUOTE(PREFIX);
        class main {
            file = "\z\ztw\addons\main\functions";
            // 入口 / 权限
            class canOpen {};
            class open {};
            // 时间 / 天气过渡（所有机器执行，见 fn_transition）
            class transition {};
            // 工具
            class formatClock {};
            class parseClock {};
            // 界面
            class ui_onLoad {};
            class ui_onUnload {};
            class ui_action {};
            class ui_update {};
            class ui_readParams {};
            class ui_setStatus {};
        };
    };
};
