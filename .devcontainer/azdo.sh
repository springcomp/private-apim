#!/bin/bash

FMT_CLEAR="\e[0m"
FMT_LIGHTGREEN_UNDERLINE="\e[4;32m"
FMT_LIGHTGRAY="\e[1;36m"
FMT_DARKGRAY="\e[1;30m"
FMT_YELLOW="\e[1;33m"
FMT_RED="\e[1;31m"
FMT_LIGHTBLUE="\e[1;34m"

## https://github.com/vsls-contrib/ado-in-codespaces/blob/main/init

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CACHE_FILE_PATH=~/.ado-in-codespaces-cache

if [ -f $CACHE_FILE_PATH ]; then
    source $CACHE_FILE_PATH
fi

function read_variable(){
  read $1
}
function read_variable_secret(){
  stty -echo

  CHARCOUNT=0
  PROMPT=""
  RESULT=""
  while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
  do
    # Enter - accept password
    if [[ $CHAR == $'\0' ]] ; then
      break
    fi

    # Backspace
    if [[ $CHAR == $'\177' ]] ; then
      if [ $CHARCOUNT -gt 0 ] ; then
        CHARCOUNT=$((CHARCOUNT-1))
        PROMPT=$'\b \b'
        RESULT="${RESULT%?}"
      else
        PROMPT=''
      fi
    else
      CHARCOUNT=$((CHARCOUNT+1))
      PROMPT='*'
      RESULT+="$CHAR"
    fi
  done

  stty echo

  eval "$1=$RESULT"
  echo ""
}
function prompt_variable_secret(){
  prompt_variable "$1" "$2" "${3:-post_process_noop}" "secret"
}
function prompt_variable_once(){
  prompt_variable "$1" "$2" "${3:-post_process_noop}" "once"
}
function prompt_variable(){
  local variable_name=$1
  local variable_prompt=$2
  local post_process_function_name=$3
  local opt=${4:-cleartext}

  if [[ -z "$post_process_function_name" ]]; then
    local post_process_function_name="post_process_noop"
  fi

  local reused=${!variable_name}
  if [[ "$opt" = "secret" ]]; then
    local reused="***"
  fi

  local suffix="$FMT_LIGHTGRAY"" (to reuse [$reused], press ENTER)$FMT_CLEAR"
  printf "$FMT_LIGHTBLUE""$variable_prompt$suffix: $FMT_CLEAR"

  if [[ "$opt" = "secret" ]]; then
    read_variable_secret input
  else
    read_variable input
  fi

  if [[ -z "$input" ]]; then
    if [[ -z "${!variable_name}" ]]; then
      echo -e "$FMT_YELLOW""Please specify a valid value for variable $variable_name.$FMT_CLEAR"
    else
      eval "input=${!variable_name}"
      echo -e "$FMT_DARKGRAY""Reusing existing $variable_name value.$FMT_CLEAR"
    fi
  fi

  if [[ "$input" != "${!variable_name}" ]]; then
    instruction="$post_process_function_name $input"
    local processed=`$instruction`
    instruction="export $variable_name=$processed"
    echo -e $instruction >> $CACHE_FILE_PATH
    eval $instruction
  fi
}

function post_process_noop(){
  echo "$1"
}

function post_process_pat(){
  echo -n ":$1" | base64
}

function init(){
  prompt_variable_once "ADO_REPO_URL" "Please enter the URL to the Azure DevOps repository"
  prompt_variable "ADO_REPO_USERNAME" "Please specify your Azure DevOps username"
  prompt_variable_secret "ADO_REPO_PAT" "Please specify your Azure DevOps Personal Access Token (PAT)" "post_process_pat"
}

function reset(){
  rm ~/.ado-in-codespaces-cache
  unset ADO_REPO_URL
  unset ADO_REPO_USERNAME
  unset ADO_REPO_PAT
}

if [[ "$1" = "--reset" ]]; then
  reset
else
  workspace=$1
  if [[ -z "$workspace" ]]; then
    workspace="/workspace"
  fi

  init
  if [[ -z "$ADO_REPO_URL" && -z "$ADO_REPO_PAT" ]]; then
    echo -e "$FMT_RED""Missing required ADO_REPO_URL or ADO_REPO_PAT variable.$FMT_CLEAR"
  else
    echo -e "$FMT_LIGHTGREEN_UNDERLINE""Cloning $ADO_REPO_URL in $workspace…$FMT_CLEAR"
    git config --global --set http.extraHeader="Authorization: Basic $ADO_REPO_PAT" 
    git clone $ADO_REPO_URL $workspace
  fi
fi