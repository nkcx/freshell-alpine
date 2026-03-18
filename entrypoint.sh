#!/bin/bash
set -e

FRESHELL_DIR="/opt/freshell"
HOME_DIR="/home/coder"
EXTENSIONS_IMPORT="/extensions"
EXTENSIONS_TARGET="${HOME_DIR}/.freshell/extensions"

# --- First-run initialization ---
# When the /home/coder volume is empty (first deploy), seed it with
# the defaults baked into the image. On subsequent starts, the volume
# already has the user's data and this is a no-op.

if [ ! -f "${HOME_DIR}/.bashrc" ]; then
    echo "[etherium] First run detected — initializing home directory..."
    cp /etc/skel/.bashrc "${HOME_DIR}/.bashrc" 2>/dev/null || true
    cp /etc/skel/.profile "${HOME_DIR}/.profile" 2>/dev/null || true
fi

# Ensure SSH directory exists with correct permissions
mkdir -p "${HOME_DIR}/.ssh"
chmod 700 "${HOME_DIR}/.ssh"

# Ensure projects directory exists as a convention
mkdir -p "${HOME_DIR}/projects"

# --- Extension volume support ---
# If an /extensions volume is mounted, copy its contents into the
# freshell extensions directory. This allows injecting extensions
# without conflicting with freshell's own extension management.

if [ -d "${EXTENSIONS_IMPORT}" ] && [ "$(ls -A ${EXTENSIONS_IMPORT} 2>/dev/null)" ]; then
    echo "[etherium] Importing extensions from ${EXTENSIONS_IMPORT}..."
    mkdir -p "${EXTENSIONS_TARGET}"
    cp -rn "${EXTENSIONS_IMPORT}/"* "${EXTENSIONS_TARGET}/" 2>/dev/null || true
fi

# --- Hand off to CMD ---
exec "$@"
