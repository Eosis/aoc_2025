import day_3
import gleeunit/should

const test_input = "987654321111111
811111111111119
234234234234278
818181911112111"

pub fn part_1_test() {
  day_3.do_part_1(test_input)
  |> should.equal(357)
}

pub fn parsing_test() {
  day_3.parse_input(test_input)
  |> should.equal([
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    [8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9],
    [2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8],
    [8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1],
  ])
}
