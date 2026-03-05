#!/usr/bin/env bash
# Claude Code status line
# Design principles:
#   - Concise multi-line output
#   - Safe ASCII-only separators (no Powerline/Nerd Font glyphs)
#   - Correct ANSI escape sequences
#   - Git caching for performance (5 second TTL)
#   - Adaptive context color: green -> yellow -> red
# Receives JSON on stdin from Claude Code

input=$(cat)

# ---------------------------------------------------------------------------
# ANSI color codes (using $'...' for proper escape interpretation)
# ---------------------------------------------------------------------------
RESET=$'\033[0m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'

# ---------------------------------------------------------------------------
# Extract fields from JSON input
# ---------------------------------------------------------------------------
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
session_name=$(printf '%s' "$input" | jq -r '.session_name // empty')
duration_ms=$(printf '%s' "$input" | jq -r '.cost.total_duration_ms // 0')

# ---------------------------------------------------------------------------
# Shorten home directory to ~
# ---------------------------------------------------------------------------
short_cwd="${cwd/#$HOME/~}"

# ---------------------------------------------------------------------------
# Git caching (5 second TTL)
# ---------------------------------------------------------------------------
CACHE_FILE="/tmp/statusline-git-cache"
CACHE_MAX_AGE=5  # seconds

# Generate cache key based on cwd to handle different repos
CACHE_KEY=$(printf '%s' "$cwd" | md5sum | cut -d' ' -f1 2>/dev/null || printf '%s' "$cwd" | md5 -q 2>/dev/null)
CACHE_FILE="/tmp/statusline-git-cache-${CACHE_KEY}"

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

# Check if we're in a git repo and cache git info
if cache_is_stale; then
    if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git -C "$cwd" \
                     -c core.hooksPath=/dev/null \
                     -c gc.auto=0 \
                     symbolic-ref --short HEAD 2>/dev/null \
                 || git -C "$cwd" \
                        -c core.hooksPath=/dev/null \
                        rev-parse --short HEAD 2>/dev/null)
        staged=$(git -C "$cwd" -c core.hooksPath=/dev/null diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        modified=$(git -C "$cwd" -c core.hooksPath=/dev/null diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        untracked=$(git -C "$cwd" -c core.hooksPath=/dev/null ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        printf '%s|%s|%s|%s\n' "$branch" "$staged" "$modified" "$untracked" > "$CACHE_FILE"
    else
        printf '|||\n' > "$CACHE_FILE"
    fi
fi

# Read from cache
IFS='|' read -r branch staged modified untracked < "$CACHE_FILE"

# Build git display strings
git_branch=""
git_status=""
if [ -n "$branch" ]; then
    git_branch=" ${DIM}(${RESET}${CYAN}git:${branch}${RESET}${DIM})${RESET}"
fi

# Build status string
if [ "$staged" -gt 0 ] 2>/dev/null || [ "$modified" -gt 0 ] 2>/dev/null || [ "$untracked" -gt 0 ] 2>/dev/null; then
    status_parts=""
    if [ "$staged" -gt 0 ] 2>/dev/null; then
        status_parts="${GREEN}+${staged}${RESET}"
    fi
    if [ "$modified" -gt 0 ] 2>/dev/null; then
        if [ -n "$status_parts" ]; then
            status_parts="${status_parts} "
        fi
        status_parts="${status_parts}${YELLOW}~${modified}${RESET}"
    fi
    if [ "$untracked" -gt 0 ] 2>/dev/null; then
        if [ -n "$status_parts" ]; then
            status_parts="${status_parts} "
        fi
        status_parts="${status_parts}${RED}?${untracked}${RESET}"
    fi
    if [ -n "$status_parts" ]; then
        git_status=" ${DIM}[${RESET}${status_parts}${DIM}]${RESET}"
    fi
fi

# ---------------------------------------------------------------------------
# Context usage bar (visual progress bar)
# ---------------------------------------------------------------------------
ctx_info=""
if [ -n "$used_pct" ]; then
    # Truncate to integer safely
    used_int=$(printf '%.0f' "$used_pct" 2>/dev/null || echo "${used_pct%%.*}")

    # Determine bar width (8 characters)
    bar_width=8
    filled=$((used_int * bar_width / 100))

    # Build the bar
    bar=""
    for ((i=0; i<bar_width; i++)); do
        if [ $i -lt $filled ]; then
            bar="${bar}█"
        else
            bar="${bar}░"
        fi
    done

    # Color based on usage level
    if [ "$used_int" -ge 80 ] 2>/dev/null; then
        ctx_bar_color=$'\033[31m'   # red   — critical
    elif [ "$used_int" -ge 50 ] 2>/dev/null; then
        ctx_bar_color=$'\033[33m'   # yellow — moderate
    else
        ctx_bar_color=$'\033[32m'   # green  — comfortable
    fi
    ctx_info=" ${DIM}|${RESET} ${ctx_bar_color}[${bar}] ${used_pct}%${RESET}"
fi

# ---------------------------------------------------------------------------
# Optional: session name (only shown when explicitly set via /rename)
# ---------------------------------------------------------------------------
session_info=""
if [ -n "$session_name" ]; then
    session_info=" ${DIM}[${RESET}${MAGENTA}${session_name}${RESET}${DIM}]${RESET}"
fi

# ---------------------------------------------------------------------------
# Session duration (format as human readable)
# ---------------------------------------------------------------------------
duration_info=""
if [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ] 2>/dev/null; then
    # Convert ms to seconds
    total_sec=$((duration_ms / 1000))
    if [ "$total_sec" -ge 3600 ]; then
        hours=$((total_sec / 3600))
        mins=$(((total_sec % 3600) / 60))
        secs=$((total_sec % 60))
        duration_str="${hours}h ${mins}m ${secs}s"
    elif [ "$total_sec" -ge 60 ]; then
        mins=$((total_sec / 60))
        secs=$((total_sec % 60))
        duration_str="${mins}m ${secs}s"
    else
        duration_str="${total_sec}s"
    fi
    duration_info=" ${DIM}|${RESET} ${CYAN}${duration_str}${RESET}"
fi

# ---------------------------------------------------------------------------
# Assemble and print (multi-line format)
# Line 1: user in dir (git:branch) [status]
# Line 2: model | context | duration [session]
# ---------------------------------------------------------------------------
# Line 1: Location & Git
line1="${BLUE}$(whoami)${RESET} ${DIM}in${RESET} ${YELLOW}${short_cwd}${RESET}${git_branch}${git_status}"

# Line 2: Model, Context, Duration, Session
line2="${MAGENTA}${model}${RESET}${ctx_info}${duration_info}${session_info}"

# Output both lines
printf '%s\n' "$line1"
printf '%s\n' "$line2"