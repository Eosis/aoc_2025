import day_5
import gleeunit/should

const test_input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

pub fn part_1_test() {
  day_5.do_part_1(test_input)
  |> should.equal(3)
}

pub fn parsing_test() {
  day_5.parse_input(test_input)
  |> echo
}

pub fn part_2_test() {
  day_5.do_part_2(test_input)
  |> should.equal(14)
}
