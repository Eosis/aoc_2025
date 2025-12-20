import gleam/dict.{type Dict}
import glearray.{type Array}

pub type MachineDescription {
  MachineDescription(
    lights: Array(Bool),
    buttons: Dict(Int, List(Int)),
    joltage: Dict(Int, Int),
  )
}
