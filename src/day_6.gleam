import gleam.{type Int}
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_6.txt")
  do_part_1(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> list.map(do_calculation)
  |> int.sum
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_6.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  parse_part_2_input(input)
  |> list.map(do_calculation)
  |> int.sum
}

pub type Op {
  Add
  Multiply
}

pub fn parse_input(input: String) -> List(#(Op, List(Int))) {
  let assert Ok(string_split_regexp) = regexp.from_string("\\s+")
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(fn(row) { regexp.split(string_split_regexp, row) })
  |> list.transpose
  |> list.map(fn(computation) {
    let #(values, op) = list.split(computation, list.length(computation) - 1)
    let assert Ok(values) =
      list.map(values, int.parse)
      |> result.all
    let op = case op {
      ["+"] -> Add
      ["*"] -> Multiply
      _ ->
        panic as {
          "Should be only + or * !!!, but I got " <> string.inspect(op)
        }
    }
    #(op, values)
  })
}

pub fn parse_part_2_input(input: String) -> List(#(Op, List(Int))) {
  split_to_individual_calcs(input)
  |> list.map(fn(item: #(OpString, List(List(String)))) {
    let #(op_string, cephy_operands) = item
    #(op_from_op_string(op_string), parse_cephy_operands(cephy_operands))
  })
}

fn op_from_op_string(op_string) -> Op {
  case op_string {
    AddOpString(_) -> Add
    MultiplyOpString(_) -> Multiply
  }
}

fn do_calculation(calculation) -> Int {
  let #(op, values) = calculation
  let assert Ok(result) = case op {
    Add -> list.reduce(values, int.add)
    Multiply -> list.reduce(values, int.multiply)
  }
  result
}

pub fn split_to_individual_calcs(
  input: String,
) -> List(#(OpString, List(List(String)))) {
  let lines = string.split(input, "\n")
  let assert Ok(operators) = list.last(lines)
  let op_strings = op_strings_from_operation_row(operators)
  let operands =
    list.take(lines, list.length(lines) - 1)
    |> list.map(string.to_graphemes)
  do_split_to_individual_calcs(from: [], operands:, operators: op_strings)
}

fn do_split_to_individual_calcs(
  from acc: List(#(OpString, List(List(String)))),
  operands operands: List(List(String)),
  operators operators: List(OpString),
) {
  case operators {
    [] -> list.reverse(acc)
    [op_string, ..remaining_op_strings] -> {
      let to_take = op_string.length
      let #(new_operands, remaining_operands) =
        list.map(operands, fn(row) -> #(List(String), List(String)) {
          let #(operands, rest) = list.split(row, to_take)
          // Take another space off the thing. !! Fiddly off by one shite.
          #(operands, list.drop(rest, 1))
        })
        |> list.unzip
      let new_acc = [#(op_string, new_operands), ..acc]
      do_split_to_individual_calcs(
        new_acc,
        remaining_operands,
        remaining_op_strings,
      )
    }
  }
}

pub type OpString {
  AddOpString(length: Int)
  MultiplyOpString(length: Int)
}

pub fn split_into_operations(input: String) -> List(String) {
  do_split_into_op_strings(list.new(), string.to_graphemes(input))
}

fn do_split_into_op_strings(
  acc: List(String),
  input: List(String),
) -> List(String) {
  case input {
    [first, ..rest] -> {
      let #(to_take, remainder) =
        list.split_while(rest, fn(grapheme) { grapheme == " " })
      let new_string_graphemes = [first, ..to_take]
      do_split_into_op_strings(
        [string.join(new_string_graphemes, ""), ..acc],
        remainder,
      )
    }
    [] -> {
      // !! HACK ALERT !!
      // We must fix the last value to be one space longer, as this is not in the input
      // This is a hack, I'm not sure the best way to handle this, nothing seems nice without
      // actually invoking a proper parser, maybe?
      // !! HACK ALERT !!
      case acc {
        [] -> acc
        [head, ..rest] -> list.reverse([head <> " ", ..rest])
      }
    }
  }
}

pub fn op_string_from_operation(input: String) {
  case input {
    "+" <> _ -> AddOpString(string.length(input) - 1)
    "*" <> _ -> MultiplyOpString(string.length(input) - 1)
    _ -> panic as "unexpected"
  }
}

pub fn op_strings_from_operation_row(input: String) -> List(OpString) {
  input
  |> split_into_operations
  |> list.map(op_string_from_operation)
}

pub fn parse_cephy_operands(operands: List(List(String))) -> List(Int) {
  list.transpose(operands)
  |> list.map(fn(operand) {
    list.fold(over: operand, from: 0, with: fn(acc, next) {
      case int.parse(next) {
        Ok(number) -> { acc * 10 } + number
        Error(_) -> acc
      }
    })
  })
}
