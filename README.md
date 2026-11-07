# QQ Web

把 QQ 装进容器，通过浏览器访问和操作。基于 LinuxServer.io 的 [baseimage-selkies](https://github.com/linuxserver/docker-baseimage-selkies)。

> 本项目只是对官方 Linux 版 QQ 的容器化封装，与腾讯公司无关。

## 项目简介

我不喜欢在一个容器里放多个应用的模式，所以为每个应用单独做了只运行这一个应用的容器。

同系列项目：

- [WeChat Web](https://github.com/lycloudqwq/wechat-web)

## 准备 QQ 安装包

QQ 安装包的下载地址会拒绝 curl 等非浏览器的下载请求，所以无法在构建时通过 curl 自动下载，需要自己手动下载安装包：

1. 在浏览器中打开 <https://im.qq.com/index/#/linux>，下载与机器架构对应的 `.deb` 安装包（x64 或 ARM64）。
2. 把安装包放到项目目录下（和 `Dockerfile` 同一个目录），然后二选一：
   - 把本地安装包重命名为 `QQ.deb`；
   - 或者保留原文件名，把 `Dockerfile` 中 `--mount=type=bind,source=QQ.deb` 里的 `QQ.deb` 改成实际的安装包名。

安装包只在构建时临时挂载使用，不会额外占用镜像空间。

## Build

```bash
docker build --pull --no-cache -t qq-web:dev .
```

## Run

```bash
docker run -d --name qq-web --shm-size=1gb -v "/mnt/d/qq:/config" -p IP:3002:3001 --restart unless-stopped qq-web:dev
```

| 参数 | 说明 |
|---|---|
| `--shm-size=1gb` | 共享内存大小，Selkies 官方推荐的设置。 |
| `-v "/mnt/d/qq:/config"` | 持久化 `/config`（容器内用户的主目录）。不要和 WeChat Web 共用同一个目录。 |
| `-p IP:3002:3001` | 把宿主机的 3002 端口映射到容器内的 HTTPS 端口 3001，这样可以和使用 3001 端口的 WeChat Web 同时运行。为了安全，建议只绑定 localhost或局域网 IP，省略 IP 会监听所有网卡。网页默认没有密码，能访问到这个端口的人都可以操作你的 QQ。 |

## 访问

在浏览器中打开 `https://<IP>:3002`，容器使用的是自签名证书，第一次访问时浏览器会提示不安全，确认继续访问即可。

## 关闭 QQ

- 登录后点击 QQ 右上角的关闭按钮，默认只是最小化，而且无法在设置里修改为关闭应用。
- 但是关闭容器可以正常退出 QQ，手机 QQ 顶部的通知也会正常退出：

```bash
docker stop qq-web
```

## 参数说明

以下参数写在 `Dockerfile` 开头的 `ENV` 中，作为镜像的默认值。

### 基础设置

| 参数 | 值 | 说明 |
|---|---|---|
| `LC_ALL` | `zh_CN.UTF-8` | 容器的语言环境，基础镜像会据此自动设置 `LANG` 和 `LANGUAGE`。 |
| `TZ` | `Asia/Shanghai` | 时区，影响消息的时间显示。其他例如 `Asia/Tokyo`。 |
| `PIXELFLUX_WAYLAND` | `true` | 使用 Wayland 模式（labwc 窗口管理器），这是基础镜像目前主推的模式。 |
| `RESTART_APP` | `true` | QQ 进程退出后自动重新启动。 |
| `TITLE` | `QQ` | 浏览器标签页的标题，以及将网页安装为应用（PWA）时的名称。 |

### 安全

| 参数 | 值 | 说明 |
|---|---|---|
| `DISABLE_SUDO` | `true` | 禁用容器内 `abc` 用户的 sudo。 |
| `DISABLE_TERMINALS` | `true` | 禁用终端程序，并把它们从右键菜单中移除。 |
| `SELKIES_ENABLE_SHARING` | `false` | 关闭所有分享功能（分享链接等）。 |
| `SELKIES_COMMAND_ENABLED` | `false` | 禁止网页端向容器发送要执行的命令。基础镜像默认是开启的，所以需要显式关闭。 |

### 窗口

| 参数 | 值 | 说明 |
|---|---|---|
| `NO_DECOR` | `true` | 去掉窗口管理器（labwc）给窗口加的标题栏。 |
| `NO_FULL` | `true` | 不自动最大化窗口，图片查看、文件选择等弹窗按原本大小显示。 |
| `NO_GAMEPAD` | `true` | 关闭手柄支持，不再向进程注入手柄相关的库，同时隐藏手柄面板。 |

### 网页界面

| 参数 | 值 | 说明 |
|---|---|---|
| `SELKIES_UI_LAYOUT` | `wish` | 控制界面使用顶部浮动工具栏样式。 |
| `SELKIES_UI_SHOW_LOGO` | `false` | 隐藏 Selkies 的 logo。 |
| `SELKIES_UI_SIDEBAR_SHOW_APPS` | `false` | 隐藏"应用"（应用安装器）。 |
| `SELKIES_UI_SIDEBAR_SHOW_SHARING` | `false` | 隐藏"分享"。 |
| `SELKIES_UI_SIDEBAR_SHOW_FULLSCREEN` | `false` | 隐藏全屏按钮。 |
| `SELKIES_UI_SIDEBAR_SHOW_GAMING_MODE` | `false` | 隐藏游戏模式按钮。 |
| `SELKIES_UI_SIDEBAR_SHOW_TRACKPAD` | `false` | 隐藏虚拟触控板按钮。 |
| `SELKIES_UI_SIDEBAR_SHOW_KEYBOARD_BUTTON` | `false` | 隐藏屏幕键盘按钮。 |

### 画面

| 参数 | 值 | 说明 |
|---|---|---|
| `SELKIES_MANUAL_WIDTH` | `1920` | 固定分辨率的宽度。设置后分辨率被锁定，网页里不能再修改。 |
| `SELKIES_MANUAL_HEIGHT` | `1080` | 固定分辨率的高度。 |
| `SELKIES_FRAMERATE` | `120` | 初始帧率 120，可以在网页的视频设置里调整（范围 8–240）。 |
| `SELKIES_VIDEO_FULLCOLOR` | `true` | 使用 4:4:4 色度编码，文字边缘更清晰。浏览器不支持时会自动退回 4:2:0。 |

> QQ 在较高的界面缩放（例如 150%）下文字会变得模糊，所以这里把缩放设置为默认的 100%。如果觉得字太小，建议在 QQ 的设置里手动调大字体大小，并且建议在 Dashboard 里关闭本地缩放功能。

### 其他参数

其他参数可以参考 <https://docs.linuxserver.io/selkies/user-guide/configuration/>。
