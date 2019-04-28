#!/usr/bin/env bash

# TODO: Fix the fact that everything is a subshell and writing to a global array won't work
# TODO: Make script more robust by using set -e and friends
declare -a __gatsh__imported_paths=()

main() {
  parse_args "$@"
  # TODO: Try to minimize dependencies: sed, grep, cat, see bash bible
  local root
  root=$(realpath "$INPUT")
  result=$(load_file "$root")
  if [[ -z "$OUTPUT" ]]; then 
    echo "$result" 
  else 
    echo "$result" > "$OUTPUT"
  fi
}

parse_args() {
  local positional=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key in
      -o|--output)
        [[ $# -lt 2 ]] && die "Missing value for optional argument '$key'" 1
        OUTPUT="$2"
        shift # past argument
        shift # past value
        ;;
      -h|--help)
        help && exit 0
        ;;
      *)    # unknown option
        positional+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
  done
  set -- "${positional[@]}" # restore positional parameters

  if [[ ${#positional[@]} -ne 1 ]]; then
     HELP=1
     die "Missing value for non-optional argument 'file'" 1 
  fi
  INPUT=$1
  
  validate_args 
}

validate_args() {
  if [[ ! -f "$INPUT" ]]; then die "The file '$INPUT' does not exist!" 1; fi
}

die() {
  local exit_code=$2
  [[ -n "$exit_code" ]] || exit_code=1
  [[ "$HELP" = 1 ]] && help >&2
  echo "$1" >&2
  exit ${exit_code}
}

help() {
  cat <<EOF
Usage: gatsh [option]... <file>

Recursively concatinate scripts referenced in file to standard output. 

Examples: 
  gatsh main.sh

EOF
}

load_file() {
  local root="$1"
  __gatsh__imported_paths+=("$root")
  local contents
  contents=$(cat "$root") 
  contents=$(inline_sourced "$root" "$contents")
  echo "$contents"
}

inline_sourced() {
  # TODO: Rip this apart so its more testable
  local root="$1"
  local contents="$2"
  local sources
  sources=$(echo "$contents" | grep -e '^\w*source\s.*' -e '^\w*\.\s.*')
  [ -z "$sources" ] && { echo "$contents"; return; }
  local sourced_contents
  while read -r line; do
    sourced_contents=$(load_sourced_files "$root" "$line")
    contents=${contents/"$line"/"$sourced_contents"}
    contents=${contents//"$line"}
  done <<< "$sources"
  echo "$contents"
}

load_sourced_files() {
  local root="$1"
  local source_line="$2"
  local sources
  sources=$(echo "$source_line" \
    | cut -d' ' -f2- \
    | tr ' ' '\n')
  local sources_contents=()
  local content
  while read -r source; do
    sourced_path=$(get_sourced_path "$root" "$source")
    [[ ${__gatsh__imported_paths[*]} == *"$sourced_path"* ]] && continue
    content=$(load_file "$sourced_path")
    # Sanitize content: Remove shebang and leading/trailing newlines
    # See https://stackoverflow.com/a/7359879/2553104 and https://stackoverflow.com/a/1935132/2553104
    content=$(echo "$content" | sed '/^#!/d' | sed -e :a -e '/./,$!d;/^\n*$/{$d;N;};/\n$/ba' )
    sources_contents+=("$content")
  done <<< "$sources"
  echo "${sources_contents[*]}"
}

# Resolve a given source to an absolute path
# 
# Parameters: 
#   $1 - The file from which requires the source. Must exist. 
#   $2 - The path to the sourced file
# 
# Examples
#   parse_source_file /opt/main.sh ../lib1 
# 
get_sourced_path() {
  local root="$1"
  local source="$2"
  clean_source
  local source_path
  # Get path relative to file which sources source
  source_path=$(cd "${root%/*}" && realpath "$source")
  echo "$source_path"
}

clean_source(){
  source="${source%\"}"
  source="${source#\"}"
  source="${source%\'}"
  source="${source#\'}"
}


if [ "${BASH_SOURCE[0]}" == "$0" ]; then
  main "$@"
fi
