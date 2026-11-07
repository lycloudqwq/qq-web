FROM lsiobase/selkies:debiantrixie

ENV LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    PIXELFLUX_WAYLAND=true \
    RESTART_APP=true \
    DISABLE_SUDO=true \
    DISABLE_TERMINALS=true \
    NO_DECOR=true \
    NO_FULL=true \
    NO_GAMEPAD=true \
    TITLE="QQ" \
    SELKIES_UI_LAYOUT=wish \
    SELKIES_UI_SHOW_LOGO=false \
    SELKIES_UI_SIDEBAR_SHOW_APPS=false \
    SELKIES_UI_SIDEBAR_SHOW_SHARING=false \
    SELKIES_UI_SIDEBAR_SHOW_FULLSCREEN=false \
    SELKIES_UI_SIDEBAR_SHOW_GAMING_MODE=false \
    SELKIES_UI_SIDEBAR_SHOW_TRACKPAD=false \
    SELKIES_UI_SIDEBAR_SHOW_KEYBOARD_BUTTON=false \
    SELKIES_ENABLE_SHARING=false \
    SELKIES_COMMAND_ENABLED=false \
    SELKIES_MANUAL_WIDTH=1920 \
    SELKIES_MANUAL_HEIGHT=1080 \
    SELKIES_FRAMERATE=120 \
    SELKIES_VIDEO_FULLCOLOR=true

RUN --mount=type=bind,source=QQ.deb,target=/tmp/qq.deb \
    set -eu; \
    curl --fail --location \
        --retry 5 --retry-delay 10 --retry-all-errors \
        --connect-timeout 30 \
        --output /usr/share/selkies/www/icon.png \
        "https://static-res.qq.com/static-res/imqq/qq-logo.png"; \
    test -s /usr/share/selkies/www/icon.png; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        /tmp/qq.deb; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    printf '%s\n' \
        '#!/bin/sh' \
        'export QT_QPA_PLATFORM=wayland' \
        '/opt/QQ/qq --no-sandbox' \
        'while pgrep -x qq >/dev/null; do sleep 2; done' \
        > /defaults/autostart_wayland
