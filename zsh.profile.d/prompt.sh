setopt PROMPT_SUBST

function check_for {
  /usr/bin/which -s $*
}

function environs {
  envs=()
  envs+=$(check_for rbenv && environ_rbenv)
  envs+=$(check_for node && environ_node)

  [[ ${#envs} != 0 ]] || return

  echo -n "%{%F{black}%K{black}%}"
  for env in $envs; do
    echo -n "${(S)env/</"\uE0B2%S%{%K{black}%}"}%s "
  done
  echo -n "%{%f%k%}"
}

function environ_rbenv {
  active_gemsets="$(rbenv gemset active 2>/dev/null)"
  echo -n "%F{red}"
  echo -n "< $(rbenv version | cut -d \  -f1)${active_gemsets:+ ($active_gemsets)}"
  echo -n "%K{red}"
}

function environ_node {
  echo -n "%F{blue}"
  echo -n "< $(node --version)"
  echo -n "%K{blue}"
}

function prompt_vcs {
  prompt_git
}

function prompt_git {
  git_dir=`git rev-parse --git-dir 2> /dev/null`
  [[ -n ${git_dir/./} ]] || return 1

  branch=`git symbolic-ref -q HEAD || git name-rev --name-only --always HEAD 2> /dev/null`
  [[ -n `git symbolic-ref -q HEAD` ]] || detatched='%U'

  if ( ! git diff --quiet || [[ -n `git ls-files -o --exclude-standard` ]] ); then
    color="red"
  elif ( ! git diff --quiet --staged ); then
    color="green"
  else
    color="blue"
  fi

  echo -n " on %{$detatched%F{$color}%}${branch/refs\/heads\//}%{%f%u%}"
}

PROMPT=
PROMPT+="%{%F{magenta}%}%m%{%f%}:"
PROMPT+="%{%F{yellow}%}%~%{%f%}"
PROMPT+="\$(prompt_vcs)"
PROMPT+=" %(!.#.$) "
export PROMPT

RPROMPT='$(environs)'
export RPROMPT

# Output command results at each new prompt.

# If a command has been run since the last invocation of `ps1_exit_code`,
# output a newline between the results of that command and the new prompt.

# Additionally, if the command had a non-zero exit code, output the numeric
# error code before the newline.

# TODO: Translate numeric exit codes into signal names?

function preexec {
  export PROMPT_COMMAND_EXECUTED=1
}

function precmd {
  local exit_code=$status
  if [[ -n $PROMPT_COMMAND_EXECUTED ]]; then
    [[ $exit_code -ne 0 ]] && echo "${fg_bold[black]}# => $exit_code"
    echo
  fi

  unset PROMPT_COMMAND_EXECUTED
}
