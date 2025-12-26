import atto
import atto/text
import day_10/input_parser
import day_10/machine_description.{type MachineDescription, MachineDescription}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
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
  |> list.map(find_lowest_number_required)
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

fn decrement_joltages(
  starting_joltages: Dict(Int, Int),
  press: Int,
  machine: MachineDescription,
) -> Dict(Int, Int) {
  let assert Ok(to_decrement) = dict.get(machine.buttons, press)
  list.fold(over: to_decrement, from: starting_joltages, with: fn(acc, idx) {
    dict.upsert(acc, idx, fn(entry) {
      case entry {
        None ->
          panic as {
            "We should always be decrementing a thing already there "
            <> string.inspect(starting_joltages)
            <> string.inspect(idx)
          }
        Some(joltage) -> joltage - 1
      }
    })
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
  list.range(1, dict.size(buttons))
  |> list.fold_until(
    from: Error(Nil),
    with: fn(found: Result(Int, Nil), to_take: Int) {
      case attempt_solution_with_n_presses(to_take, desired_lights, md) {
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
  machine: MachineDescription,
) -> Bool {
  list.combinations(
    list.range(from: 0, to: { dict.size(machine.buttons) - 1 }),
    to_take,
  )
  |> list.map(apply_button_presses(_, glearray.length(desired), machine))
  |> list.any(fn(result) { result == desired })
}

fn apply_button_presses(
  presses: List(Int),
  number_of_lights: Int,
  machine: MachineDescription,
) -> Array(Bool) {
  let initial: Array(Bool) =
    list.range(1, number_of_lights)
    |> list.map(fn(_) { False })
    |> glearray.from_list
  let lights_to_inc =
    presses
    |> list.map(fn(press) {
      let assert Ok(lights_to_inc) = dict.get(machine.buttons, press)
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
  let MachineDescription(_, buttons:, joltage:) = md
  pprint.format(buttons)
  <> "\n"
  <> pprint.format(pprint.format(joltage))
  <> "\n"
}

/// This approach is too slow as it still needs to go through stuff to depth 10, or more, which is too complex (n^10)
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
      after == machine.joltage
    })

  use <- bool.lazy_guard(when: sans_blown == [], return: fn() {
    panic as "Whatw"
  })
  case found {
    Ok(inner) -> {
      echo "Found a thing, it was " <> string.inspect(inner)
      list.length(inner)
    }
    Error(_) -> {
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
    list.range(0, dict.size(machine.joltage) - 1)
    |> list.index_map(fn(_, idx) { #(idx, 0) })
    |> dict.from_list

  list.fold(over: combination, from: initial_joltage, with: fn(acc, press) {
    increment_joltages(acc, press, machine.buttons)
  })
}

fn button_range(machine: MachineDescription) -> List(Int) {
  list.range(from: 0, to: dict.size(machine.buttons) - 1)
}

// Set first target, which should be the lowest number in the joltage map
// Work out the combinations which are applicable to satisfying this.
// Eliminate the combinations which have blown the joltage req
// for each of the remaining combinations, make a new machine description which describes
// the reduced problem.
// Recurse into the new problem, adding the offset of the initial presses onto it.

//Utilities required:
//  ✅ lights_to_applicable_buttons(light_idx: Int, machine: MachineDescription) -> List(Int)
//  ✅ distribute the required number of presses across the different things: ditribute_presses(acc: Dict(Int, Int), make: Int, list: List(Int)
//  ✅ most restricted -> returns idx of thing with lowest required joltage (most restricted)
//  find_lowest_number_required(already: Int, machine: MachineDescription) -> Result(Int)

pub fn find_lowest_number_required(machine: MachineDescription) -> Int {
  let assert Ok(result) = find_lowest_number_required_loop(0, machine)
  result
}

// Set first target, which should be the lowest number in the joltage map
// Work out the combinations which are applicable to satisfying this.
// Eliminate the combinations which have blown the joltage req
// for each of the remaining combinations, make a new machine description which describes
// the reduced problem.
// Recurse into the new problem, adding the offset of the initial presses onto it.
fn find_lowest_number_required_loop(
  acc: Int,
  machine: MachineDescription,
) -> Result(Int, Nil) {
  use <- bool.guard(
    when: dict.values(machine.joltage) |> int.sum == 0,
    return: Ok(acc),
  )
  echo "acc is: " <> int.to_string(acc)
  io.println_error(
    "Getting Minimum for: " <> format_machine_description(machine),
  )
  let most_restricted_joltage_idx = most_restricted_joltage(machine)
  io.println_error(
    "Mst restricted joltage idx is "
    <> int.to_string(most_restricted_joltage_idx),
  )
  let assert Ok(most_restricted_joltage_value) =
    dict.get(machine.joltage, most_restricted_joltage_idx)
  let pressable =
    echo joltage_to_applicable_buttons(most_restricted_joltage_idx, machine)
      as "Could press"
  let possible_combos =
    distribute_presses(most_restricted_joltage_value, pressable)
  let possible_remaining_joltages =
    possible_combos
    |> list.filter_map(decrement_joltage_from_presses(_, machine))
    |> echo as "possible remaining"

  let possible_remaining_machines =
    possible_remaining_joltages
    |> list.map(fn(remaining_joltage) {
      // The problem is that we need to eliminate the other zero joltages... Otherwise algo attempts
      let to_elims: List(Int) =
        dict.to_list(remaining_joltage)
        |> list.filter_map(fn(item) {
          let #(key, value) = item
          case value {
            0 -> Ok(key)
            _ -> Error(Nil)
          }
        })
      let new_machine =
        MachineDescription(..machine, joltage: remaining_joltage)
      list.fold(over: to_elims, from: new_machine, with: fn(acc, to_elim) {
        eliminate_joltage(acc, to_elim)
      })
    })

  list.filter_map(possible_remaining_machines, find_lowest_number_required_loop(
    acc + most_restricted_joltage_value,
    _,
  ))
  |> echo
  |> list.max(order.reverse(int.compare))
}

fn press_dict_to_list(presses: Dict(Int, Int)) -> List(Int) {
  dict.fold(over: presses, from: [], with: fn(acc: List(Int), button, times) {
    list.append(acc, list.repeat(button, times:))
  })
}

// fn decrement_joltages(
//   starting_joltages: Dict(Int, Int),
//   press: Int,
//   machine: MachineDescription
// )

pub fn decrement_joltage_from_presses(
  presses: Dict(Int, Int),
  machine: MachineDescription,
) -> Result(Dict(Int, Int), Nil) {
  let after_presses =
    dict.fold(
      from: machine.joltage,
      over: presses,
      with: fn(joltages, button, times) {
        let times = list.range(1, times)
        list.fold(over: times, from: joltages, with: fn(acc, _val) {
          decrement_joltages(acc, button, machine)
        })
      },
    )
  let blown =
    dict.values(after_presses)
    |> list.any(fn(joltage) { joltage < 0 })

  case blown {
    True -> Error(Nil)
    False -> Ok(after_presses)
  }
}

pub fn distribute_presses(
  to_press: Int,
  pressable: List(Int),
) -> List(Dict(Int, Int)) {
  case to_press {
    0 -> []
    to_press -> {
      distribute_presses_loop(
        init_press_dict(pressable),
        to_press - 1,
        pressable,
      )
    }
  }
}

fn distribute_presses_loop(
  acc: List(Dict(Int, Int)),
  to_press: Int,
  pressable: List(Int),
) -> List(Dict(Int, Int)) {
  use <- bool.guard(when: to_press == 0, return: acc)
  let new_acc =
    list.flat_map(pressable, fn(this_press) {
      list.map(acc, fn(presses) {
        dict.upsert(presses, this_press, fn(found) {
          case found {
            None -> 1
            Some(presses) -> presses + 1
          }
        })
      })
    })
  let uniq = list.unique(new_acc)
  distribute_presses_loop(uniq, to_press - 1, pressable)
}

fn init_press_dict(pressable: List(Int)) {
  pressable
  |> list.map(fn(to_press) { dict.insert(dict.new(), to_press, 1) })
}

pub fn joltage_to_applicable_buttons(
  joltage_idx: Int,
  machine: MachineDescription,
) -> List(Int) {
  dict.to_list(machine.buttons)
  |> list.filter_map(fn(affected) {
    let #(key, value) = affected
    case list.contains(value, joltage_idx) {
      True -> Ok(key)
      False -> Error(Nil)
    }
  })
}

pub fn most_restricted_joltage(machine: MachineDescription) -> Int {
  let assert Ok(#(idx, _)) =
    dict.to_list(machine.joltage)
    |> list.max(fn(a, b) {
      let #(_, a_joltage) = a
      let #(_, b_joltage) = b
      order.reverse(int.compare)(a_joltage, b_joltage)
    })
  idx
}

pub fn eliminate_joltage(
  machine: MachineDescription,
  eliminate: Int,
) -> MachineDescription {
  MachineDescription(
    ..machine,
    joltage: dict.delete(machine.joltage, eliminate),
    buttons: dict.filter(machine.buttons, fn(_, affected_joltages) {
      affected_joltages
      |> list.contains(eliminate)
      |> bool.negate
    }),
  )
}
