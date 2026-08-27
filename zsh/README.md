Add ~/.zshenv:
```
  if [[ -e ~/.zshenv ]]; then
      cp -a -- ~/.zshenv ~/.zshenv_bak
  fi && printf '%s\n' \
      'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' \
      'zmodload zsh/datetime' \
      'typeset -g ZSH_STARTUP_EPOCH=$EPOCHREALTIME' \
      > ~/.zshenv
```
```
```
