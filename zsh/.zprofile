if [[ -z $WAYLAND_DISPLAY && $XDG_VTNR == 1 ]]; then
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_DESKTOP=sway
    export XDG_MENU_PREFIX=gnome-

    export QT_QPA_PLATFORM='wayland;xcb'
    export QT_QPA_PLATFORMTHEME=qt5ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
fi
