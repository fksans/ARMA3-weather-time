# Zeus Time & Weather：服务器 key 安装说明（给腐竹）

**Zeus Time & Weather** 是**客户端模组**，只有 Zeus 玩家自己加载。
服务器**不需要**加载它（不要写进 `-mod` / `-serverMod`），只需要信任它的签名 key，
否则开了签名校验的服务器会把加载它的 Zeus 踢掉。

## 1. 拿到 key

找模组作者要 `.bikey` 文件，或者在发布包里找：

```
@zeus_time_weather/keys/ztw.bikey          ← 作者用了固定 key 时的文件名
@zeus_time_weather/keys/ztw_1.0.0.0.bikey  ← 默认方式（每个版本一把 key）时的文件名
```

> `.bikey` 是公钥，可以随便传。**不要**接收也不要索要 `.biprivatekey` / `.hemttprivatekey`，那是作者的私钥。

## 2. 放进服务器的 keys 文件夹

把 `.bikey` 复制到 **Arma 3 服务器根目录**下的 `keys` 文件夹（和 `arma3server_x64.exe` 同级，里面已经有 `a3.bikey`）：

```
Arma 3 Server/
├── arma3server_x64.exe
├── keys/
│   ├── a3.bikey
│   ├── cba_a3.bikey
│   ├── ace_x.y.z.bikey
│   ├── zen_x.y.z.bikey
│   └── ztw.bikey            ← 放这里
└── ...
```

- Linux 服务器同理：`<服务器目录>/keys/`（注意文件名大小写，建议全部小写）。
- 用面板（TCAdmin、Pterodactyl、FASTER、Arma Server Manager 等）的：在面板的 key 管理里上传，或用文件管理器放进同一个 `keys` 目录。

## 3. 确认 server.cfg

```cpp
verifySignatures = 2;   // 一般已经是 2，保持即可
```

不需要改其他配置，也不需要开 `allowedFilePatching`。

## 4. 重启服务器

key 只在服务器启动时读取，**必须重启**（重开任务不够）。

## 5. 验证

- Zeus 带着 `@zeus_time_weather`（+ CBA、ZEN 和服务器模组包）进服，没有被踢 = 成功。
- 如果被踢，服务器 RPT / 控制台里会有类似 `Player XXX: Signature check failed` 或 `wrong signature for file ...ztw_main.pbo` 的日志，说明 key 没放对或服务器没重启。

## 6. 模组更新时

- 作者用的是**固定 key**（文件名 `ztw.bikey`）：什么都不用做。
- 作者用的是**默认方式**（文件名带版本号，如 `ztw_1.1.0.0.bikey`）：每个新版本都要放入新的 `.bikey` 并重启；旧版本的 key 可以删掉（删了以后旧版本模组就进不来了）。

## 7. 服务器需要加载 ZEN

本模组会在服务器上推进时间和天气，用的是 ZEN 的事件通道（和 ZEN 自己的模块用同一条通道），**不受 `CfgRemoteExec` 白名单影响**。服务器的 `-mod` 里本来就有 ZEN 的话什么都不用做；如果服务器没加载 ZEN，时间过渡会在几秒后被服务器同步回去。
