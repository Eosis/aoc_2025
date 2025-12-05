import day_5.{Range}
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
  |> should.equal(
    #([Range(3, 5), Range(10, 14), Range(16, 20), Range(12, 18)], [
      32,
      17,
      11,
      8,
      5,
      1,
    ]),
  )
}

pub fn part_2_test() {
  day_5.do_part_2(test_input)
  |> should.equal(14)
}

pub fn overlapping_test() {
  let a = Range(low: 5, high: 10)
  let b = Range(low: 7, high: 15)

  day_5.overlapping(a, b)
  |> should.be_true

  day_5.overlapping(b, a)
  |> should.be_true

  let a = Range(low: 1, high: 4)
  let b = Range(low: 15, high: 15)
  day_5.overlapping(a, b)
  |> should.be_false

  day_5.overlapping(b, a)
  |> should.be_false

  let a = Range(low: 1, high: 1)
  let b = Range(low: 1, high: 1)

  day_5.overlapping(a, b)
  |> should.be_true

  let a = Range(low: 1, high: 1)
  let b = Range(low: 2, high: 2)

  day_5.overlapping(a, b)
  |> should.be_false
}

pub fn de_overlap_ranges_test() {
  [
    Range(low: 1, high: 10),
    Range(low: 15, high: 20),
    Range(low: 30, high: 35),
    Range(low: 35, high: 36),
    Range(low: 60, high: 65),
    Range(low: 58, high: 61),
    Range(100, 110),
    Range(90, 120),
  ]
  |> day_5.de_overlap_ranges
  |> echo
}

pub fn de_overlap_test() {
  let a = Range(low: 1, high: 10)
  let b = Range(low: 2, high: 10)
  day_5.de_overlap(b, a)
  |> should.equal(Range(low: 1, high: 10))
}
