// Zeus Time & Weather - 时间 / 天气过渡界面
// 使用原版 3DEN 风格控件基类（configFile 根下的 ctrl*），不依赖其他模组的 UI。

class ctrlStatic;
class ctrlStaticBackground;
class ctrlStaticTitle;
class ctrlStructuredText;
class ctrlButton;
class ctrlEdit;
class ctrlCombo;
class ctrlToolbox;
class ctrlCheckbox;

#define TEXT_SIZE QUOTE(POS_H(0.85))
#define TEXT_SIZE_SMALL QUOTE(POS_H(0.75))

class ztw_RscText: ctrlStatic {
    idc = -1;
    sizeEx = TEXT_SIZE;
    h = QUOTE(POS_H(1));
};
class ztw_RscLabel: ztw_RscText {
    style = 1; // ST_RIGHT
};
class ztw_RscButton: ctrlButton {
    idc = -1;
    sizeEx = TEXT_SIZE;
    h = QUOTE(POS_H(1.1));
};
class ztw_RscEdit: ctrlEdit {
    idc = -1;
    sizeEx = TEXT_SIZE;
    h = QUOTE(POS_H(1));
};
class ztw_RscCombo: ctrlCombo {
    idc = -1;
    sizeEx = TEXT_SIZE;
    h = QUOTE(POS_H(1));
};

// 配置里不能写 "2060 + 0" 这样的表达式，idc 用拼接得到：
// 勾选框 206x = IDC_ZTW_WEATHER_CHECK + x，输入框 207x = IDC_ZTW_WEATHER_EDIT + x
#define WEATHER_ROW(INDEX,NAME,COL,ROW_Y) \
    class WeatherCheck##INDEX: ctrlCheckbox { \
        idc = 206##INDEX; \
        tooltip = "$STR_ZTW_WeatherCheckTooltip"; \
        x = QUOTE(POS_X(5.5 + COL * 9.8)); \
        y = QUOTE(POS_Y(ROW_Y)); \
        w = QUOTE(POS_W(1)); \
        h = QUOTE(POS_H(1)); \
    }; \
    class WeatherLabel##INDEX: ztw_RscText { \
        text = NAME; \
        x = QUOTE(POS_X(6.6 + COL * 9.8)); \
        y = QUOTE(POS_Y(ROW_Y)); \
        w = QUOTE(POS_W(4.4)); \
    }; \
    class WeatherEdit##INDEX: ztw_RscEdit { \
        idc = 207##INDEX; \
        tooltip = "$STR_ZTW_WeatherValueTooltip"; \
        x = QUOTE(POS_X(11.1 + COL * 9.8)); \
        y = QUOTE(POS_Y(ROW_Y)); \
        w = QUOTE(POS_W(3)); \
    }

// 窗口左上角 (5, 4)，宽 30
class ztw_display {
    idd = IDD_ZTW;
    movingEnable = 1;
    enableSimulation = 1;
    onLoad = "call ztw_fnc_ui_onLoad";
    onUnload = "call ztw_fnc_ui_onUnload";

    class ControlsBackground {
        class Background: ctrlStaticBackground {
            x = QUOTE(POS_X(5));
            y = QUOTE(POS_Y(5));
            w = QUOTE(POS_W(30));
            h = QUOTE(POS_H(13.2));
            colorBackground[] = {0.08, 0.08, 0.08, 0.95};
        };
    };

    class Controls {
        class Title: ctrlStaticTitle {
            moving = 1;
            text = "$STR_ZTW_Title";
            sizeEx = TEXT_SIZE;
            x = QUOTE(POS_X(5));
            y = QUOTE(POS_Y(4));
            w = QUOTE(POS_W(30));
            h = QUOTE(POS_H(1));
        };
        class Status: ztw_RscText {
            idc = IDC_ZTW_STATUS;
            style = 1;
            sizeEx = TEXT_SIZE_SMALL;
            colorText[] = {1, 0.85, 0.4, 1};
            x = QUOTE(POS_X(13));
            y = QUOTE(POS_Y(4));
            w = QUOTE(POS_W(20.8));
        };
        class Close: ztw_RscButton {
            idc = IDC_ZTW_CLOSE;
            text = "X";
            tooltip = "$STR_ZTW_Close";
            x = QUOTE(POS_X(33.9));
            y = QUOTE(POS_Y(4));
            w = QUOTE(POS_W(1.1));
            h = QUOTE(POS_H(1));
            colorBackground[] = {0, 0, 0, 0};
        };

        // ---- 行 1：现在的时间 / 天气 / 过渡进度 ----
        class Current: ztw_RscText {
            idc = IDC_ZTW_CURRENT;
            sizeEx = TEXT_SIZE_SMALL;
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(5.3));
            w = QUOTE(POS_W(29));
            colorBackground[] = {0, 0, 0, 0.5};
            colorText[] = {0.55, 0.85, 1, 1};
        };

        // ---- 行 2：方式 + 预览 ----
        class Mode: ctrlToolbox {
            idc = IDC_ZTW_MODE;
            sizeEx = TEXT_SIZE;
            rows = 1;
            columns = 2;
            strings[] = {"$STR_ZTW_ModeTarget", "$STR_ZTW_ModeSkip"};
            tooltips[] = {"$STR_ZTW_ModeTargetTooltip", "$STR_ZTW_ModeSkipTooltip"};
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(6.6));
            w = QUOTE(POS_W(12));
            h = QUOTE(POS_H(1.1));
        };
        class Preview: ztw_RscText {
            idc = IDC_ZTW_PREVIEW;
            colorText[] = {1, 0.85, 0.4, 1};
            x = QUOTE(POS_X(17.8));
            y = QUOTE(POS_Y(6.65));
            w = QUOTE(POS_W(16.7));
        };

        // ---- 行 3：目标时间 / 快捷时间 / 前进小时数 ----
        class TargetTimeLabel: ztw_RscLabel {
            text = "$STR_ZTW_TargetTime";
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(7.95));
            w = QUOTE(POS_W(3.6));
        };
        class TargetTime: ztw_RscEdit {
            idc = IDC_ZTW_TARGET_TIME;
            tooltip = "$STR_ZTW_TargetTimeTooltip";
            x = QUOTE(POS_X(9.1));
            y = QUOTE(POS_Y(7.95));
            w = QUOTE(POS_W(3));
        };
        class Sunrise: ztw_RscButton {
            idc = IDC_ZTW_SUNRISE;
            text = "$STR_ZTW_Sunrise";
            tooltip = "$STR_ZTW_SunriseTooltip";
            x = QUOTE(POS_X(12.4));
            y = QUOTE(POS_Y(7.9));
            w = QUOTE(POS_W(3));
        };
        class Noon: ztw_RscButton {
            idc = IDC_ZTW_NOON;
            text = "$STR_ZTW_Noon";
            x = QUOTE(POS_X(15.5));
            y = QUOTE(POS_Y(7.9));
            w = QUOTE(POS_W(3));
        };
        class Sunset: ztw_RscButton {
            idc = IDC_ZTW_SUNSET;
            text = "$STR_ZTW_Sunset";
            tooltip = "$STR_ZTW_SunsetTooltip";
            x = QUOTE(POS_X(18.6));
            y = QUOTE(POS_Y(7.9));
            w = QUOTE(POS_W(3));
        };
        class Midnight: ztw_RscButton {
            idc = IDC_ZTW_MIDNIGHT;
            text = "$STR_ZTW_Midnight";
            x = QUOTE(POS_X(21.7));
            y = QUOTE(POS_Y(7.9));
            w = QUOTE(POS_W(3));
        };
        class SkipHoursLabel: ztw_RscLabel {
            text = "$STR_ZTW_SkipHours";
            x = QUOTE(POS_X(24.8));
            y = QUOTE(POS_Y(7.95));
            w = QUOTE(POS_W(6.4));
        };
        class SkipHours: ztw_RscEdit {
            idc = IDC_ZTW_SKIP_HOURS;
            tooltip = "$STR_ZTW_SkipHoursTooltip";
            x = QUOTE(POS_X(31.3));
            y = QUOTE(POS_Y(7.95));
            w = QUOTE(POS_W(3.2));
        };

        // ---- 行 4：过渡时长 / 曲线 ----
        class DurationLabel: ztw_RscLabel {
            text = "$STR_ZTW_Duration";
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(9.25));
            w = QUOTE(POS_W(6));
        };
        class Duration: ztw_RscEdit {
            idc = IDC_ZTW_DURATION;
            tooltip = "$STR_ZTW_DurationTooltip";
            x = QUOTE(POS_X(11.5));
            y = QUOTE(POS_Y(9.25));
            w = QUOTE(POS_W(3));
        };
        class EaseLabel: ztw_RscLabel {
            text = "$STR_ZTW_Ease";
            x = QUOTE(POS_X(14.8));
            y = QUOTE(POS_Y(9.25));
            w = QUOTE(POS_W(3));
        };
        class Ease: ztw_RscCombo {
            idc = IDC_ZTW_EASE;
            tooltip = "$STR_ZTW_EaseTooltip";
            x = QUOTE(POS_X(17.8));
            y = QUOTE(POS_Y(9.25));
            w = QUOTE(POS_W(6));
        };

        // ---- 行 5：天气标题 / 预设 / 读取当前 ----
        class WeatherTitle: ztw_RscText {
            text = "$STR_ZTW_WeatherTitle";
            tooltip = "$STR_ZTW_WeatherTitleTooltip";
            colorText[] = {0.8, 0.8, 0.8, 1};
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(10.6));
            w = QUOTE(POS_W(13.5));
        };
        class WeatherPresetLabel: ztw_RscLabel {
            text = "$STR_ZTW_WeatherPreset";
            x = QUOTE(POS_X(19));
            y = QUOTE(POS_Y(10.6));
            w = QUOTE(POS_W(2.6));
        };
        class WeatherPreset: ztw_RscCombo {
            idc = IDC_ZTW_WEATHER_PRESET;
            tooltip = "$STR_ZTW_WeatherPresetTooltip";
            x = QUOTE(POS_X(21.6));
            y = QUOTE(POS_Y(10.6));
            w = QUOTE(POS_W(7));
        };
        class ReadWeather: ztw_RscButton {
            idc = IDC_ZTW_READ_WEATHER;
            text = "$STR_ZTW_ReadWeather";
            tooltip = "$STR_ZTW_ReadWeatherTooltip";
            x = QUOTE(POS_X(28.8));
            y = QUOTE(POS_Y(10.55));
            w = QUOTE(POS_W(5.7));
        };

        // ---- 行 6、7：天气项（勾选 = 这一项参与过渡） ----
        WEATHER_ROW(0,"$STR_ZTW_Overcast",0,11.9);
        WEATHER_ROW(1,"$STR_ZTW_Fog",1,11.9);
        WEATHER_ROW(2,"$STR_ZTW_Rain",2,11.9);
        WEATHER_ROW(3,"$STR_ZTW_Wind",0,13.2);
        WEATHER_ROW(4,"$STR_ZTW_Lightnings",1,13.2);
        WEATHER_ROW(5,"$STR_ZTW_Waves",2,13.2);

        // ---- 行 8：提示 ----
        class Hint: ctrlStructuredText {
            idc = IDC_ZTW_HINT;
            size = TEXT_SIZE_SMALL;
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(14.5));
            w = QUOTE(POS_W(29));
            h = QUOTE(POS_H(2.1));
            colorBackground[] = {0, 0, 0, 0};
        };

        // ---- 行 9：开始 / 停止 ----
        class Start: ztw_RscButton {
            idc = IDC_ZTW_START;
            text = "$STR_ZTW_Start";
            tooltip = "$STR_ZTW_StartTooltip";
            x = QUOTE(POS_X(5.5));
            y = QUOTE(POS_Y(16.8));
            w = QUOTE(POS_W(10.4));
            colorBackground[] = {0.75, 0.45, 0.05, 1};
        };
        class Stop: ztw_RscButton {
            idc = IDC_ZTW_STOP;
            text = "$STR_ZTW_Stop";
            tooltip = "$STR_ZTW_StopTooltip";
            x = QUOTE(POS_X(16.1));
            y = QUOTE(POS_Y(16.8));
            w = QUOTE(POS_W(9.2));
            colorBackground[] = {0.6, 0.12, 0.12, 1};
        };
        class ApplyWeather: ztw_RscButton {
            idc = IDC_ZTW_APPLY_WEATHER;
            text = "$STR_ZTW_ApplyWeather";
            tooltip = "$STR_ZTW_ApplyWeatherTooltip";
            x = QUOTE(POS_X(25.5));
            y = QUOTE(POS_Y(16.8));
            w = QUOTE(POS_W(9));
            colorBackground[] = {0.2, 0.45, 0.6, 1};
        };
    };
};
