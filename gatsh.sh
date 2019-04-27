#!/usr/bin/env bash

declare -a __gatsh__imported_paths=()

main() {
  local root
  root=$(realpath "$1")
  load_file "$root" 
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
  local root="$1"
  local contents="$2"
  local sources
  sources=$(echo "$contents" | grep -e 'source\s')
  [ -z "$sources" ] && { echo "$contents"; return; }
  local sourced_contents
  while read -r line; do
    sourced_contents=$(load_sourced_files "$root" "$line")
    contents=${contents/"$line"/"$sourced_contents"}
    # TODO: Instead op just nuking duplicate imports in same file warn the user, or allow that?
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

echo "bla"
[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"


