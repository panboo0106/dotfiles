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
