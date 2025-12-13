import day_10.{MachineDescription}
import gleam/io
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
  Ok(Nil)
}

pub fn parse_input_test() {
  test_input
  |> day_10.parse_input
  |> list.map(day_10.format_machine_description)
  |> pprint.debug
}

import atto
import atto/ops
import atto/text
import atto/text_util

pub fn better_parser_test() {
  echo atto.run(buttons(), text.new("(8,0,1,3) (8,1,2)"), Nil)
  echo atto.run(
    machine_description(),
    text.new("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"),
    Nil,
  )
}

fn machine_description() {
  use <- atto.label("Machine Description")
  use lights <- atto.do(lights())
  use buttons <- atto.do(buttons())
  use joltage <- atto.do(joltage() |> text_util.ws())
  let lights = glearray.from_list(lights)
  atto.pure(MachineDescription(lights:, buttons:, joltage:))
}

fn lights() {
  use <- atto.label("Lights")
  ops.between(
    atto.token("[") |> text_util.ws(),
    ops.some(ops.choice([atto.token("#"), atto.token(".")])),
    atto.token("]") |> text_util.ws(),
  )
  |> atto.map(fn(inner) {
    inner
    |> list.map(fn(choose) {
      case choose {
        "#" -> True
        "." -> False
        _ -> panic as "Invalid input, should be caught by the parser"
      }
    })
  })
}

fn buttons() {
  use <- atto.label("Button")

  let button =
    ops.between(
      atto.token("(") |> text_util.ws(),
      ops.sep1(
        text_util.decimal() |> text_util.ws(),
        atto.token(",") |> text_util.ws(),
      ),
      atto.token(")") |> text_util.ws(),
    )

  ops.sep1(button, text_util.hspaces())
}

fn joltage() {
  use <- atto.label("Joltage")
  ops.between(
    atto.token("{") |> text_util.ws(),
    ops.sep1(
      text_util.decimal() |> text_util.ws(),
      atto.token(",") |> text_util.ws(),
    ),
    atto.token("}") |> text_util.ws(),
  )
}
