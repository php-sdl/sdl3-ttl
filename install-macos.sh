#!/bin/bash

# macOS installer for the sdl3ttf Zephir extension.
# - Detects and installs SDL3 + SDL3_ttf via Homebrew if missing
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
    echo "SDL3_ttf Extension Installer (macOS)"
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
        echo "---- Errors in ${LOG_FILE} ----"
        grep -i "error:" "$LOG_FILE" | grep -v "warning:" | grep -v "note:" || true
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

ensure_sdl3_macos() {
    step "📚 Checking SDL3 dependency..."

    if ! command -v brew >/dev/null 2>&1; then
        die "Homebrew is required on macOS. Install it first: https://brew.sh/"
    fi

    if ! command -v pkg-config >/dev/null 2>&1; then
        step "   Installing pkg-config via Homebrew..."
        brew install pkg-config || die "Failed to install pkg-config."
    fi

    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
    for _pkgdir in "${brew_prefix}/lib/pkgconfig" "${brew_prefix}/share/pkgconfig" \
                   "/usr/local/lib/pkgconfig" "/usr/local/share/pkgconfig"; do
        [ -d "$_pkgdir" ] && export PKG_CONFIG_PATH="${_pkgdir}:${PKG_CONFIG_PATH:-}"
    done

    if pkg-config --exists sdl3 2>/dev/null; then
        ok "SDL3 detected via pkg-config ($(pkg-config --modversion sdl3))"
        return
    fi

    step "   SDL3 not found. Installing via Homebrew..."
    brew install sdl3 || die "Failed to install SDL3 via Homebrew."

    if ! pkg-config --exists sdl3 2>/dev/null; then
        die "SDL3 still not detected by pkg-config after install. Check PKG_CONFIG_PATH."
    fi
    ok "SDL3 installed ($(pkg-config --modversion sdl3))"
}

ensure_sdl3_ttf_macos() {
    step "📚 Checking SDL3_ttf dependency..."

    if ! command -v brew >/dev/null 2>&1; then
        die "Homebrew is required on macOS. Install it first: https://brew.sh/"
    fi

    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
    for _pkgdir in "${brew_prefix}/lib/pkgconfig" "${brew_prefix}/share/pkgconfig" \
                   "/usr/local/lib/pkgconfig" "/usr/local/share/pkgconfig"; do
        [ -d "$_pkgdir" ] && export PKG_CONFIG_PATH="${_pkgdir}:${PKG_CONFIG_PATH:-}"
    done

    _sdl3ttf_detect() {
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

    step "   SDL3_ttf not found. Installing via Homebrew..."
    brew install sdl3_ttf || die "Failed to install SDL3_ttf via Homebrew."

    if pc_name="$(_sdl3ttf_detect)"; then
        ok "SDL3_ttf installed and detected (${pc_name})"
        return
    fi

    # Accept if the header is present even without a .pc file.
    if [ -f "${brew_prefix}/include/SDL3_ttf/SDL_ttf.h" ] || \
       [ -f "${brew_prefix}/include/SDL3/SDL_ttf.h" ]; then
        ok "SDL3_ttf installed (headers found; pkg-config .pc unavailable but build will proceed)"
        return
    fi

    die "SDL3_ttf still not detected after install. Run: brew reinstall sdl3_ttf"
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

ensure_sdl3_macos
ensure_sdl3_ttf_macos

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

# GCC 14+ on some hosts promotes -Wincompatible-pointer-types to an error;
# Zephir-generated code has benign mismatches — demote them to warnings.
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
if ! "$ZEPHIR" build >>"$LOG_FILE" 2>&1; then
    show_failure_logs
    die "Build failed. See ${LOG_FILE}."
fi
if [ ! -f "$BUILD_SO" ]; then
    show_failure_logs
    die "Build output not found at ${BUILD_SO}."
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
    echo "   PHP binary:   $PHP_BIN_REAL"
    echo "   Ext dir:      $PHP_EXT_DIR"
    echo "   INI:          ${CLI_SCAN_DIR:-unknown}/${INI_NAME}"
    [ -n "$VERIFY_ERRORS" ] && echo "   PHP stderr: $VERIFY_ERRORS"
    die "Extension not detected in CLI. Check ${INI_NAME} placement and php --ini."
fi
echo ""

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
    echo "  • Config: (CLI scan dir — check php --ini)"
fi
echo ""
echo "Run the example:"
echo "  php ${SCRIPT_DIR}/examples/proof_of_work.php"
echo ""
