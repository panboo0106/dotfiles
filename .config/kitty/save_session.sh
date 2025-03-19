kitty_new_shell_hook() {
    # 保存 Kitty 会话
    kitty @ ls > ~/.config/kitty/kitty-dump.json 2>/dev/null || true
    # 检查是否成功保存
    if [ -f ~/.config/kitty/kitty-dump.json ] && [ -s ~/.config/kitty/kitty-dump.json ]; then
        # 转换会话格式
        cat ~/.config/kitty/kitty-dump.json | ~/anaconda3/bin/python  ~/.config/kitty/kitty-convert-dump.py > ~/.config/kitty/kitty-session.kitty
        # 选择下面一种通知方式：
        # 1. 使用 notify-send (Linux桌面环境)
        if command -v notify-send &> /dev/null; then
            notify-send "Kitty Session" "Kitty session saved successfully" --icon=kitty
        # 2. 使用 osascript (macOS)
        elif [ "$(uname)" = "Darwin" ] && command -v terminal-notifier &> /dev/null; then
        terminal-notifier -title "Kitty Session" -message "Kitty session saved successfully"
        # 3. 使用 Kitty 的窗口标题闪烁通知
        elif [ -n "$KITTY_WINDOW_ID" ]; then
            printf "\033]0;Session Saved\007"
            sleep 1
        # 4. 简单的终端输出
        else
            echo "Kitty session saved to ~/.config/kitty-session.kitty"
        fi
    else
        # 保存失败的通知
        echo "Failed to save Kitty session" >&2
    fi
}
kitty_new_shell_hook 
