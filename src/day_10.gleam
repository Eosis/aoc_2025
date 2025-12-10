import gleam/int
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import glearray.{type Array}
import pprint

import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_10.txt")
  do_part_1(input)
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_10.txt")
  do_part_2(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> list.map(find_best)
  |> int.sum
}

pub fn do_part_2(input: String) -> Int {
  parse_input(input)
  |> todo
}

pub type MachineDescription {
  MachineDescription(lights: Array(Bool), buttons: List(List(Int)), wot: Nil)
}

pub fn parse_input(input: String) -> List(MachineDescription) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let parts = string.split(line, " ")
    let #(lights, rest) = list.split(parts, 1)
    let assert Ok(lights) = list.first(lights)
    let #(buttons, _wot) = list.split(rest, { list.length(rest) - 1 })
    MachineDescription(
      lights: glearray.from_list(parse_lights(lights)),
      buttons: parse_buttons(buttons),
      wot: Nil,
    )
  })
}

fn parse_lights(description: String) -> List(Bool) {
  let description = string.to_graphemes(description)
  let #(_, rest) = list.split(description, 1)
  let #(lights, _) = list.split(rest, { list.length(rest) - 1 })
  list.map(lights, fn(light) {
    case light {
      "#" -> True
      "." -> False
      _ -> panic as "Invalid input!"
    }
  })
}

fn parse_buttons(descriptions: List(String)) -> List(List(Int)) {
  list.map(descriptions, fn(description) {
    description
    |> string.slice(1, string.length(description) - 2)
    |> string.split(",")
    |> list.map(int.parse)
    |> result.all
    |> result.lazy_unwrap(fn() { panic as "Not okay, man" })
  })
}

fn find_best(md: MachineDescription) -> Int {
  let MachineDescription(lights: desired_lights, buttons:, wot:) = md

  // fold until one found
  list.range(1, list.length(buttons))
  |> list.fold_until(
    from: Error(Nil),
    with: fn(found: Result(Int, Nil), to_take: Int) {
      case attempt_solution_with_n_presses(to_take, desired_lights, buttons) {
        True -> Stop(Ok(to_take))
        False -> Continue(found)
      }
    },
  )
  |> result.lazy_unwrap(fn() {
    panic as { "This one had no solution?" <> format_machine_description(md) }
  })
}

fn attempt_solution_with_n_presses(
  to_take: Int,
  desired: Array(Bool),
  buttons: List(List(Int)),
) -> Bool {
  list.combinations(buttons, to_take)
  |> list.map(apply_button_presses(glearray.length(desired)))
  |> list.any(fn(result) { result == desired })
}

fn apply_button_presses(
  number_of_lights: Int,
) -> fn(List(List(Int))) -> Array(Bool) {
  fn(presses: List(List(Int))) {
    let initial: Array(Bool) =
      list.range(1, number_of_lights)
      |> list.map(fn(_) { False })
      |> glearray.from_list
    list.fold(
      over: presses,
      from: initial,
      with: toggle_lights_from_button_press,
    )
  }
}

fn toggle_lights_from_button_press(
  lights: Array(Bool),
  button: List(Int),
) -> Array(Bool) {
  list.fold(
    from: lights,
    over: button,
    with: fn(lights: Array(Bool), button: Int) {
      let assert Ok(current) = glearray.get(lights, button)
      let next = !current
      let assert Ok(lights) = glearray.copy_set(lights, button, next)
      lights
    },
  )
}

pub fn format_machine_description(md: MachineDescription) -> String {
  let MachineDescription(lights:, buttons:, wot:) = md
  let lights = glearray.to_list(lights)
  pprint.format(lights) <> "\n" <> pprint.format(buttons)
}
