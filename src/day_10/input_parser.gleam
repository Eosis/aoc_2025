import atto
import atto/ops
import atto/text_util
import day_10/machine_description.{MachineDescription}
import gleam/list
import glearray

pub fn day_10_input() {
  ops.many(machine_description())
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
