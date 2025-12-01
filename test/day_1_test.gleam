import day_1.{L, R}
import gleeunit/should
import simplifile

pub fn parsing_test() {
  "L41
  R54
  L32
  R235"
  |> day_1.parse_input
  |> should.equal([L(41), R(54), L(32), R(235)])
}

pub fn part_1_test() {
  "L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82"
  |> day_1.do_part_1
  |> should.equal(3)
}

pub fn wrapping_add_test() {
  day_1.wrapping_add(99, 5)
  |> should.equal(4)

  day_1.wrapping_add(91, 4)
  |> should.equal(95)

  day_1.wrapping_add(90, 105)
  |> should.equal(95)
}

pub fn wrapping_sub_test() {
  day_1.wrapping_sub(7, 5)
  |> should.equal(2)

  day_1.wrapping_sub(2, 5)
  |> should.equal(97)

  day_1.wrapping_sub(0, 1)
  |> should.equal(99)

  day_1.wrapping_sub(99, 505)
  |> should.equal(94)
}
