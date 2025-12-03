import gleam.{type Int}
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_2.txt")
  do_part_1(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> generate_list_to_test
  |> list.filter(keeping: is_repeaty)
  |> int.sum
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_2.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  todo
}

pub type Range {
  Range(start: Int, end: Int)
}

pub fn parse_input(input: String) -> List(Range) {
  input
  |> string.split(",")
  |> echo
  |> list.map(string.trim)
  |> list.map(parse_range)
}

fn parse_range(input: String) -> Range {
  let parsed_ints: List(Int) =
    input
    |> string.split("-")
    |> list.map(int.parse)
    |> list.map(fn(res) {
      result.lazy_unwrap(res, fn() {
        let to_print = "failed to parse this" <> string.inspect(res)
        panic as to_print
      })
    })
  case parsed_ints {
    [start, end] -> Range(start:, end:)
    _ -> panic as "parsed a weird number of ints, man!"
  }
}

// Yeah, let's not worry about memory, it is not like there is a RAM shortage at the moment
// (currently ~$900 for 2 32GB sticks 😱) just put them all in memory, baby!

/// ⚠️ Assuming they don't overlap
pub fn generate_list_to_test(input: List(Range)) -> List(Int) {
  input
  |> list.flat_map(fn(range) -> List(Int) {
    let Range(start:, end:) = range
    list.range(start, end)
  })
}

pub fn is_repeaty(input: Int) -> Bool {
  let as_string =
    input
    |> int.to_string
  case string.length(as_string) % 2 {
    1 -> False
    0 -> {
      let half_length = string.length(as_string) / 2
      let start = string.slice(as_string, at_index: 0, length: half_length)
      let end =
        string.slice(as_string, at_index: half_length, length: half_length)
      start == end
    }
    _ -> panic as "Compiler too dumb to work out this is unrepresentable"
  }
}
