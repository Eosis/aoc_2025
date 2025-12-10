import day_10
import gleam/io
import gleam/list
import gleeunit/should
import pprint

const test_input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

pub fn part_1_test() {
  day_10.do_part_1(test_input)
  |> should.equal(7)
}

pub fn part_2_test() {
  Ok(Nil)
}

pub fn parse_input_test() {
  test_input
  |> day_10.parse_input
  |> list.map(day_10.format_machine_description)
  |> pprint.debug
}
