setopt PROMPT_SUBST

function check_for {
  /usr/bin/which -s $*
}

function environs {
  envs=()
  envs+=$(check_for rbenv && environ_ruby)
  envs+=$(check_for goenv && environ_go)
  envs+=$(check_for nodenv && environ_node)

  [[ ${#envs} != 0 ]] || return

  echo -n "%{%F{0}%K{0}%}"
  for env in $envs; do
    echo -n "${(S)env/</"\uE0B2%S%{%K{0}%}"}%s "
  done
  echo -n "%{%f%k%}"
}

function environ_ruby {
  version=$(rbenv version | awk '{ print $1 }')
  if [ $version != 'system' ] && [ $version != '(set' ]; then
  active_gemsets="$(rbenv gemset active 2>/dev/null)"
    echo -n "%F{160}"
    echo -n "< %K{15}⌔ ${version}${active_gemsets:+ ($active_gemsets)}%k"
    echo -n "%K{160}"
  fi
}

function environ_node {
  version=$(nodenv version | awk '{ print $1 }')
  if [ $version != 'system' ] && [ $version != '(set' ]; then
    echo -n "%F{22}"
    echo -n "< %K{15}⬢ ${version}%k"
    echo -n "%K{22}"
  fi
}

function environ_go {
  version=$(goenv version | awk '{ print $1 }')
  if [ $version != 'system' ] && [ $version != '(set' ]; then
    echo -n "%F{153}"
    echo -n "< %K{0}ᵍ̥ ${version}%k"
    echo -n "%K{153}"
  fi
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

# TODO: Translate numeric exit codes into signal names?

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
