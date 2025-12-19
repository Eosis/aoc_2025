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
  |> list.map(work_out_best_presses)
  |> int.sum
}

pub fn work_out_best_presses(machine: MachineDescription) -> Int {
  let initial_joltage =
    list.index_map(machine.joltage, fn(_, idx) { #(idx, 0) })
    |> dict.from_list
  case do_work_out_best_presses(Running(0), machine, initial_joltage, []) {
    Done(presses) -> presses
    _ -> panic as "This should not happen"
  }
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

fn do_work_out_best_presses(
  presses_state: State,
  machine: MachineDescription,
  joltage: Dict(Int, Int),
  chosen: List(Int),
) -> State {
  let desired =
    list.index_map(machine.joltage, fn(item, idx) { #(idx, item) })
    |> dict.from_list
  use <- bool.lazy_guard(when: desired == joltage, return: fn() {
    echo Done(get_presses(presses_state))
  })
  use <- bool.lazy_guard(when: blown(joltage, desired), return: fn() {
    echo Blown
  })

  echo chosen as "Continuing..."
  let new_state = increment_presses(presses_state)
  // Press all in turn and descend in.
  let result =
    machine.buttons
    |> list.index_map(fn(effects, idx) {
      let new_chosen = [idx, ..chosen]
      let joltages_after_press =
        list.fold(from: joltage, over: effects, with: increment_joltages)
      do_work_out_best_presses(
        new_state,
        machine,
        joltages_after_press,
        new_chosen,
      )
    })
    |> list.filter(fn(state) {
      case state {
        Done(_) -> True
        _ -> False
      }
    })
    |> list.sort(fn(a, b) {
      let a = get_presses(a)
      let b = get_presses(b)
      order.reverse(int.compare)(a, b)
    })
    |> list.first

  case result {
    Error(Nil) -> Blown
    Ok(inner) -> inner
  }
}

fn increment_joltages(current: Dict(Int, Int), to_inc: Int) -> Dict(Int, Int) {
  dict.upsert(current, to_inc, fn(entry) {
    case entry {
      None -> panic as "We should always be incrementing a thing already there"
      Some(joltage) -> joltage + 1
    }
  })
}

fn blown(current: Dict(Int, Int), desired: Dict(Int, Int)) -> Bool {
  let assert Ok(zipped) =
    list.strict_zip(dict.to_list(current), dict.to_list(desired))
  list.any(in: zipped, satisfying: fn(item) {
    let #(#(_, current), #(_, desired)) = item
    current > desired
  })
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
    |> echo
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
