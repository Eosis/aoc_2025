import day_1.{L, R, ResultAndHits}
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

const test_input = "L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82"

pub fn part_1_test() {
  test_input
  |> day_1.do_part_1
  |> should.equal(3)
}

pub fn part_2_test() {
  test_input
  |> day_1.do_part_2
  |> should.equal(6)
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

pub fn wrapping_add_with_hits_test() {
  day_1.wrapping_add_with_hits(current: 99, to_add: 5)
  |> should.equal(ResultAndHits(result: 4, hits: 1))

  day_1.wrapping_add_with_hits(current: 99, to_add: 105)
  |> should.equal(ResultAndHits(result: 4, hits: 2))

  day_1.wrapping_add_with_hits(current: 99, to_add: 205)
  |> should.equal(ResultAndHits(result: 4, hits: 3))

  day_1.wrapping_add_with_hits(current: 50, to_add: 7)
  |> should.equal(ResultAndHits(result: 57, hits: 0))
}

pub fn wrapping_sub_with_hits_test() {
  day_1.wrapping_sub_with_hits(current: 99, to_subtract: 5)
  |> should.equal(ResultAndHits(result: 94, hits: 0))

  day_1.wrapping_sub_with_hits(current: 5, to_subtract: 5)
  |> should.equal(ResultAndHits(result: 0, hits: 1))

  day_1.wrapping_sub_with_hits(current: 5, to_subtract: 105)
  |> should.equal(ResultAndHits(result: 0, hits: 2))

  day_1.wrapping_sub_with_hits(current: 0, to_subtract: 8)
  |> should.equal(ResultAndHits(result: 92, hits: 0))

  day_1.wrapping_sub_with_hits(current: 0, to_subtract: 108)
  |> should.equal(ResultAndHits(result: 92, hits: 1))
}
