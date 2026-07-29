# Source cargo env if it exists
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# leo-notebook vault — consumed by pkb-consult/pkb-* skills (NOTEBOOK_PATH)
# Google Drive mounts under CloudStorage on macOS; keep this machine-local.
export NOTEBOOK_PATH="$HOME/Library/CloudStorage/GoogleDrive-leo.minorui@gmail.com/My Drive/Note/leo-notebook"
