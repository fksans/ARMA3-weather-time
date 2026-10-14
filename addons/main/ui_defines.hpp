// Zeus Time & Weather - UI IDs & layout helpers

#define IDD_ZTW 191380

#define IDC_ZTW_STATUS 2001
#define IDC_ZTW_CLOSE 2002
#define IDC_ZTW_CURRENT 2010
#define IDC_ZTW_MODE 2020
#define IDC_ZTW_PREVIEW 2021
#define IDC_ZTW_TARGET_TIME 2030
#define IDC_ZTW_SUNRISE 2031
#define IDC_ZTW_NOON 2032
#define IDC_ZTW_SUNSET 2033
#define IDC_ZTW_MIDNIGHT 2034
#define IDC_ZTW_SKIP_HOURS 2035
#define IDC_ZTW_DURATION 2040
#define IDC_ZTW_EASE 2041
#define IDC_ZTW_WEATHER_PRESET 2050
#define IDC_ZTW_READ_WEATHER 2051
// 天气项的勾选框 / 输入框：基础 IDC + 序号（顺序见 WEATHER_KEYS）
#define IDC_ZTW_WEATHER_CHECK 2060
#define IDC_ZTW_WEATHER_EDIT 2070
#define IDC_ZTW_HINT 2080
#define IDC_ZTW_START 2090
#define IDC_ZTW_STOP 2091
#define IDC_ZTW_APPLY_WEATHER 2092

// 40 x 25 居中网格（与原版 GUI_GRID_CENTER 相同）
#define GRID_AREA_W ((safezoneW / safezoneH) min 1.2)
#define GRID_AREA_H (((safezoneW / safezoneH) min 1.2) / 1.2)
#define GRID_W (GRID_AREA_W / 40)
#define GRID_H (GRID_AREA_H / 25)
#define GRID_X (safezoneX + (safezoneW - GRID_AREA_W) / 2)
#define GRID_Y (safezoneY + (safezoneH - GRID_AREA_H) / 2)

#define POS_X(N) ((N) * GRID_W + GRID_X)
#define POS_Y(N) ((N) * GRID_H + GRID_Y)
#define POS_W(N) ((N) * GRID_W)
#define POS_H(N) ((N) * GRID_H)
