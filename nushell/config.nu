# config.nu
#
# Installed by:
# version = "0.112.2"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
# mkdir ($nu.data-dir | path join "vendor/autoload")
# starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
# $env.config.edit_mode = "vi"
# $env.config.buffer_editor = "nvim"

# ~/.config/nushell/config.nu


# ============================================================
# PATH
# ============================================================

use std/util "path add"

path add ($nu.home-dir | path join ".local/bin")
path add ($nu.home-dir | path join ".cargo/bin")

$env.JAVA_HOME = "/usr/lib/jvm/openjdk21"
path add ($env.JAVA_HOME | path join "bin")

$env.ANDROID_HOME = ($nu.home-dir | path join "Android/Sdk")
$env.ANDROID_SDK_ROOT = $env.ANDROID_HOME

path add ($env.ANDROID_HOME | path join "cmdline-tools/latest/bin")
path add ($env.ANDROID_HOME | path join "platform-tools")


# ============================================================
# Environment
# ============================================================

$env.LANG = "en_US.UTF-8"

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.BROWSER = "app.zen_browser.zen"
$env.TERMINAL = "footclient"


# ============================================================
# Nushell
# ============================================================

$env.config.buffer_editor = "nvim"

# Vim mode
$env.config.edit_mode = "vi"

# Disable Nushell welcome banner
# $env.config.show_banner = false


# ============================================================
# Yazi
# ============================================================

def --env f [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")

    ^yazi ...$args --cwd-file $tmp

    let cwd = (open $tmp)

    if $cwd != $env.PWD and ($cwd | path exists) {
        cd $cwd
    }

    rm -fp $tmp
}


# ============================================================
# Battery charge limit
# ============================================================

def setbat [limit?: int] {
    let battery_file = "/sys/class/power_supply/BAT0/charge_control_end_threshold"

    if $limit != null {
        $limit
        | into string
        | ^sudo tee $battery_file
    } else {
        let current = (
            open --raw $battery_file
            | str trim
        )

        print $"Current limit: ($current)%"
    }
}


# ============================================================
# YouTube search
# ============================================================

def yt [...words: string] {
    let query = (
        $words
        | str join " "
        | str replace --all " " "+"
    )

    ^xdg-open $"https://www.youtube.com/results?search_query=($query)" o+e> /dev/null

    exit
}


# ============================================================
# ~/.config completions
# ============================================================

def "nu-complete config files" [context: string] {
    let base = ($nu.home-dir | path join ".config")

    let typed = (
        $context
        | str replace -r '^(vi|chc)\s*' ''
    )

    let directory_selected = ($typed | str ends-with (char path_sep))

    let parent = if $directory_selected {
        $typed | str trim --right --char (char path_sep)
    } else {
        $typed | path dirname
    }

    let prefix = if $directory_selected {
        ""
    } else {
        $typed | path basename
    }

    let search_dir = if ($parent | is-empty) or $parent == "." {
        $base
    } else {
        $base | path join $parent
    }

    if not ($search_dir | path exists) {
        return []
    }

    ls -a $search_dir
    | where {|item|
        ($item.name | path basename) | str starts-with $prefix
    }
    | each {|item|
        let name = ($item.name | path basename)

        let relative = if ($parent | is-empty) or $parent == "." {
            $name
        } else {
            $parent | path join $name
        }

        if $item.type == "dir" {
            $"($relative)/"
        } else {
            $relative
        }
    }
}


# ============================================================
# ~/.config helpers
# ============================================================

def vi [file: string@"nu-complete config files"] {
    ^nvim (
        $nu.home-dir
        | path join ".config" $file
    )
}

def chc [file: string@"nu-complete config files"] {
    ^chmod +x (
        $nu.home-dir
        | path join ".config" $file
    )
}


# ============================================================
# mkdir + cd
# ============================================================

def --env mcd [dir: path] {
    mkdir $dir
    cd $dir
}


# ============================================================
# Git clone into ~/builds
# ============================================================

def --env gclo [...args: string] {
    cd ($nu.home-dir | path join "builds")

    ^git clone ...$args
}


# ============================================================
# DriftWM update
# ============================================================

def --env drup [] {
    cd ($nu.home-dir | path join "builds/driftwm")

    ^git pull and
    ^make build and
    ^sudo make install
}


# ============================================================
# Git add + commit + push
# ============================================================

def ggph [] {
    let msg = (input "Commit message: ")

    if ($msg | str trim | is-empty) {
        print "Сообщение коммита пустое"
        return
    }

    ^git add . and
    ^git commit -m $msg and
    ^git push
}


# ============================================================
# History search
# ============================================================

def hg [pattern: string] {
    history
    | where command =~ $pattern
    | get command
}


# ============================================================
# Service aliases
# ============================================================

alias svo = sudo sv stop
alias sva = sudo sv start
alias sve = sudo sv restart
alias svs = sudo sv status


# ============================================================
# XBPS
# ============================================================

alias ins = sudo xbps-install
alias rem = sudo xbps-remove -Ro
alias sea = xbps-query -Rs


# ============================================================
# Flatpak
# ============================================================

alias fre = flatpak remove
alias fru = flatpak run


# ============================================================
# General aliases
# ============================================================

alias cx = chmod +x

alias svi = sudo nvim

alias cl = clear
alias hi = history

# mkdir in Nu creates parent directories as needed
alias mnd = mkdir

alias swa = nvim ~/.config/sway/config
alias dio = nvim ~/.config/driftwm/config.toml

alias ripd = ripdrag -a -s 64 -H 500 -n -b -W 420


# ============================================================
# Config editing
# ============================================================

# alias nuvi = nvim ~/.config/nushell/config.nu
# alias nuli = nvim ~/.config/nushell/login.nu
# alias stvi = nvim ~/.config/starship.toml


# ============================================================
# Fastfetch
# ============================================================

def ff [] {
    ^fastfetch -c screenfetch.jsonc
}


# ============================================================
# Pokemon
# ============================================================

def pok [] {
    clear
    ^pokemon-colorscripts -r --no-title
}

def dfiles [] {
    git -C ~/.config add -- foot nvim mako yazi sway niri driftwm waybar nushell swayosd fuzzel wlogout waypie i3status-rust kitty starship.toml pipewire nwg-dock
    git -C ~/.config commit -m "update"
    git -C ~/.config push
}

# ============================================================
# Wayland sessions
# ============================================================

def swag [] {
    with-env {
        XDG_SESSION_TYPE: "wayland"
        XDG_CURRENT_DESKTOP: "sway"
        XDG_SESSION_DESKTOP: "sway"
    } {
        exec dbus-run-session sway-rywby
    }
}


def niro [] {
    with-env {
        XDG_SESSION_TYPE: "wayland"
        XDG_CURRENT_DESKTOP: "niri"
        XDG_SESSION_DESKTOP: "niri"
    } {
        exec dbus-run-session niri --session
    }
}


def diof [] {
    with-env {
        XDG_SESSION_TYPE: "wayland"
        XDG_CURRENT_DESKTOP: "driftwm"
        XDG_SESSION_DESKTOP: "driftwm"
    } {
        exec dbus-run-session driftwm
    }
}


def heve [] {
    let script = (
        $nu.home-dir
        | path join "builds/hevelwm/start_hevel.sh"
    )

    with-env {
        XDG_SESSION_TYPE: "wayland"
        XDG_CURRENT_DESKTOP: "hevelwm"
        XDG_SESSION_DESKTOP: "hevelwm"
    } {
        exec dbus-run-session swc-launch $script
    }
}


# ============================================================
# Starship
# ============================================================

# Vendor autoload runs after config.nu and Starship replaces PROMPT_COMMAND
# there. Preserve Nushell's stock prompt so the user autoload can restore it.
$env.NU_STOCK_PROMPT_COMMAND = $env.PROMPT_COMMAND
