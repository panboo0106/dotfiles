#!/bin/sh
CONFIG="$HOME/.config/ghostty/config"

# Cycle each run: light -> dark -> follow-system -> (back to light). Reload via SIGUSR2.
AUTO="theme = light:solarized-zen-light,dark:solarized-zen-dark"
LIGHT="theme = solarized-zen-light"
DARK="theme = solarized-zen-dark"

case "$(grep '^theme = ' "$CONFIG")" in
    "theme = light:"*) next="$LIGHT"; label="light" ;;          # follow-system -> light
    "$LIGHT")          next="$DARK";  label="dark" ;;           # light -> dark
    *)                 next="$AUTO";  label="follow-system" ;;  # dark/unknown -> follow-system
esac

sed -i '' "s|^theme = .*|$next|" "$CONFIG"
kill -USR2 $(pgrep -x ghostty) 2>/dev/null
echo "ghostty theme -> $label"
