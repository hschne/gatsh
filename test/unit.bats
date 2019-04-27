#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # shellcheck source=.
  source "$BATS_TEST_DIRNAME/../gatsh.sh"
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

