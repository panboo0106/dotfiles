#!/bin/bash
# Kitty Session Save/Restore Script

SESSION_FILE="$HOME/.config/kitty/last_session.conf"
KITTY_CONF_DIR="$HOME/.config/kitty"

save_session() {
    echo "# Kitty Session - $(date)" > "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"

    # Get list of tabs and their titles
    kitty @ ls 2>/dev/null | jq -r '.[0].tabs[] | select(.is_focused != true) | .title' 2>/dev/null | while read -r title; do
        if [[ -n "$title" ]]; then
            echo "# Tab: $title" >> "$SESSION_FILE"
            echo "new_tab $title" >> "$SESSION_FILE"
        fi
    done

    echo "Session saved to $SESSION_FILE"
}

restore_session() {
    if [[ ! -f "$SESSION_FILE" ]]; then
        echo "No session file found at $SESSION_FILE"
        exit 1
    fi

    echo "Restoring session from $SESSION_FILE"
    kitty @ load-config "$SESSION_FILE" 2>/dev/null || echo "Note: Session restoration requires kitty remote control"
}

case "$1" in
    save)
        save_session
        ;;
    restore)
        restore_session
        ;;
    *)
        echo "Usage: $0 {save|restore}"
        echo ""
        echo "Save current kitty session (tabs, windows)"
        echo "Restore previously saved session"
        ;;
esac
