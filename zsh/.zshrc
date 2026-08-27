# Clean Zsh configuration (no Oh My Zsh)

# A child Zsh normally starts this timer in $ZDOTDIR/.zshenv. Keep a safe
# fallback for unusual launchers that skip .zshenv.
zmodload zsh/datetime
[[ -n $ZSH_STARTUP_EPOCH ]] || typeset -g ZSH_STARTUP_EPOCH=$EPOCHREALTIME

# Environment
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/openjdk21
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=app.zen_browser.zen
export TERMINAL=footclient

# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Vi editing mode
bindkey -v
KEYTIMEOUT=1

# Git aliases and helpers from the Oh My Zsh git plugin, used standalone.
[[ -r "$HOME/.local/share/zsh/plugins/omz-git/git.plugin.zsh" ]] &&
  source "$HOME/.local/share/zsh/plugins/omz-git/git.plugin.zsh"

# Functions
function f() {
	local tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[[ "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

setbat() {
    if [[ -n "$1" ]]; then
        echo "$1" | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
    else
        echo "Current limit: $(cat /sys/class/power_supply/BAT0/charge_control_end_threshold)%"
    fi
}

yt() {
    local query=$(echo "$*" | sed 's/ /+/g')
    xdg-open "https://www.youtube.com/results?search_query=$query" &>/dev/null & disown
    exit
}

vi() { nvim "$HOME/.config/$1" }
chc() { chmod +x "$HOME/.config/$1" }
mcd() { command mkdir -p "$1" && cd "$1" || return }

ggph() {
    local msg
    vared -p "Commit message: " -c msg
    [[ -n "$msg" ]] || {
        echo "Empty commit message"
        return 1
    }
    git add . && git commit -m "$msg" && git push
}

cggph() {
    local msg
    local config_dir="$HOME/.config"

    vared -p "Commit message: " -c msg
    [[ -n "$msg" ]] || {
        echo "Empty commit message"
        return 1
    }

    git -C "$config_dir" add -- \
        foot nvim mako yazi sway niri driftwm waybar nushell swayosd \
        fuzzel wlogout waypie i3status-rust kitty starship.toml \
        starship-nu.toml pipewire nwg-dock zsh README.md .gitignore &&
    git -C "$config_dir" commit -m "$msg" &&
    git -C "$config_dir" push
}

compdef '_files -W ~/.config' vi
compdef '_files -W ~/.config' chc
compdef '_files -W flatpak remove' fpr

alias gclo='cd ~/builds && git clone'
alias drup='cd ~/builds/driftwm && git pull && make build && sudo make install'
alias cx='chmod +x'
alias svo='sudo sv stop'
alias sva='sudo sv start'
alias sve='sudo sv restart'
alias svs='sudo sv status'
alias svi='sudo nvim'
alias cl='clear'
alias hi='history'
alias ins='sudo xbps-install '
alias rem='sudo xbps-remove -Ro '
alias swa='nvim ~/.config/sway/config'
alias sea='xbps-query -Rs '
alias ff='fastfetch -c screenfetch.jsonc'
alias mnd='mkdir -p '
alias pok='clear && pokemon-colorscripts -r --no-title'
alias swag='exec dbus-run-session sway-rywby'
alias niro='exec dbus-run-session niri --session'
alias diof='exec dbus-run-session driftwm'
alias heve='exec dbus-run-session swc-launch ~/builds/hevelwm/start_hevel.sh'
alias dio='nvim ~/.config/driftwm/config.toml'
alias fre='flatpak remove'
alias fru='flatpak run'
alias zsvi='nvim ~/.config/zsh/.zshrc'
alias zpvi='nvim ~/.config/zsh/.zprofile'
alias ripd='ripdrag -a -s 64 -H 500 -n -b -W 420'
alias hg='history | grep '

# System plugins. Syntax highlighting must be loaded after other ZLE plugins.
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# Startup banner
zsh_startup_banner() {
    local logo_color=$'\e[38;2;241;90;36m'
    local label_color=$'\e[1;32m'
    local reset=$'\e[0m'
    local uptime_value
    local day_word hour_word minute_word second_word
    local -i uptime_days uptime_hours uptime_minutes uptime_seconds
    local -i uptime_total_ms uptime_ms
    local -i elapsed_ns elapsed_ms elapsed_us elapsed_remainder_ns

    read -r uptime_value _ < /proc/uptime
    uptime_total_ms=$(( int(uptime_value * 1000) ))
    uptime_days=$(( uptime_total_ms / 86400000 ))
    uptime_hours=$(( (uptime_total_ms / 3600000) % 24 ))
    uptime_minutes=$(( (uptime_total_ms / 60000) % 60 ))
    uptime_seconds=$(( (uptime_total_ms / 1000) % 60 ))
    uptime_ms=$(( uptime_total_ms % 1000 ))
    day_word=$([[ $uptime_days == 1 ]] && print day || print days)
    hour_word=$([[ $uptime_hours == 1 ]] && print hour || print hours)
    minute_word=$([[ $uptime_minutes == 1 ]] && print minute || print minutes)
    second_word=$([[ $uptime_seconds == 1 ]] && print second || print seconds)

    elapsed_ns=$(( int((EPOCHREALTIME - ZSH_STARTUP_EPOCH) * 1000000000) ))
    elapsed_ms=$(( elapsed_ns / 1000000 ))
    elapsed_us=$(( (elapsed_ns / 1000) % 1000 ))
    elapsed_remainder_ns=$(( elapsed_ns % 1000 ))

    print -r -- "${logo_color} _____  ____  _   _${reset}"
    print -r -- "${logo_color}|__  / / ___|| | | |${reset}"
    print -r -- "${logo_color}  / /  \\___ \\| |_| |${reset}"
    print -r -- "${logo_color} / /_   ___) |  _  |${reset}"
    print -r -- "${logo_color}/____| |____/|_| |_|${reset}"
    print -r -- "${label_color}Startup Time:${reset} ${elapsed_ms}ms ${elapsed_us}µs ${elapsed_remainder_ns}ns"
    print -r -- "${label_color}Uptime:${reset} ${uptime_days} ${day_word} ${uptime_hours} ${hour_word} ${uptime_minutes} ${minute_word} ${uptime_seconds} ${second_word} ${uptime_ms}ms"
}

zsh_startup_banner
unfunction zsh_startup_banner
unset ZSH_STARTUP_EPOCH
