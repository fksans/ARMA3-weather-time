#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "Zeus Time & Weather";
        author = "fksans";
        url = "https://github.com/fksans/ARMA3-weather-time";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.18;
        requiredAddons[] = {
            "cba_main",
            "zen_main",
            "zen_common",
            "zen_context_menu",
            "zen_custom_modules"
        };
        version = QUOTE(MAJOR.MINOR.PATCH.BUILD);
        versionStr = QUOTE(MAJOR.MINOR.PATCH.BUILD);
        versionAr[] = {MAJOR, MINOR, PATCH, BUILD};
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgFunctions.hpp"
#include "gui.hpp"
