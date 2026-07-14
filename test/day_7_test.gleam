import day_7
import gleeunit/should

import pprint

import rememo/memo

const test_input = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."

pub fn part_1_test() {
  day_7.do_part_1(test_input)
  |> should.equal(21)
}

pub fn part_2_test() {
  day_7.do_part_2(test_input)
  |> should.equal(40)
}

pub fn parse_test() {
  test_input
  |> day_7.parse_input
  |> pprint.debug
}

pub fn rememo_test() {
  // Make the mutable state that holds the cached values
  // for the duration of this block, return the final value of 
  // the called function, then delete the mutable state
  use cache <- memo.create()
  fib(300, cache)
  |> echo
}

fn fib(n, cache) {
  // Check if a value exists for the key n
  // Use it if it exists, update the cache if it doesn't
  use <- memo.memoize(cache, n)
  case n {
    1 | 2 -> 1
    n -> fib(n - 1, cache) + fib(n - 2, cache)
  }
}
