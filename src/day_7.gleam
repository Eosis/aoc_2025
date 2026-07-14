import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import rememo/memo
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_7.txt")
  do_part_1(input)
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_7.txt")
  do_part_2(input)
}

pub type SplittingState {
  SplittingState(active: Set(Int), offset: Int, splits: Int)
}

pub fn do_part_1(input: String) -> Int {
  let SplitterDescription(start:, splitters:, depth:) = parse_input(input)
  let initial_state =
    SplittingState(active: set.from_list([start]), splits: 0, offset: 0)
  let final =
    int.range(0, depth, with: initial_state, run: fn(state, idx) {
      let SplittingState(active: was, offset: _, splits:) = state
      was
      |> set.to_list
      |> list.fold(from: #(0, set.new()), with: fn(acc, beam_x) {
        case set.contains(splitters, #(idx, beam_x)) {
          True -> {
            let new_active =
              acc.1
              |> set.insert(beam_x - 1)
              |> set.insert(beam_x + 1)
              |> set.delete(beam_x)
            #(acc.0 + 1, new_active)
          }

          False -> #(acc.0, set.insert(acc.1, beam_x))
        }
      })
      |> fn(result) {
        SplittingState(active: result.1, splits: splits + result.0, offset: idx)
      }
    })
  final.splits
}

pub fn do_part_2(input: String) -> Int {
  let description = parse_input(input)
  use count_paths_memo <- memo()
  count_paths(description.start, 0, description, dict.new())
}

fn count_paths(
  x_offset: Int,
  y_offset: Int,
  description: SplitterDescription,
) -> Int {
  let SplitterDescription(start: _, splitters:, depth:) = description
  use <- bool.guard(y_offset > depth, 1)

  case
    splitters
    |> set.contains(#(y_offset, x_offset))
  {
    False -> count_paths(x_offset, y_offset + 1, description)
    True -> {
      let left = count_paths(x_offset - 1, y_offset + 1, description)
      let right = count_paths(x_offset + 1, y_offset + 1, description)
      left + right
    }
  }
}

pub type SplitterDescription {
  SplitterDescription(start: Int, splitters: Set(#(Int, Int)), depth: Int)
}

pub fn parse_input(input: String) -> SplitterDescription {
  let lines =
    input
    |> string.split("\n")
  case lines {
    [first, ..rest] ->
      SplitterDescription(
        start: find_initial(first),
        splitters: enumerate_splitters(rest),
        depth: list.length(rest),
      )
    _ -> panic as "Malformed Input"
  }
}

fn find_initial(first: String) -> Int {
  let result =
    first
    |> string.to_graphemes
    |> list.index_map(fn(item, idx) { #(item, idx) })
    |> list.find_map(fn(thing) {
      let #(item, idx) = thing
      case item {
        "S" -> Ok(idx)
        _ -> Error(Nil)
      }
    })

  case result {
    Ok(idx) -> idx
    _ -> panic as "Malformed input"
  }
}

fn enumerate_splitters(rest: List(String)) -> Set(#(Int, Int)) {
  rest
  |> list.index_fold(from: set.new(), with: fn(acc, line, idx) {
    enumerate_splitters_in_line(idx, line)
    |> set.union(acc)
  })
}

fn enumerate_splitters_in_line(offset: Int, line: String) -> Set(#(Int, Int)) {
  line
  |> string.to_graphemes
  |> list.index_fold(from: [], with: fn(acc, char, idx) {
    case char {
      "^" -> list.prepend(acc, #(offset, idx))
      _ -> acc
    }
  })
  |> set.from_list
}
