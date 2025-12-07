import day_6
import gleeunit/should

const test_input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +"

pub fn part_1_test() {
  day_6.do_part_1(test_input)
  |> should.equal(4_277_556)
}
// pub fn parsing_test() {
//   day_6.parse_input(test_input)
//   |> should.equal(
//     #([Range(3, 5), Range(10, 14), Range(16, 20), Range(12, 18)], [
//       32,
//       17,
//       11,
//       8,
//       5,
//       1,
//     ]),
//   )
// }

// pub fn part_2_test() {
//   day_6.do_part_2(test_input)
//   |> should.equal(14)
// }
