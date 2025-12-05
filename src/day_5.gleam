import gleam.{type Int}
import gleam/function
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_5.txt")
  do_part_1(input)
}

pub fn do_part_1(input: String) -> Int {
  let #(ranges, ingredients) = parse_input(input)
  ingredients
  |> list.map(fn(ingredient) {
    list.fold(over: ranges, from: False, with: fn(acc, range) {
      acc || in_range(ingredient, range)
    })
  })
  |> list.count(function.identity)
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_5.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  let input = parse_input(input)
  input.0
  |> de_overlap_ranges
  |> list.map(size_of_range)
  |> int.sum
}

fn add_range_to_set(set: Set(Int), range: Range) -> Set(Int) {
  list.range(range.low, range.high)
  |> list.fold(from: set, with: fn(acc, a) { set.insert(acc, a) })
}

pub type Range {
  Range(low: Int, high: Int)
}

fn in_range(check: Int, range: Range) -> Bool {
  case int.compare(check, range.low) {
    Lt -> False
    Eq -> True
    Gt ->
      case int.compare(check, range.high) {
        Lt -> True
        Eq -> True
        Gt -> False
      }
  }
}

pub fn parse_input(input: String) -> #(List(Range), List(Int)) {
  let assert [ranges, used] = string.split(input, "\n\n")
  let parsed_ranges =
    ranges
    |> string.split("\n")
    |> list.map(fn(range) {
      let assert [Ok(low), Ok(high)] =
        string.split(range, "-")
        |> list.map(int.parse)
      Range(low, high)
    })
  let assert #(used, []) =
    used
    |> string.split("\n")
    |> list.map(int.parse)
    |> result.partition
  #(parsed_ranges, used)
}

pub fn overlapping(a: Range, b: Range) -> Bool {
  case int.compare(a.low, b.low) {
    Gt -> overlapping(b, a)
    // a defo starts earlier or at b
    Eq | Lt ->
      case int.compare(a.high, b.low) {
        Lt -> False
        Eq -> True
        Gt -> True
      }
  }
}

pub fn de_overlap(a: Range, b: Range) -> Range {
  let low = int.min(a.low, b.low)
  let high = int.max(a.high, b.high)
  Range(low:, high:)
}

pub fn de_overlap_ranges(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.sort(fn(a, b) { int.compare(a.low, b.low) })
  |> list.fold(from: [], with: fn(acc, next) {
    case acc {
      [] -> [next]
      [first, ..rest] ->
        case overlapping(first, next) {
          True -> {
            let new = de_overlap(first, next)
            [new, ..rest]
          }
          False -> {
            [next, ..acc]
          }
        }
    }
  })
}

fn size_of_range(range: Range) -> Int {
  { range.high - range.low } + 1
}
