setopt PROMPT_SUBST

function environs {
  envs=()

  [[ ${#envs} != 0 ]] || return

  echo -n "%{%F{0}%K{0}%}"
  for env in $envs; do
    echo -n "${(S)env/</"\uE0B2%S%{%K{0}%}"}%s "
  done
  echo -n "%{%f%k%}"
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
    color="161"
  elif ( ! git diff --quiet --staged ); then
    color="119"
  else
    color="20"
  fi

  echo -n " on %{$detatched%F{$color}%}${branch/refs\/heads\//}%{%f%u%}"
}

PROMPT=
PROMPT+="%{%F{141}%}%m%{%f%}:"
PROMPT+="%{%F{221}%}%~%{%f%}"
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

function preexec {
  export PROMPT_COMMAND_EXECUTED=1
}

function precmd {
  local exit_code=$status
  if [[ -n $PROMPT_COMMAND_EXECUTED ]]; then
    [[ $exit_code -ne 0 ]] && echo -e "\e[38;5;248m# => $exit_code"
    echo
  fi

  unset PROMPT_COMMAND_EXECUTED
}
