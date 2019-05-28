#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # shellcheck source=.
  source "$BATS_TEST_DIRNAME/../gatsh.sh"
}

@test "parse_args with existing input file should set INPUT" {
  file=$(mktemp)
  parse_args "$file"

  assert_equal "$INPUT" "$file"
}

@test "parse_args with nonexisting input file should print error" {
  run parse_args invalid_file

  assert_output "The file 'invalid_file' does not exist!"
}

@test "parse_args with output should set OUTPUT" {
  file=$(mktemp)
  parse_args -o output_file "$file"

  assert_equal "$OUTFILE" output_file
}

@test "parse_args with optional output missing should print error" {
  run parse_args -o

  assert_output "Missing value for optional argument '-o'"
}

@test "parse_args with output but invalid file should show error" {
  file=$(mktemp)
  run parse_args -o "/invalid/outfile.sh" "$file"

  assert_output --partial "Invalid output file"
}

@test "get_individual_sources should seperate files" {
  run get_individual_sources "source lib1 lib2 lib3"

  assert_output <<EOF
lib1
lib2
lib3
EOF
}
@test "parse_args with help prints usage" {
  run parse_args -h

  assert_output --partial "Usage: gatsh"
}

@test "clean_source should remove double quotes" {
  source="\"lib1.sh\""

  clean_source 

  assert_equal "$source" lib1.sh
}

@test "clean_source should remove single quotes" {
  source="'lib1.sh'"

  clean_source 

  assert_equal "$source" lib1.sh
}

@test "get_sourced_path with file should return relative path" {
  root="$BATS_TEST_DIRNAME/file.sh"
  source="./lib.sh"

  result=$(get_sourced_path "$root" "$source")

  assert_equal "$result" "$BATS_TEST_DIRNAME/lib.sh"
}

