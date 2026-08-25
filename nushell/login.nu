# ~/.config/nushell/login.nu

# Environment that should only be initialized for the login session.
#
# Equivalent role to ~/.zprofile.

if (
    (($env.WAYLAND_DISPLAY? | default "") == "")
    and
    (($env.XDG_VTNR? | default "") == "1")
) {
    $env.XDG_SESSION_TYPE = "wayland"
    $env.XDG_MENU_PREFIX = "gnome-"

    $env.QT_QPA_PLATFORM = "wayland;xcb"
    $env.QT_QPA_PLATFORMTHEME = "qt5ct"
    $env.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"
}
