# This file is used when ZDOTDIR is inherited by a child Zsh process.
zmodload zsh/datetime
typeset -g ZSH_STARTUP_EPOCH=$EPOCHREALTIME
