# Zeus Time & Weather（Zeus 时间天气）

给 Arma 3 Zeus 用的**平滑时间跳过 + 天气渐变**工具，**客户端模组**：只有 Zeus 自己加载，其他玩家和服务器都不用装（服务器需要加载 ZEN）。

原版 / ZEN 改时间是一下子 `setDate` 过去，画面直接跳变；改天气要等很久才看得出来，体积云又不能立刻改变。这个模组把它们换成一段「延时摄影」式的过渡，天气跟着同一条时间轴一起变。

- 依赖：**CBA_A3**、**ZEN (Zeus Enhanced)**（写在 `requiredAddons` 里）。

## 功能

| 功能 | 说明 |
| --- | --- |
| 到指定时间 | 例如 18:30，只往后走，到下一次出现这个时间。快捷按钮：日出 / 正午 / 日落 / 午夜，日出日落按当前地图纬度和日期计算（`BIS_fnc_sunriseSunsetTime`）。 |
| 前进时长 | 往后走 N 小时（例如 2.5 或 2:30），可以超过 24 小时，最多 240 小时。 |
| 过渡时长 | 现实中用几秒走完（1–600 秒）。比如跳 12 小时、用 20 秒，太阳会在 20 秒内平滑地划过天空。 |
| 曲线 | 匀速，或缓入缓出（开头结尾慢、中间快，默认）。 |
| 天气跟着时间轴走 | 勾选云量 / 雾 / 雨 / 风力 / 闪电 / 海浪并填目标值（0–1），它们在过渡时长内和时间一起渐变，**过渡结束时直接到达目标**（结束那一下画面会卡一下）。没勾选的项不变。 |
| 天气预设 | 晴朗 / 多云 / 阴天 / 下雨 / 暴风雨 / 晨雾，选了会填好并勾选全部天气项。「读取当前」把现在的天气填进去。 |
| 只改天气 | 时间填成现在（或前进 0 小时），天气在设定的秒数内渐变，结束时同样直接到达目标。 |
| 停止过渡 | 时间和天气停在当时的样子。新的过渡会直接取代正在进行的过渡。 |
| 天气立即生效 | 过渡进行中：所有人（包括服务器）跳过剩下的天气渐变，勾选的项马上到达目标。没有过渡在进行时：天气保持现在的值，只刷新云层画面。都会卡一下。云的画面卡住、换成晴天后画面还是漆黑时用。 |
| 权限 | 只有当前玩家是 curator（`getAssignedCuratorLogic player` 非空）时才能打开；打开期间被收回 Zeus 会自动关闭。 |

### 三个入口

1. **ZEN 模块**：Zeus 模块列表 → 分类「时间天气」→「时间 / 天气过渡」（`zen_custom_modules_fnc_register`）。
2. **ZEN 右键菜单**：Zeus 界面里右键 →「时间 / 天气过渡」（`zen_context_menu_fnc_addAction`）。
3. **快捷键**：默认 `Ctrl + Shift + T`（`CBA_fnc_addKeybind`），可在 *设置 → 控制 → 插件设置（Configure Addons）→ Zeus Time & Weather* 里改。

在 Zeus 界面（display 312）中打开时，窗口作为 312 的子 display 弹出，Zeus 界面保持打开，关掉窗口（`X` 或 `Esc`）就回到 Zeus。

### 界面

```
┌ 时间 / 天气过渡 ─────────────────────── [状态消息]  X ┐
│ 现在 05:32 · 云 0.30 · 雾 0.00 · 雨 0.00 · ... · 过渡中 45% │
│ [ 到指定时间 | 前进时长 ]     05:32 → 18:30（+12:58，20 秒） │
│ 目标时间 [18:30] [日出][正午][日落][午夜]  前进(小时) [1]   │
│ 过渡时长(秒) [20]  曲线 [缓入缓出 ▼]                         │
│ 天气（跟着时间轴一起渐变）   预设 [选择预设… ▼] [读取当前]  │
│ ☑ 云量 [0.80]   ☐ 雾 [0.00]     ☑ 雨 [0.60]                  │
│ ☐ 风力 [0.20]   ☐ 闪电 [0.00]   ☐ 海浪 [0.20]                │
│ 提示 ...                                                     │
│ [    开始过渡    ] [   停止过渡   ] [  天气立即生效  ]       │
└──────────────────────────────────────────────────────────────┘
```

界面文字跟随游戏语言：中文显示中文，英文游戏显示英文，其他语言默认中文。

### 存储（profileNamespace）

| 变量 | 内容 |
| --- | --- |
| `ztw_duration` | 上次使用的过渡时长 |
| `ztw_ease` | 上次是否使用缓入缓出 |

## 原理

- **时间**：其他玩家没有安装本模组，过渡代码通过 ZEN 的 `zen_common_execute` 事件（`CBA_fnc_globalEvent`）发给**所有机器（服务器 + 每位玩家）**，ZEN 自己的「执行代码」模块用的就是这条通道，不受 `CfgRemoteExec` 白名单影响。每台机器每帧用 `skipTime` 推进一小段，按「进度 × 总时长 − 已经跳过的」计算，最后一帧正好补齐，误差不累积。所有机器步调一致，服务器的时间同步不会把客户端拉回去，所以看到的是太阳平滑移动，而不是隔几秒跳一下。
- **天气**：天气（尤其是云）只会随游戏时间的正常流逝变化，每帧一小段的 `skipTime` 带不动它（1.0.0 就是这样：夜里切雷暴后再跳到白天晴朗，云量几乎不动，画面一直漆黑）。所以天气命令（`setOvercast` / `setFog` / `setRain` / `setWindStr` / `setLightnings` / `setWaves`）的过渡时间设成过渡期间实际流逝的游戏时间（过渡时长 × 时间倍率），天气在这几秒里和太阳一起变；过渡结束时每台机器再执行一次 `forceWeatherChange`，把还没变完的部分直接设到目标值，并用 `simulWeatherSync` 刷新云层画面。`forceWeatherChange` 会把**所有**天气拉到「预报值」，而引擎在对局中会自己随机改预报，对局开得久了可能随机出浓雾（1.0.1 就会这样：跳时间后整张地图浓雾，按「天气立即生效」也回不去）。所以每次执行前，先把没勾选的项的预报锁成当前值，只让勾选的项变化。天气命令的效果只在本机，所以同样在每台机器上执行。雾只改浓度，保留任务设置的雾衰减和高度。

### 注意事项

- **服务器也要加载 ZEN**（一般都会）。服务器上没有 ZEN 时服务器时间不变，客户端过几秒就会被同步回去。
- 过渡进行中才进服的玩家只会收到服务器的时间同步，会看到几次跳变。
- 云量较低时引擎可能不下雨。
- 过渡结束时（勾选了天气才会）和点「天气立即生效」时，画面会卡一下，这是引擎刷新天气和云层的代价。
- **不会污染任务**：本模组不添加任何可放置对象（模块通过 ZEN 的自定义模块注册），用它的 Zeus 保存的任务不会依赖本模组。

## 项目结构（HEMTT）

```
.
├── .hemtt/
│   ├── project.toml            # HEMTT 项目配置（name / prefix / 版本 / release 目录 / 签名）
│   └── launch.toml             # hemtt launch 用的 CBA / ZEN / ACE 创意工坊 ID
├── addons/
│   └── main/                   # → ztw_main.pbo
│       ├── $PBOPREFIX$         # z\ztw\addons\main
│       ├── config.cpp          # CfgPatches（requiredAddons: cba_main, zen_*）
│       ├── CfgEventHandlers.hpp# CBA XEH：clientInit
│       ├── CfgFunctions.hpp    # ztw_fnc_*
│       ├── gui.hpp             # 界面 ztw_display
│       ├── script_component.hpp# 宏、天气项、天气预设
│       ├── script_version.hpp  # 版本号（HEMTT 读取）
│       ├── ui_defines.hpp      # IDD / IDC / 网格宏
│       ├── stringtable.xml     # 中文（默认）+ 英文
│       ├── XEH_postInitClient.sqf   # 注册 ZEN 模块、右键菜单、CBA 快捷键
│       └── functions/
│           ├── fn_canOpen.sqf           # 是否为 curator
│           ├── fn_open.sqf              # 打开（312 子 display / dialog）
│           ├── fn_transition.sqf        # 过渡本体：所有机器每帧 skipTime，天气在过渡时长内渐变、结束时到位
│           ├── fn_applyWeatherNow.sqf   # 天气立即生效（forceWeatherChange + simulWeatherSync）
│           ├── fn_formatClock.sqf / fn_parseClock.sqf
│           └── fn_ui_*.sqf              # 界面逻辑
├── .github/workflows/
│   └── build.yml               # CI：PR 检查 + 打标签自动发布到 GitHub Releases
├── docs/
│   └── SERVER_KEY_INSTALL.md   # 给服务器腐竹的 key 安装说明
├── mod.cpp
└── README.md
```

## 构建

### 1. 安装 HEMTT

需要 HEMTT **1.22.0 或更新**（固定签名 key 的 `hemtt keys` 命令需要较新版本）。

- Windows：`winget install hemtt`（更新：`winget upgrade hemtt`），或从 <https://github.com/BrettMayson/HEMTT/releases> 下载 `hemtt.exe` 放到仓库根目录 / PATH 中。
- Linux：`curl -sSf https://hemtt.dev/install.sh | sh`

```sh
hemtt --version
```

### 2. 常用命令（在仓库根目录执行）

| 命令 | 作用 |
| --- | --- |
| `hemtt check` | 只做检查（配置、SQF、stringtable lint），不输出文件。加 `-p` 运行全部严格检查。 |
| `hemtt dev` | 快速开发构建到 `.hemttout/dev`（不签名），配合 `-filePatching` 调试。 |
| `hemtt launch` | 开发构建并直接启动游戏，自动加载 `.hemtt/launch.toml` 里配置的 CBA + ZEN（`hemtt launch ace` 再加 ACE3）。 |
| `hemtt build` | 正式构建到 `.hemttout/build`，不签名。 |
| `hemtt release` | 正式构建 + **签名** + 打包 zip。 |

### 3. 发布（签名）

```sh
hemtt release
```

输出：

```
.hemttout/release/                     # 即 @zeus_time_weather 的内容
├── addons/
│   ├── ztw_main.pbo
│   └── ztw_main.pbo.<authority>.bisign
├── keys/
│   └── <authority>.bikey              # 交给服务器
├── mod.cpp
└── README.md
releases/
├── ztw-<版本>.zip                     # 解压后为 @zeus_time_weather/
└── ztw-latest.zip
```

Zeus 玩家把 `@zeus_time_weather` 放进游戏目录（或做成创意工坊物品），在启动器里和 CBA、ZEN 一起作为本地模组加载即可。

### 4. 签名与 key

HEMTT 有两种签名方式，二选一：

**A. 默认：每个版本一把新 key（零配置）**

`hemtt release` 每次随机生成私钥签名后就丢弃，authority 为 `ztw_<版本号>`，例如 `ztw_1.0.0.0.bikey`。
私钥从不落盘，最安全；但**每发一个新版本，服务器都要换一次 `.bikey`**（旧 key 可以删掉）。

**B. 推荐：固定 key（服务器只装一次）**

1. 在仓库根目录执行（只做一次）：

   ```sh
   hemtt keys generate
   ```

   - 按提示确认，HEMTT 会生成 `ztw.hemttprivatekey`（已加密）并显示一串**密码，只显示一次**，请存进密码管理器。
   - `*.hemttprivatekey` 已经在 `.gitignore` 里，**绝对不要提交、不要发给任何人**。请另外备份这个文件和密码，丢了只能换新 key。
   - 这把 key 绑定本项目（name / prefix / 仓库第一个提交）。

2. 把命令最后输出的那一行填进 `.hemtt/project.toml`（文件末尾已留好注释模板）：

   ```toml
   [signing]
   private_key_hash = "……"
   ```

3. 之后每次 `hemtt release` 都会提示输入密码，用同一把 key 签名，生成的 key 固定为 `keys/ztw.bikey`。
   发新版本时服务器不需要做任何改动。

> 固定私钥只能在本地使用：HEMTT 检测到 CI 环境时会拒绝使用私钥文件。
> 所以选了 B 之后，下面的「自动打包发布」会在 `hemtt release` 这一步失败，需要改成本地 `hemtt release`，再把 zip 和 `.bikey` 手动传到 GitHub Releases。

### 5. 改版本号

修改 `addons/main/script_version.hpp` 里的 `MAJOR / MINOR / PATCH / BUILD`。

### 6. 自动打包发布（GitHub Actions）

`.github/workflows/build.yml` 做两件事：

- **推到 main / 提 PR**：运行 `hemtt check`，有错误会在 PR 上标红。
- **推 `v*` 标签，或在 Actions 页面手动运行**：运行 `hemtt release` 构建并签名，然后在 GitHub **Releases** 页面创建一个版本，附上两个文件：
  - `ztw-<版本>.zip`：给 Zeus 玩家下载，解压就是 `@zeus_time_weather`
  - `ztw_<版本>.bikey`：给服务器腐竹

发新版本有两种方式。

**方式一：网页上点按钮（最简单）**

1. 改 `addons/main/script_version.hpp` 里的版本号，比如改成 `1.0.1`，提交并推到 main。
2. 打开仓库的 **Actions** 页签 → 左侧选 **Build** → 右侧点 **Run workflow** → 分支选 `main` → 点绿色的 **Run workflow**。
3. 等几分钟，工作流会自动创建 `v1.0.1` 标签和 Release。如果这个版本号已经发布过，会直接报错，提醒你先改版本号。

**方式二：自己打标签**

1. 改 `addons/main/script_version.hpp` 里的版本号，比如改成 `1.0.1`，提交并推到 main。
2. 打一个**和版本号一致**的标签并推上去：

   ```sh
   git tag v1.0.1
   git push origin v1.0.1
   ```

   也可以在 GitHub 网页上操作：Releases → Draft a new release → 标签填 `v1.0.1`（选 main）→ Publish release。标签推上去后 Actions 会自动把 zip 和 `.bikey` 加到这个 Release 里。
3. 等 Actions 跑完（仓库的 Actions 页面能看到进度），Releases 页面就会出现新版本。

- 标签必须和 `script_version.hpp` 的 `MAJOR.MINOR.PATCH` 一致（`v1.0.1` 对应 `1.0.1`），不一致时工作流会直接报错，不会发出版本号对不上的包。
- CI 里用的是默认签名方式 A：**每个版本的 `.bikey` 都不同**，更新版本后要把新的 `.bikey` 发给腐竹。

## 给服务器腐竹

见 [docs/SERVER_KEY_INSTALL.md](docs/SERVER_KEY_INSTALL.md)。简要：把 `.bikey` 放进服务器的 `keys` 文件夹并重启，服务器**不需要**加载本模组，但需要加载 ZEN。
