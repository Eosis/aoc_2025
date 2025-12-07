import gleam.{type Int}
import gleam/function
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
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
  parse_input(input)
  |> todo
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
  |> list.map(fn(row) { echo regexp.split(string_split_regexp, echo row) })
  |> list.transpose
  |> list.map(fn(computation) {
    let #(values, op) =
      echo list.split(computation, list.length(computation) - 1)
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

fn do_calculation(calculation) -> Int {
  let #(op, values) = calculation
  let assert Ok(result) = case op {
    Add -> list.reduce(values, int.add)
    Multiply -> list.reduce(values, int.multiply)
  }
  result
}
