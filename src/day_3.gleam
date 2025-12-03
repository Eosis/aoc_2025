import gleam.{type Int}
import gleam/function
import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_3.txt")
  do_part_1(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> list.map(get_best_value)
  |> int.sum
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_3.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  parse_input(input)
  |> list.map(get_best_values([], _, 12))
  |> list.map(fn(inner) {
    list.fold(inner, 0, fn(acc, item) { { acc * 10 } + item })
  })
  |> int.sum
}

pub fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(string_to_digits)
}

fn string_to_digits(input: String) -> List(Int) {
  string.to_graphemes(input)
  |> list.map(fn(char) {
    let assert Ok(digit) = int.parse(char)
    digit
  })
}

fn get_best_value(input: List(Int)) -> Int {
  let assert Ok(#(tens, idx)) =
    list.take(input, list.length(input) - 1)
    |> list.index_map(fn(val, idx) { #(val, idx) })
    |> list.max(fn(a, b) { int.compare(a.0, b.0) })

  let rem = list.drop(input, idx + 1)
  let assert Ok(units) =
    rem
    |> list.max(int.compare)
  tens * 10 + units
}

fn get_best_values(acc: List(Int), input: List(Int), nth: Int) -> List(Int) {
  case nth {
    0 -> list.reverse(acc)
    n -> {
      let drop_from_end = n - 1
      let assert Ok(#(digit, idx)) =
        list.take(input, list.length(input) - drop_from_end)
        |> list.index_map(fn(val, idx) { #(val, idx) })
        |> list.max(fn(a, b) { int.compare(a.0, b.0) })
      get_best_values([digit, ..acc], list.drop(input, idx + 1), n - 1)
    }
  }
}
