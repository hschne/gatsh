#!/usr/bin/env bash

# TODO: Make script more robust by using set -e and friendsa
INPUT=""
TEMPFILE=""

main() {
  parse_args "$@"
  # TODO: Try to minimize dependencies: sed, grep, cat, see bash bible
  TEMPFILE=$(mktemp "/tmp/gatsh.XXXXXXX")
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
  local file="$1"
  echo "$file" >> "$TEMPFILE"
  local contents
  contents=$(cat "$file") 
  contents=$(inline_sourced "$file" "$contents")
  echo "$contents"
}

inline_sourced() {
  # TODO: Rip this apart so its more testable, then make sure grep matches all patterns
  local root="$1"
  local contents="$2"
  local sources
  # Get all lines where other files are sourced. If no such lines occur we can return this
  # files contents as is, because there is nothing to inline.
  sources=$(echo "$contents" | grep -e '^\w*source\s.*' -e '^\w*\.\s.*')
  [ -z "$sources" ] && { echo "$contents"; return; }
  local sourced_contents
  while read -r line; do
    sourced_contents=$(load_sourced_files "$root" "$line")
    # Replace the source line with the contents of the sourced files. Remove all other occurences of 
    # that line as well, because there's no need to process them 
    contents=${contents/"$line"/"$sourced_contents"}
    contents=${contents//"$line"}
  done <<< "$sources"
  echo "$contents"
}

load_sourced_files() {
  # TODO: Rip this apart so its more testable, then make sure grep matches all patterns
  local root="$1"
  local source_line="$2"
  local sources
  # Get all files that occur within a single source statement, e.g. source lib1 lib2 yields lib1, lib2
  sources=$(echo "$source_line" \
    | cut -d' ' -f2- \
    | tr ' ' '\n')
  local sources_contents=()
  local content
  while read -r source; do
    sourced_path=$(get_sourced_path "$root" "$source")
    # Check that the file being imported was not already imported
    readarray imported_files < "$TEMPFILE"
    [[ ${imported_files[*]} == *"$sourced_path"* ]] && continue
    # TODO: Check & warn if that file does not exist
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
#   $1 - The file from which requires the source. Must be in an existing directory
#   $2 - The path to the sourced file
# 
# Examples
#   get_sourced_path main.sh ../lib1 
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
