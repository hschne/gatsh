#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  # shellcheck source=.
  gatsh="$BATS_TEST_DIRNAME/../gatsh.sh"
  test_files="$BATS_TEST_DIRNAME/files"
}

@test "should concatinate sourced files" {
  run "$gatsh" "$test_files/0-default/main.sh"
  expected=$(<"$test_files/0-default/expected.sh")

  assert_output "$expected"
}

@test "with nested folders should concatinate sourced files" {
  run "$gatsh" "$test_files/1-nested/main.sh"
  expected=$(<"$test_files/1-nested/expected.sh")

  assert_output "$expected"
}

@test "with cyclic dependencies should concatinate sourced files" {
  run "$gatsh" "$test_files/2-cyclic/main.sh"
  expected=$(<"$test_files/2-cyclic/expected.sh")

  assert_output "$expected"
}

@test "with outfile should concatinate into output file" {
  outfile="$test_files/0-default/out.sh"
  run "$gatsh" -o "$outfile" "$test_files/0-default/main.sh"
  actual=$(<"$outfile")

  expected=$(<"$test_files/0-default/expected.sh")
  assert_equal "$expected" "$actual"
  rm "$outfile"
}

@test "with help should print help" {
  run "$gatsh" -h 

  assert_output --partial "Usage: gatsh [OPTIONS] <file>"
}
