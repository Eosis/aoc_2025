import day_9
import gleeunit/should

const test_input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn part_1_test() {
  day_9.do_part_1(test_input)
  |> should.equal(50)
}

pub fn part_2_test() {
  True
}
