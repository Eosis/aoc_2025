import glearray.{type Array}

pub type MachineDescription {
  MachineDescription(
    lights: Array(Bool),
    buttons: List(List(Int)),
    joltage: List(Int),
  )
}
