import day_6.{AddOpString, MultiplyOpString}
import gleam/list
import gleam/string
import gleeunit/should

// 123 328  51 64 
//  45 64  387 23 
//   6 98  215 314
// *   +   *   +  
const test_input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

pub fn part_1_test() {
  day_6.do_part_1(test_input)
  |> should.equal(4_277_556)
}

pub fn part_2_test() {
  day_6.do_part_2(test_input)
  |> should.equal(3_263_827)
}

pub fn split_to_individual_calcs_test() {
  day_6.split_to_individual_calcs(test_input)
  |> should.equal([
    #(MultiplyOpString(3), [["1", "2", "3"], [" ", "4", "5"], [" ", " ", "6"]]),
    #(AddOpString(3), [["3", "2", "8"], ["6", "4", " "], ["9", "8", " "]]),
    #(MultiplyOpString(3), [[" ", "5", "1"], ["3", "8", "7"], ["2", "1", "5"]]),
    #(AddOpString(3), [["6", "4", " "], ["2", "3", " "], ["3", "1", "4"]]),
  ])
}

pub fn op_strings_from_operation_row_test() {
  "+   *  +  +     *  "
  |> day_6.split_into_operations()
  |> list.map(day_6.op_string_from_operation)
  |> should.equal([
    AddOpString(3),
    MultiplyOpString(2),
    AddOpString(2),
    AddOpString(5),
    MultiplyOpString(3),
  ])
}

pub fn parse_cephy_operands_test() {
  day_6.parse_cephy_operands([["1", "2", "3"], [" ", "4", "5"], [" ", " ", "6"]])
  |> should.equal([1, 24, 356])
  day_6.parse_cephy_operands([["6", "4", " "], ["2", "3", " "], ["3", "1", "4"]])
  |> should.equal([623, 431, 4])
}
