import atto
import atto/text
import day_10
import day_10/input_parser
import day_10/machine_description.{MachineDescription}
import gleam/dict
import gleam/list
import glearray
import gleeunit/should
import pprint

const test_input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

pub fn part_1_test() {
  day_10.do_part_1(test_input)
  |> should.equal(7)
}

pub fn part_2_test() {
  day_10.do_part_2(
    "[####..##..] (0,4,5,6,7,9) (0,2,4,6,9) (0,1,2,3,5,6,7,8) (1,9) (0,1,3,4,5,6,7,8) (0,1,3,7,9) (3,7) (1,3,4,6,7,9) (1,2,3,4,5,7,8,9) (0,1,2,6,8) (0,1,2,4,8,9) (0,1,2,7,8,9) (1,3,5,7,8) {211,227,193,67,188,46,42,85,204,212}",
  )
  |> pprint.debug
}

pub fn parse_input_test() {
  test_input
  |> text.new
  |> atto.run(input_parser.day_10_input(), _, Nil)
  |> should.equal(
    Ok([
      MachineDescription(
        glearray.from_list([False, True, True, False]),
        dict.from_list([
          #(0, [3]),
          #(1, [1, 3]),
          #(2, [2]),
          #(3, [2, 3]),
          #(4, [0, 2]),
          #(5, [0, 1]),
        ]),
        dict.from_list([#(0, 3), #(1, 5), #(2, 4), #(3, 7)]),
      ),
      MachineDescription(
        glearray.from_list([False, False, False, True, False]),
        dict.from_list([
          #(0, [0, 2, 3, 4]),
          #(1, [2, 3]),
          #(2, [0, 4]),
          #(3, [0, 1, 2]),
          #(4, [1, 2, 3, 4]),
        ]),
        dict.from_list([#(0, 7), #(1, 5), #(2, 12), #(3, 7), #(4, 2)]),
      ),
      MachineDescription(
        glearray.from_list([False, True, True, True, False, True]),
        dict.from_list([
          #(0, [0, 1, 2, 3, 4]),
          #(1, [0, 3, 4]),
          #(2, [0, 1, 2, 4, 5]),
          #(3, [1, 2]),
        ]),
        dict.from_list([
          #(0, 10),
          #(1, 11),
          #(2, 11),
          #(3, 5),
          #(4, 10),
          #(5, 5),
        ]),
      ),
    ]),
  )
}

pub fn best_presses_test() {
  echo day_10.get_lowest_presses_for_joltage(
    [],
    MachineDescription(
      glearray.from_list([False, True, True, False]),
      dict.from_list([
        #(0, [3]),
        #(1, [1, 3]),
        #(2, [2]),
        #(3, [2, 3]),
        #(4, [0, 2]),
        #(5, [0, 1]),
      ]),
      dict.from_list([#(0, 1), #(1, 0), #(2, 2), #(3, 1)]),
    ),
  )
}

pub fn distribute_presses_test() {
  day_10.distribute_presses(3, [2, 3])
  |> should.equal([
    dict.from_list([#(2, 3)]),
    dict.from_list([#(2, 2), #(3, 1)]),
    dict.from_list([#(2, 1), #(3, 2)]),
    dict.from_list([#(3, 3)]),
  ])
}

pub fn lights_to_buttons_test() {
  let machine =
    MachineDescription(
      glearray.from_list([False, True, True, False]),
      dict.from_list([
        #(0, [3]),
        #(1, [1, 3]),
        #(2, [2]),
        #(3, [2, 3]),
        #(4, [0, 2]),
        #(5, [0, 1]),
      ]),
      dict.from_list([#(0, 1), #(1, 0), #(2, 2), #(3, 1)]),
    )
  day_10.joltage_to_applicable_buttons(3, machine)
  |> should.equal([0, 1, 3])
}

pub fn most_restricted_joltage_test() {
  let md =
    MachineDescription(
      joltage: dict.from_list([#(0, 3), #(1, 2), #(2, 1)]),
      lights: glearray.from_list([]),
      buttons: dict.new(),
    )
  day_10.most_restricted_joltage(md)
  |> should.equal(2)

  let assert Ok(md) =
    atto.run(
      input_parser.machine_description(),
      text.new("[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"),
      Nil,
    )
  day_10.most_restricted_joltage(md)
  |> should.equal(4)
}

pub fn eliminate_joltage_test() {
  let machine =
    MachineDescription(
      glearray.from_list([False, True, True, False]),
      dict.from_list([
        #(0, [3]),
        #(1, [1, 3]),
        #(2, [2]),
        #(3, [2, 3]),
        #(4, [0, 2]),
        #(5, [0, 1]),
      ]),
      dict.from_list([#(0, 3), #(1, 5), #(2, 4), #(3, 7)]),
    )
  day_10.eliminate_joltage(machine, 3)
  |> should.equal(MachineDescription(
    glearray.from_list([False, True, True, False]),
    dict.from_list([
      #(2, [2]),
      #(4, [0, 2]),
      #(5, [0, 1]),
    ]),
    dict.from_list([
      #(0, 3),
      #(1, 5),
      #(2, 4),
    ]),
  ))
}

pub fn decrement_joltage_from_presses_test() {
  let machine =
    MachineDescription(
      glearray.from_list([False, True, True, False]),
      dict.from_list([
        #(0, [3]),
        #(1, [1, 3]),
        #(2, [2]),
        #(3, [2, 3]),
        #(4, [0, 2]),
        #(5, [0, 1]),
        #(6, [0]),
      ]),
      dict.from_list([#(0, 1), #(1, 0), #(2, 2), #(3, 1)]),
    )

  dict.from_list([#(2, 1), #(3, 1), #(6, 1)])
  |> day_10.decrement_joltage_from_presses(machine)
  |> should.equal(Ok(dict.from_list([#(0, 0), #(1, 0), #(2, 0), #(3, 0)])))

  dict.from_list([#(2, 1), #(3, 1), #(6, 1), #(6, 2)])
  |> day_10.decrement_joltage_from_presses(machine)
  |> should.equal(Error(Nil))
}

pub fn find_lowest_number_required_test() {
  let md =
    MachineDescription(
      glearray.from_list([]),
      dict.from_list([
        #(1, [2, 3]),
        #(3, [0, 1, 2]),
      ]),
      dict.from_list([
        #(0, 5),
        #(1, 5),
        #(2, 10),
        #(3, 5),
      ]),
    )
  day_10.find_lowest_number_required(md)
  |> should.equal(10)
}
