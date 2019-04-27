#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # shellcheck source=.
  gatsh="$BATS_TEST_DIRNAME/../gatsh.sh"
  test_files="$BATS_TEST_DIRNAME/files"
}

@test "clean_source should remove double quotes" {
  result=$("$gatsh" "$test_files/main.sh")

  expected='#! /usr/bin/env bash/n/n echo "lib1"'


  assert_equal "$result" "$expected"
}

