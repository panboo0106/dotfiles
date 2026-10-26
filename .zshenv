# ============================================
# PATH & Locale — read by EVERY zsh process
# (interactive-only tool init stays in .zshrc, e.g. mise activate)
# ============================================

# Basic PATH setup (~/.local/bin ahead of homebrew so uv's default python3,
# fd, rg win)
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH

# Drop duplicate PATH entries; /etc/paths.d and login shells re-add the same
# directories, so keep the first (highest-priority) occurrence of each.
typeset -U path PATH

# Go bin directory (GOPATH bin, valid regardless of Go manager)
export PATH="$HOME/go/bin:$PATH"

# Local bin - only if exists
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Locale settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Source cargo env if it exists
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# leo-notebook vault — consumed by pkb-consult/pkb-* skills (NOTEBOOK_PATH)
# Google Drive mounts under CloudStorage on macOS; keep this machine-local.
#
# The `:-` is load-bearing, do not "simplify" it away. zsh sources .zshenv for
# EVERY non-interactive shell, so an unconditional assignment here overwrites
# the value in every subprocess — including a test harness that deliberately
# points the pkb-* commands at a fixture vault. That silently aims writes at
# the real, un-versioned notebook. With `:-`, an inherited value wins and the
# real vault stays the default only when nobody asked for anything else.
export NOTEBOOK_PATH="${NOTEBOOK_PATH:-$HOME/Library/CloudStorage/GoogleDrive-leo.minorui@gmail.com/My Drive/Note/leo-notebook}"

# glab CLI — relocate global config to ~/.config (default is
# ~/Library/Application Support/glab-cli). Must stay in .zshenv: non-interactive
# shells (scripts, tool subprocesses) never read .zshrc.
export GLAB_CONFIG_DIR="$HOME/.config/glab-cli"
