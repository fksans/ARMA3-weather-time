// CBA Extended Event Handlers：只在有界面的机器（玩家客户端）初始化
class Extended_PostInit_EventHandlers {
    class ADDON {
        clientInit = "call compileScript ['\z\ztw\addons\main\XEH_postInitClient.sqf']";
    };
};
