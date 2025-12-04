import gleam.{type Int}
import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_4.txt")
  do_part_1(input)
}

pub fn do_part_1(input: String) -> Int {
  let floor = parse_input(input)
  generate_locations_to_check(floor)
  |> list.map(count_neighbouring_rolls(_, floor))
  |> list.filter(fn(rolls) { rolls < 4 })
  |> list.length
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_4.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  parse_input(input)
  |> count_total_removable
}

fn count_total_removable(floor: Floor) -> Int {
  do_count_total_removable(0, floor)
}

fn do_count_total_removable(acc: Int, floor: Floor) -> Int {
  let removable =
    generate_locations_to_check(floor)
    |> list.map(fn(location) {
      #(location, count_neighbouring_rolls(location, floor))
    })
    |> list.filter(fn(location_status) { location_status.1 < 4 })
  let number_to_remove = list.length(removable)

  case number_to_remove {
    0 -> acc
    _ -> {
      let locations_to_remove = list.map(removable, fn(tup) { tup.0 })
      let after_removal =
        free_up_locations(floor.locations, locations_to_remove)
      do_count_total_removable(
        acc + number_to_remove,
        Floor(bounds: floor.bounds, locations: after_removal),
      )
    }
  }
}

fn free_up_locations(
  floor_locations: Dict(#(Int, Int), Location),
  to_remove: List(#(Int, Int)),
) -> Dict(#(Int, Int), Location) {
  list.fold(over: to_remove, from: floor_locations, with: fn(acc, location) {
    dict.upsert(acc, location, fn(_) { Free })
  })
}

pub type Floor {
  Floor(bounds: #(Int, Int), locations: Dict(#(Int, Int), Location))
}

fn generate_locations_to_check(floor: Floor) -> List(#(Int, Int)) {
  let Floor(locations:, bounds: #(y_bound, x_bound)) = floor
  list.range(0, y_bound - 1)
  |> list.flat_map(fn(y) {
    list.range(0, x_bound - 1)
    |> list.map(fn(x) { #(y, x) })
  })
  |> list.filter(fn(location) {
    let assert Ok(location) = dict.get(locations, location)
      as { "Should be retrievable at" <> string.inspect(location) }
    case location {
      Roll -> True
      _ -> False
    }
  })
}

pub fn parse_input(input: String) -> Floor {
  let input = string.trim(input)
  let locations =
    string.split(input, "\n")
    |> list.map(fn(line) {
      string.to_graphemes(line) |> list.map(location_from_char)
    })
    |> list.index_map(fn(line, y) {
      list.index_map(line, fn(location, x) { #(#(y, x), location) })
    })
    |> list.flatten
    |> dict.from_list

  let #(y, x) = #(
    string.split(input, "\n") |> list.length,
    string.split(input, "\n")
      |> list.first
      |> fn(a) {
        case a {
          Ok(first) -> string.length(first)
          Error(_) -> panic as "You wot?"
        }
      },
  )
  Floor(locations:, bounds: #(y, x))
}

pub type Location {
  Roll
  Free
}

fn count_neighbouring_rolls(location: #(Int, Int), floor: Floor) -> Int {
  surrounding_coordinates(location, floor.bounds)
  |> list.map(fn(location) {
    let assert Ok(value) = dict.get(floor.locations, location)
      as "Couldn't find a thing..."
    value
  })
  |> list.count(fn(at_location) {
    case at_location {
      Roll -> True
      _ -> False
    }
  })
}

fn location_from_char(item: String) {
  case item {
    "." -> Free
    "@" -> Roll
    _ -> panic as { "What the heck was this?!: " <> item }
  }
}

pub fn surrounding_coordinates(coordinates: #(Int, Int), bounds: #(Int, Int)) {
  let #(y, x) = coordinates
  let #(y_size, x_size) = bounds
  let diffs = [-1, 0, 1]
  let ys_to_check = list.map(diffs, fn(diff) { diff + y })
  let xs_to_check = list.map(diffs, fn(diff) { diff + x })
  let combos =
    list.flat_map(ys_to_check, fn(y_to_check) {
      list.map(xs_to_check, fn(x_to_check) { #(y_to_check, x_to_check) })
    })
  list.filter(combos, fn(check) { check != coordinates })
  |> list.filter(fn(coordinates) {
    let #(y, x) = coordinates
    y < y_size && y >= 0 && x < x_size && x >= 0
  })
}
