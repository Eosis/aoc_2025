import atto
import atto/text
import day_10
import day_10/input_parser
import day_10/machine_description.{MachineDescription}
import gleam/bool
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
  day_10.do_part_2("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}")
  |> pprint.debug
}

pub fn parse_input_test() {
  use <- bool.guard(when: True, return: Nil)
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
  echo day_10.get_lowest_presses_for_joltage(
    [],
    MachineDescription(
      glearray.from_list([False, True, True, False]),
      [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]],
      [1, 0, 2, 1],
    ),
  )
}

fn combos(take take: Int, from from: List(a)) -> List(List(a)) {
  case take {
    1 -> {
      list.map(from, fn(item) { [item] })
    }
    _ -> {
      from
      |> list.flat_map(fn(first: a) {
        combos(take: { take - 1 }, from: from)
        |> echo
        |> list.map(fn(inner: List(a)) { [first, ..inner] })
      })
    }
  }
}
