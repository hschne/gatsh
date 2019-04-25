#!/usr/bin/env bash

main() {
  local root_file="$1"
  load_file "$root_file" 
}

load_file() {
  local root_file
  root_file=$(realpath "$1")
  local contents
  contents=$(cat "$root_file") 
  get_source_lines "$root_file" "$contents"
}

get_source_lines() {
  local root_file="$1"
  local contents="$2"
  local sources
  sources=$(echo "$contents" | sed '/^#!/d' \
    | grep -e 'source\s')
  [ -z "$sources" ] && return
  while read -r line; do
      echo "... $line ..."
  done <<< "$sources"
}

parse_source() {
  local root_file="$1"
  local source="$2"
  local source_files
  source_files=$(echo "$source" | cut -d' ' -f2- \
    | tr ' ' '\n')
  while read -r line; do
      echo "... $line ..."
  done <<< "$source_files"
}

parse_source_file() {
  local root_file="$1"
  local source="$2"
  local source_path
  # Get path relative to file which sources source
  source_path=$(cd "${root_file%/*}" && realpath "$source")
  echo "$source_path"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"


