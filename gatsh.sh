#!/usr/bin/env bash

main() {
  local root_file="$1"
  load_file "$root_file" 
}

load_file() {
  local path="$1"
  local contents
  contents=$(cat "$path") 
  get_source_lines "$path" "$contents"
}

get_source_lines() {
  local path="$1"
  local contents="$2"
  local sources
  sources=$(echo "$contents" | sed '/^#!/d' \
    | grep -e 'source\s' \
    | cut -d' ' -f2- \
    | tr ' ' '\n' )
  [ -z "$sources" ] && return
  while read -r line; do
      echo "... $line ..."
  done <<< "$sources"
}

get_absolute_path() {
  local path="$1"
  local source="$2"
}

[[ ${BASH_SOURCE[0]} == $0 ]] && main "$@"


