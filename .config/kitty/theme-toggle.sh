#!/bin/bash
# Kitty 主题切换脚本 - 实时切换，无需重启

KITTY_CONF="$HOME/.config/kitty/kitty.conf"
THEME_DIR="$HOME/.config/kitty"

case "$1" in
    light)
        # 实时切换颜色 (使用 OSC 转义序列)
        printf '\033]11;#fdf6e3\007'  # 背景
        printf '\033]10;#657b83\007'  # 前景
        printf '\033]12;#657b83\007'  # 光标
        # 更新配置文件
        sed -i.bak 's/include solarized-zen-dark.conf/include solarized-zen-light.conf/' "$KITTY_CONF" 2>/dev/null || \
        sed -i 's/include solarized-zen-dark.conf/include solarized-zen-light.conf/' "$KITTY_CONF"
        echo "已切换到 Light 主题"
        ;;
    dark)
        # 实时切换颜色
        printf '\033]11;#00242c\007'  # 背景
        printf '\033]10;#839395\007'  # 前景
        printf '\033]12;#839395\007'  # 光标
        # 更新配置文件
        sed -i.bak 's/include solarized-zen-light.conf/include solarized-zen-dark.conf/' "$KITTY_CONF" 2>/dev/null || \
        sed -i 's/include solarized-zen-light.conf/include solarized-zen-dark.conf/' "$KITTY_CONF"
        echo "已切换到 Dark 主题"
        ;;
    *)
        echo "用法: $0 {light|dark}"
        exit 1
        ;;
esac
