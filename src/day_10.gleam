import atto
import atto/text
import day_10/input_parser
import day_10/machine_description.{type MachineDescription, MachineDescription}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/order
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
  let assert Ok(mds) =
    atto.run(input_parser.day_10_input(), text.new(input), Nil)
  mds
  |> list.map(find_best)
  |> int.sum
}

pub fn do_part_2(input: String) -> Int {
  let assert Ok(mds) =
    atto.run(input_parser.day_10_input(), text.new(input), Nil)
  mds
  |> list.map(get_lowest_presses_for_joltage([], _))
  |> int.sum
}

pub type State {
  Running(presses: Int)
  Done(presses: Int)
  Blown
}

fn get_presses(state: State) -> Int {
  case state {
    Blown -> panic as "Shouldn't get called when blown"
    Running(presses) | Done(presses) -> presses
  }
}

fn increment_presses(state: State) -> State {
  case state {
    Blown -> Blown
    Running(presses) -> Running(presses + 1)
    _ -> panic as "Shouldn't increment a done thing"
  }
}

fn increment_joltages(
  current: Dict(Int, Int),
  press: Int,
  button_map: Dict(Int, List(Int)),
) -> Dict(Int, Int) {
  let assert Ok(to_increment) = dict.get(button_map, press)

  list.fold(over: to_increment, from: current, with: fn(acc, idx) {
    dict.upsert(acc, idx, fn(entry) {
      case entry {
        None ->
          panic as {
            "We should always be incrementing a thing already there "
            <> string.inspect(current)
            <> string.inspect(idx)
          }
        Some(joltage) -> joltage + 1
      }
    })
  })
}

fn blown(current: Dict(Int, Int), desired: List(Int)) -> Bool {
  let desired =
    list.index_map(desired, fn(item, idx) { #(idx, item) })
    |> dict.from_list
  let assert Ok(zipped) =
    list.strict_zip(dict.to_list(current), dict.to_list(desired))
  list.any(in: zipped, satisfying: fn(item) {
    let #(#(_, current), #(_, desired)) = item
    current > desired
  })
}

fn done(current: Dict(Int, Int), desired: List(Int)) -> Bool {
  let desired =
    list.index_map(desired, fn(item, idx) { #(idx, item) })
    |> dict.from_list
  desired == current
}

fn find_best(md: MachineDescription) -> Int {
  let MachineDescription(_, lights: desired_lights, buttons:) = md

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
  let button_map =
    list.index_map(buttons, fn(item, idx) { #(idx, item) })
    |> dict.from_list
  list.combinations(
    list.range(from: 0, to: { dict.size(button_map) - 1 }),
    to_take,
  )
  |> list.map(apply_button_presses(_, glearray.length(desired), button_map))
  |> list.any(fn(result) { result == desired })
}

fn apply_button_presses(
  presses: List(Int),
  number_of_lights: Int,
  button_map: Dict(Int, List(Int)),
) -> Array(Bool) {
  let initial: Array(Bool) =
    list.range(1, number_of_lights)
    |> list.map(fn(_) { False })
    |> glearray.from_list
  let lights_to_inc =
    presses
    |> list.map(fn(press) {
      let assert Ok(lights_to_inc) = dict.get(button_map, press)
      lights_to_inc
    })

  list.fold(
    over: lights_to_inc,
    from: initial,
    with: toggle_lights_from_button_press,
  )
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
  let MachineDescription(_, lights:, buttons:) = md
  let lights = glearray.to_list(lights)
  pprint.format(lights) <> "\n" <> pprint.format(buttons)
}

// // choose some stuff.
// [0], [1], [2]
// done? -> Keep
// blown? -> drop
// Run check. Are we done?
//   Yes -> Woop de fuckin' do
//   No -> add another of all the buttons, back to the start... By which we mean... call the function again with a different base
// // Check if blown

pub fn get_lowest_presses_for_joltage(
  current_presses: List(List(Int)),
  machine: MachineDescription,
) -> Int {
  let to_check: List(List(Int)) =
    generate_button_combinations(current_presses, machine)
  let sans_blown =
    to_check
    |> list.filter_map(fn(combo) {
      let after = apply_button_combination_to_machine(combo, machine)
      case blown(after, machine.joltage) {
        True -> Error(Nil)
        False -> {
          Ok(combo)
        }
      }
    })
  let found =
    list.find(sans_blown, fn(combo) {
      let after = apply_button_combination_to_machine(combo, machine)
      done(after, machine.joltage)
    })

  use <- bool.lazy_guard(when: list.length(sans_blown) == 0, return: fn() {
    panic as "Whatw"
  })
  case found {
    Ok(inner) -> {
      echo "Found a thing, it was " <> string.inspect(inner)
      list.length(inner)
    }
    Error(_) -> {
      // DIVE DIVE
      get_lowest_presses_for_joltage(sans_blown, machine)
    }
  }
}

fn generate_button_combinations(
  current: List(List(Int)),
  machine: MachineDescription,
) -> List(List(Int)) {
  let button_range = button_range(machine)
  case current {
    [] -> list.map(button_range, fn(button) { [button] })
    combos ->
      combos
      |> list.flat_map(fn(presses) {
        button_range
        |> list.map(fn(new_button) { [new_button, ..presses] })
      })
  }
}

fn apply_button_combination_to_machine(
  combination: List(Int),
  machine: MachineDescription,
) -> Dict(Int, Int) {
  let initial_joltage =
    list.range(0, list.length(machine.joltage) - 1)
    |> list.index_map(fn(_, idx) { #(idx, 0) })
    |> dict.from_list

  list.fold(over: combination, from: initial_joltage, with: fn(acc, press) {
    increment_joltages(acc, press, button_map(machine))
  })
}

fn button_range(machine: MachineDescription) -> List(Int) {
  list.range(from: 0, to: list.length(machine.buttons) - 1)
}

fn button_map(machine: MachineDescription) -> Dict(Int, List(Int)) {
  list.index_map(machine.buttons, fn(item, idx) { #(idx, item) })
  |> dict.from_list
}
