import atto
import atto/text
import day_10
import day_10/input_parser
import day_10/machine_description.{MachineDescription}
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
  todo
  day_10.do_part_2(test_input)
  |> pprint.debug
}

pub fn parse_input_test() {
  todo
  test_input
  |> text.new
  |> atto.run(input_parser.day_10_input(), _, Nil)
  |> should.equal(
    Ok([
      MachineDescription(
        glearray.from_list([False, True, True, False]),
        [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]],
        [3, 5, 4, 7],
      ),
      MachineDescription(
        glearray.from_list([False, False, False, True, False]),
        [[0, 2, 3, 4], [2, 3], [0, 4], [0, 1, 2], [1, 2, 3, 4]],
        [7, 5, 12, 7, 2],
      ),
      MachineDescription(
        glearray.from_list([False, True, True, True, False, True]),
        [[0, 1, 2, 3, 4], [0, 3, 4], [0, 1, 2, 4, 5], [1, 2]],
        [10, 11, 11, 5, 10, 5],
      ),
    ]),
  )
}

pub fn best_presses_test() {
  echo day_10.work_out_best_presses(
    MachineDescription(
      glearray.from_list([False, True, True, False]),
      [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]],
      [1, 0, 2, 1],
    ),
  )
}
