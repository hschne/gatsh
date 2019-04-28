#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # shellcheck source=.
  gatsh="$BATS_TEST_DIRNAME/../gatsh.sh"
  test_files="$BATS_TEST_DIRNAME/files"
}

@test "running gatsh on main should concatinate sourced files" {
  run "$gatsh" "$test_files/main.sh"
  expected=$(<"$test_files/main_gatshified.sh")

  assert_output "$expected"
}

