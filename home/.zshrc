autoload -U colors && colors

export PAGER="less -R"
export EDITOR=$(which mate &>/dev/null && which mate || which vim)
bindkey -e  # Turns out, zsh thinks Vim users want Vim mode automatically...

# rvm Setup
[[ -s ~/.rvm/scripts/rvm ]] && source ~/.rvm/scripts/rvm

# perlbrew Setup
export PERLBREW_ROOT=~/.perlbrew
[[ -s $PERLBREW_ROOT/etc/bashrc ]] && source $PERLBREW_ROOT/etc/bashrc

# cpanminus Setup
export PERL_CPANM_OPT="--skip-installed --prompt"

export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTFILE=~/.zsh_history

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_NO_STORE
setopt NO_HIST_BEEP

source ~/.prompt
source ~/.zsh-completion
