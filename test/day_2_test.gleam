import day_2.{Range}
import gleeunit/should

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

pub fn part_1_test() {
  day_2.do_part_1(test_input)
  |> should.equal(1_227_775_554)
}

pub fn parsing_test() {
  day_2.parse_input(test_input)
  |> should.equal([
    Range(11, 22),
    Range(95, 115),
    Range(998, 1012),
    Range(1_188_511_880, 1_188_511_890),
    Range(222_220, 222_224),
    Range(1_698_522, 1_698_528),
    Range(446_443, 446_449),
    Range(38_593_856, 38_593_862),
    Range(565_653, 565_659),
    Range(824_824_821, 824_824_827),
    Range(2_121_212_118, 2_121_212_124),
  ])
}

pub fn generate_list_test() {
  day_2.generate_list_to_test([Range(5, 10), Range(15, 19)])
  |> should.equal([5, 6, 7, 8, 9, 10, 15, 16, 17, 18, 19])
}

pub fn are_repeaty_test() {
  day_2.is_repeaty(123_123)
  |> should.be_true

  day_2.is_repeaty(23_513)
  |> should.be_false

  day_2.is_repeaty(11)
  |> should.be_true
}
