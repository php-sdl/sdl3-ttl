#!/bin/bash

# Debian/Ubuntu installer for the sdl3ttf Zephir extension.
# - Installs SDL3 and SDL3_ttf dev headers (distro pkg or source build)
# - Detects PHP extension dir dynamically
# - Enables extension for available SAPIs
# - Finds Zephir automatically or respects $ZEPHIR_BIN

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSION_NAME="sdl3ttf"
BUILD_SO="${SCRIPT_DIR}/ext/modules/${EXTENSION_NAME}.so"
LOG_FILE="${SCRIPT_DIR}/build.log"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

die() {
    echo ""
    echo "❌ $*"
    exit 1
}

require_cmd() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
}

header() {
    echo "=========================================="
    echo "SDL3_ttf Extension Installer (Debian/Ubuntu)"
    echo "=========================================="
    echo ""
}

step() {
    echo "$*"
}

ok() {
    echo "   ✓ $*"
}

show_failure_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo "---- Last 80 lines of ${LOG_FILE} ----"
        tail -80 "$LOG_FILE" || true
    fi
    if [ -f "${SCRIPT_DIR}/compile-errors.log" ]; then
        echo ""
        echo "---- Last 120 lines of compile-errors.log ----"
        tail -120 "${SCRIPT_DIR}/compile-errors.log" || true
    fi
}

should_retry_for_stale_paths() {
    [ -f "${SCRIPT_DIR}/compile-errors.log" ] || return 1

    if grep -q "No rule to make target '.*/Volumes/" "${SCRIPT_DIR}/compile-errors.log" 2>/dev/null; then
        return 0
    fi

    if [ -f "${SCRIPT_DIR}/ext/Makefile" ] && grep -q "/Volumes/ProjectSaturnStudios" "${SCRIPT_DIR}/ext/Makefile" 2>/dev/null; then
        return 0
    fi

    return 1
}

purge_generated_ext_artifacts() {
    step "🧼 Purging generated ext build artifacts..."
    rm -rf "${SCRIPT_DIR}/ext"
    rm -f "${SCRIPT_DIR}/compile-errors.log" "${SCRIPT_DIR}/compile.log" "${SCRIPT_DIR}/build.log"
    ok "Removed stale generated files"
}

run_build_or_recover_once() {
    if "$ZEPHIR" build >>"$LOG_FILE" 2>&1 && [ -f "$BUILD_SO" ]; then
        return 0
    fi

    if should_retry_for_stale_paths; then
        step "Detected stale host paths in generated build files. Retrying with a fresh ext tree..."
        purge_generated_ext_artifacts

        if ! "$ZEPHIR" fullclean >"$LOG_FILE" 2>&1; then
            show_failure_logs
            return 1
        fi

        if "$ZEPHIR" build >>"$LOG_FILE" 2>&1 && [ -f "$BUILD_SO" ]; then
            ok "Recovered from stale path build metadata"
            return 0
        fi
    fi

    return 1
}

ensure_sdl3_debian() {
    step "📚 Checking SDL3 dependency..."

    if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists sdl3 2>/dev/null; then
        ok "SDL3 detected via pkg-config ($(pkg-config --modversion sdl3))"
        return
    fi

    step "   SDL3 not detected. Installing..."
    require_cmd apt-get
    $SUDO apt-get update -q

    if $SUDO apt-get install -y pkg-config libsdl3-dev; then
        :
    else
        step "   libsdl3-dev unavailable; building SDL3 from source..."
        $SUDO apt-get install -y pkg-config build-essential cmake git || die "Failed to install SDL3 build prerequisites."
        TMP_DIR="$(mktemp -d)"
        trap 'rm -rf "$TMP_DIR"' EXIT
        git clone --branch release-3.x --depth 1 https://github.com/libsdl-org/SDL "$TMP_DIR/SDL" || die "Failed to clone SDL3."
        cmake -S "$TMP_DIR/SDL" -B "$TMP_DIR/SDL/build" -DCMAKE_BUILD_TYPE=Release || die "SDL3 cmake configure failed."
        cmake --build "$TMP_DIR/SDL/build" -j"$(nproc)" || die "SDL3 build failed."
        $SUDO cmake --install "$TMP_DIR/SDL/build" || die "SDL3 install failed."
        $SUDO ldconfig || true
        export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    fi

    pkg-config --exists sdl3 2>/dev/null || die "SDL3 still not detected after install/build."
    ok "SDL3 ready ($(pkg-config --modversion sdl3))"
}

ensure_sdl3_ttf_debian() {
    step "📚 Checking SDL3_ttf dependency..."

    _sdl3ttf_detect() {
        command -v pkg-config >/dev/null 2>&1 || return 1
        for _cand in SDL3_ttf sdl3-ttf sdl3_ttf; do
            pkg-config --exists "$_cand" 2>/dev/null && echo "$_cand" && return 0
        done
        return 1
    }

    local pc_name
    if pc_name="$(_sdl3ttf_detect)"; then
        ok "SDL3_ttf detected via pkg-config (${pc_name})"
        return
    fi

    step "   SDL3_ttf not detected. Installing..."
    require_cmd apt-get
    $SUDO apt-get update -q

    if $SUDO apt-get install -y libsdl3-ttf-dev; then
        :
    else
        step "   libsdl3-ttf-dev unavailable; building SDL3_ttf from source..."
        $SUDO apt-get install -y pkg-config build-essential cmake git || die "Failed to install SDL3_ttf build prerequisites."
        TMP_TTF_DIR="$(mktemp -d)"
        trap 'rm -rf "$TMP_TTF_DIR"' EXIT
        git clone --branch main --depth 1 https://github.com/libsdl-org/SDL_ttf "$TMP_TTF_DIR/SDL_ttf" || die "Failed to clone SDL_ttf."
        cmake -S "$TMP_TTF_DIR/SDL_ttf" -B "$TMP_TTF_DIR/SDL_ttf/build" \
            -DCMAKE_BUILD_TYPE=Release \
            -DSDLTTF_VENDORED=ON \
            -DSDLTTF_SAMPLES=OFF \
            || die "SDL3_ttf cmake configure failed."
        cmake --build "$TMP_TTF_DIR/SDL_ttf/build" -j"$(nproc)" || die "SDL3_ttf build failed."
        $SUDO cmake --install "$TMP_TTF_DIR/SDL_ttf/build" || die "SDL3_ttf install failed."
        $SUDO ldconfig || true
        export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    fi

    if pc_name="$(_sdl3ttf_detect)"; then
        ok "SDL3_ttf ready (${pc_name})"
        return
    fi

    die "SDL3_ttf still not detected after install/build."
}

header

# Preflight
step "🔎 Preflight checks..."
require_cmd php
require_cmd php-config

# Resolve Zephir
if [ -n "${ZEPHIR_BIN:-}" ]; then
    ZEPHIR="$ZEPHIR_BIN"
elif command -v zephir >/dev/null 2>&1; then
    ZEPHIR="$(command -v zephir)"
elif [ -x "$HOME/.config/composer/vendor/bin/zephir" ]; then
    ZEPHIR="$HOME/.config/composer/vendor/bin/zephir"
else
    die "Zephir not found. Install via: composer global require phalcon/zephir  (or set ZEPHIR_BIN)"
fi
ok "Found zephir: $ZEPHIR"

ensure_sdl3_debian
ensure_sdl3_ttf_debian

# Avoid noisy locale fallback warnings on minimal Debian images.
if command -v locale >/dev/null 2>&1 && locale -a 2>/dev/null | grep -qi '^c\.utf-8$'; then
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
else
    export LC_ALL=C
    export LANG=C
fi

PHP_VER_MM="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"
PHP_VER_NN="$(php -r 'echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;')"

PHP_BIN_REAL="$(php -r 'echo PHP_BINARY;' 2>/dev/null)"
PHP_BIN_DIR="$(dirname "$PHP_BIN_REAL")"
RESOLVED_PHP_CONFIG="${PHP_BIN_DIR}/php-config"

if [ -x "$RESOLVED_PHP_CONFIG" ]; then
    PHP_EXT_DIR="$("$RESOLVED_PHP_CONFIG" --extension-dir)"
elif command -v php-config >/dev/null 2>&1; then
    PHP_EXT_DIR="$(php-config --extension-dir)"
else
    die "Could not locate php-config. Install it or set PHP_EXT_DIR manually."
fi
[ -n "$PHP_EXT_DIR" ] || die "Could not determine PHP extension dir."

CLI_SCAN_DIR="$(php --ini 2>/dev/null | awk -F': ' '/Scan for additional \.ini files in:/{print $2}' || true)"
if [ -n "$CLI_SCAN_DIR" ] && [ -d "$CLI_SCAN_DIR" ] && ls "$CLI_SCAN_DIR"/*.so >/dev/null 2>&1; then
    PHP_EXT_DIR="$CLI_SCAN_DIR"
fi

ok "PHP version: ${PHP_VER_MM}"
ok "PHP binary:  ${PHP_BIN_REAL}"
ok "Ext dir:     ${PHP_EXT_DIR}"

# GCC 14+ (Debian Trixie, Ubuntu 24.10+) promotes -Wincompatible-pointer-types
# to a hard error. Zephir-generated code has benign mismatches — demote to warnings.
export CFLAGS="${CFLAGS:-} -Wno-error -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-pointer-compare"
export CPPFLAGS="${CPPFLAGS:-} -Wno-error -Wno-error=incompatible-pointer-types"
echo ""

# Clean previous build
step "🧹 Cleaning previous build..."
cd "${SCRIPT_DIR}"
if ! "$ZEPHIR" fullclean >"$LOG_FILE" 2>&1; then
    tail -50 "$LOG_FILE" || true
    die "Clean failed. See ${LOG_FILE}."
fi
ok "Clean complete"
echo ""

# Build
step "🔨 Building extension..."
if ! run_build_or_recover_once; then
    show_failure_logs
    die "Build failed or output not found at ${BUILD_SO}."
fi
ok "Build complete"
echo ""

# Install .so
step "📦 Installing binary..."
$SUDO mkdir -p "$PHP_EXT_DIR"
$SUDO cp -f "$BUILD_SO" "${PHP_EXT_DIR}/${EXTENSION_NAME}.so"
$SUDO chmod 755 "${PHP_EXT_DIR}/${EXTENSION_NAME}.so"
ok "Copied to: ${PHP_EXT_DIR}/${EXTENSION_NAME}.so"
echo ""

# Enable extension across detected SAPIs
step "⚙️  Enabling extension..."
declare -a CONF_DIR_CANDIDATES=()

if [ -n "$CLI_SCAN_DIR" ] && [ "$CLI_SCAN_DIR" != "(none)" ] && [ -d "$CLI_SCAN_DIR" ]; then
    CONF_DIR_CANDIDATES+=("$CLI_SCAN_DIR")
fi

for d in "/etc/php/${PHP_VER_MM}/cli/conf.d" "/etc/php/${PHP_VER_MM}/fpm/conf.d" "/etc/php/${PHP_VER_MM}/apache2/conf.d"; do
    [ -d "$d" ] && CONF_DIR_CANDIDATES+=("$d")
done

ALPINE_CONF="/etc/php${PHP_VER_NN}/conf.d"
[ -d "$ALPINE_CONF" ] && CONF_DIR_CANDIDATES+=("$ALPINE_CONF")

for d in "/etc/php-fpm.d" "/etc/php-fpm/conf.d"; do
    [ -d "$d" ] && CONF_DIR_CANDIDATES+=("$d")
done

CONF_DIRS=()
while IFS= read -r _line; do
    CONF_DIRS+=("$_line")
done < <(printf "%s\n" "${CONF_DIR_CANDIDATES[@]}" | awk '!seen[$0]++')

if [ "${#CONF_DIRS[@]}" -eq 0 ]; then
    echo "   ⚠️  No conf.d directories found; enabling only for current CLI context."
fi

INI_NAME="30-${EXTENSION_NAME}.ini"
INI_CONTENT="extension=${PHP_EXT_DIR}/${EXTENSION_NAME}.so"

for confd in "${CONF_DIRS[@]:-}"; do
    INI_PATH="${confd}/${INI_NAME}"
    echo "$INI_CONTENT" | $SUDO tee "$INI_PATH" >/dev/null
    ok "Written: $INI_PATH"
done
echo ""

# Verify CLI load
step "🔍 Verifying installation (CLI)..."
VERIFY_ERRORS="$("$PHP_BIN_REAL" -m 2>&1 >/dev/null || true)"
if "$PHP_BIN_REAL" -m 2>/dev/null | grep -q "^${EXTENSION_NAME}$"; then
    ok "Extension loaded successfully in CLI"
    [ -n "$VERIFY_ERRORS" ] && echo "   ⚠️  PHP startup warnings: $VERIFY_ERRORS"
else
    echo ""
    echo "   PHP binary:  $PHP_BIN_REAL"
    echo "   Ext dir:     $PHP_EXT_DIR"
    echo "   INI written: ${CLI_SCAN_DIR:-unknown}/${INI_NAME}"
    [ -n "$VERIFY_ERRORS" ] && echo "   PHP stderr: $VERIFY_ERRORS"
    die "Extension not detected in CLI. Check ${INI_NAME} placement and php --ini."
fi
echo ""

# Reload FPM if running
if command -v systemctl >/dev/null 2>&1; then
    for svc in "php${PHP_VER_MM}-fpm" "php-fpm"; do
        if systemctl is-active --quiet "${svc}.service" 2>/dev/null; then
            step "🔁 Reloading ${svc}..."
            $SUDO systemctl reload "${svc}" || true
            ok "${svc} reloaded"
            break
        fi
    done
fi

step "=========================================="
step " Extension Information (CLI)"
step "=========================================="
"$PHP_BIN_REAL" --ri "${EXTENSION_NAME}" || true
echo ""

echo "✅  Installation complete!"
echo ""
echo "File locations:"
echo "  • Binary: ${PHP_EXT_DIR}/${EXTENSION_NAME}.so"
if [ "${#CONF_DIRS[@]}" -gt 0 ]; then
    for d in "${CONF_DIRS[@]}"; do
        echo "  • Config: ${d}/${INI_NAME}"
    done
else
    echo "  • Config: (check php --ini)"
fi
echo ""
echo "Run the example:"
echo "  php ${SCRIPT_DIR}/examples/proof_of_work.php"
echo ""
