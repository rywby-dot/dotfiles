#!/bin/sh
# driftwm installer — downloads the latest release and installs system-wide.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/malbiruk/driftwm/main/install.sh | sudo sh
#   curl -fsSL https://raw.githubusercontent.com/malbiruk/driftwm/main/install.sh | sudo sh -s uninstall

set -e

PREFIX="${PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
DATADIR="$PREFIX/share"
SYSCONFDIR="${SYSCONFDIR:-/etc}"
REPO="malbiruk/driftwm"

# Runtime libraries the binary links against.
RUNTIME_LIBS="libseat.so libdisplay-info.so libinput.so libgbm.so libxkbcommon.so"

red()   { printf '\033[1;31m%s\033[0m\n' "$1"; }
green() { printf '\033[1;32m%s\033[0m\n' "$1"; }
bold()  { printf '\033[1m%s\033[0m\n' "$1"; }

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        red "Error: must run as root (use sudo)."
        exit 1
    fi
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

check_runtime_deps() {
    missing=""
    for lib in $RUNTIME_LIBS; do
        if ! ldconfig -p 2>/dev/null | grep -q "$lib"; then
            missing="$missing $lib"
        fi
    done

    if [ -n "$missing" ]; then
        red "Missing runtime libraries:$missing"
        echo ""
        distro=$(detect_distro)
        case "$distro" in
            fedora|rhel|centos)
                bold "Install with: sudo dnf install libseat libdisplay-info libinput mesa-libgbm libxkbcommon" ;;
            ubuntu|debian|linuxmint|pop)
                bold "Install with: sudo apt install libseat1 libdisplay-info-dev libinput10 libudev1 libgbm1 libxkbcommon0" ;;
            arch|manjaro|endeavouros)
                bold "Install with: sudo pacman -S seatd libdisplay-info libinput mesa libxkbcommon" ;;
            *)
                bold "Install the packages that provide:$missing" ;;
        esac
        exit 1
    fi
}

check_portal_deps() {
    # Portals are optional but recommended. xdph-cosmic gives per-window
    # screencast (Brave Meet, OBS); xdph-wlr is the monitor-only fallback.
    has_cosmic=0
    has_wlr=0
    for p in /usr/libexec/xdg-desktop-portal-cosmic /usr/lib/xdg-desktop-portal-cosmic; do
        [ -x "$p" ] && has_cosmic=1
    done
    for p in /usr/libexec/xdg-desktop-portal-wlr /usr/lib/xdg-desktop-portal-wlr; do
        [ -x "$p" ] && has_wlr=1
    done

    if [ "$has_cosmic" -eq 0 ] && [ "$has_wlr" -eq 0 ]; then
        bold "Optional: install a screencast portal for OBS / Brave Meet / Firefox screen sharing."
        distro=$(detect_distro)
        case "$distro" in
            fedora|rhel|centos)
                echo "  sudo dnf install xdg-desktop-portal-cosmic   # per-window + monitor"
                echo "  sudo dnf install xdg-desktop-portal-wlr      # monitor only"
                ;;
            ubuntu|debian|linuxmint|pop)
                echo "  sudo apt install xdg-desktop-portal-cosmic   # per-window + monitor (if packaged)"
                echo "  sudo apt install xdg-desktop-portal-wlr      # monitor only"
                ;;
            arch|manjaro|endeavouros)
                echo "  sudo pacman -S xdg-desktop-portal-cosmic     # per-window + monitor"
                echo "  sudo pacman -S xdg-desktop-portal-wlr        # monitor only"
                ;;
            *)
                echo "  Install xdg-desktop-portal-cosmic (preferred) or xdg-desktop-portal-wlr."
                ;;
        esac
        echo ""
    elif [ "$has_cosmic" -eq 0 ]; then
        bold "Note: only xdg-desktop-portal-wlr is installed (monitor capture only)."
        echo "  For per-window screencast (Brave Meet, OBS window sharing), install xdg-desktop-portal-cosmic."
        echo ""
    fi
}

do_install() {
    check_root

    bold "Checking runtime dependencies..."
    check_runtime_deps
    green "All runtime dependencies found."
    check_portal_deps

    bold "Fetching latest release..."
    if ! command -v curl >/dev/null 2>&1; then
        red "Error: curl is required."
        exit 1
    fi

    RELEASE_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
        | grep '"browser_download_url"' \
        | grep 'x86_64-linux\.tar\.gz' \
        | head -1 \
        | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')

    if [ -z "$RELEASE_URL" ]; then
        red "Error: could not find a release artifact."
        red "Check https://github.com/$REPO/releases"
        exit 1
    fi

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    bold "Downloading $RELEASE_URL..."
    curl -fSL "$RELEASE_URL" -o "$TMPDIR/release.tar.gz"
    tar xzf "$TMPDIR/release.tar.gz" -C "$TMPDIR"

    # Find the extracted directory
    SRCDIR=$(find "$TMPDIR" -maxdepth 1 -type d -name 'driftwm-*' | head -1)
    if [ -z "$SRCDIR" ]; then
        red "Error: unexpected archive structure."
        exit 1
    fi

    bold "Installing to $PREFIX..."
    install -Dm755 "$SRCDIR/driftwm" "$BINDIR/driftwm"
    install -Dm755 "$SRCDIR/driftwm-session" "$BINDIR/driftwm-session"
    install -Dm644 "$SRCDIR/driftwm.desktop" "$DATADIR/wayland-sessions/driftwm.desktop"
    install -Dm644 "$SRCDIR/driftwm-portals.conf" "$DATADIR/xdg-desktop-portal/driftwm-portals.conf"

    # Clean up stale system config from pre-rename installs (compositor never read it)
    rm -f "$SYSCONFDIR/driftwm/config.toml"
    install -Dm644 "$SRCDIR/config.reference.toml" "$SYSCONFDIR/driftwm/config.reference.toml"

    for f in "$SRCDIR"/wallpapers/*.glsl "$SRCDIR"/wallpapers/*/*.glsl; do
        [ -f "$f" ] || continue
        rel="${f#"$SRCDIR"/wallpapers/}"
        install -Dm644 "$f" "$DATADIR/driftwm/wallpapers/$rel"
    done

    green "driftwm installed successfully!"
    echo ""
    echo "  Binary:     $BINDIR/driftwm"
    echo "  Session:    $BINDIR/driftwm-session"
    echo "  Reference:  $SYSCONFDIR/driftwm/config.reference.toml"
    echo "  Wallpapers: $DATADIR/driftwm/wallpapers/"
    echo ""
    echo "Select 'driftwm' from your display manager, or run 'driftwm' from a TTY."
}

do_uninstall() {
    check_root

    bold "Uninstalling driftwm..."
    rm -f "$BINDIR/driftwm"
    rm -f "$BINDIR/driftwm-session"
    rm -f "$DATADIR/wayland-sessions/driftwm.desktop"
    rm -f "$DATADIR/xdg-desktop-portal/driftwm-portals.conf"
    rm -rf "$DATADIR/driftwm"
    rm -rf "$SYSCONFDIR/driftwm"
    green "driftwm uninstalled."
}

case "${1:-install}" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
    *)         red "Usage: $0 [install|uninstall]"; exit 1 ;;
esac
