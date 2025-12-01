import gleam.{type Int}
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_1.txt")
  do_part_1(input)
}

pub fn do_part_1(input: String) -> Int {
  let instructions = parse_input(input)
  let initial = LockState(current: 50, zeros_seen: 0)
  list.fold(instructions, initial, run_instruction).zeros_seen
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_1.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  let instructions = parse_input(input)
  let initial = LockState(current: 50, zeros_seen: 0)
  list.fold(instructions, initial, run_part_two_instruction).zeros_seen
}

pub fn parse_input(input: String) -> List(Instruction) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(parse_instruction)
}

pub type Instruction {
  L(amount: Int)
  R(amount: Int)
}

fn parse_instruction(instruction: String) -> Instruction {
  case instruction {
    "L" <> rest -> {
      let assert Ok(amount) = int.parse(rest)
      L(amount: amount)
    }
    "R" <> rest -> {
      let assert Ok(amount) = int.parse(rest)
      R(amount: amount)
    }
    _ -> {
      echo instruction as "This was an invalid instruction!"
      panic as "Invalid instruction supplied"
    }
  }
}

pub type LockState {
  LockState(current: Int, zeros_seen: Int)
}

fn run_instruction(state: LockState, instruction: Instruction) -> LockState {
  let LockState(current:, zeros_seen:) = state
  let next_shown = case instruction {
    L(amount) -> wrapping_sub(current, amount)
    R(amount) -> wrapping_add(current, amount)
  }

  let zeros_seen = case next_shown {
    0 -> zeros_seen + 1
    _ -> zeros_seen
  }

  LockState(current: next_shown, zeros_seen:)
}

fn run_part_two_instruction(
  state: LockState,
  instruction: Instruction,
) -> LockState {
  let LockState(current:, zeros_seen:) = state
  let ResultAndHits(result:, hits:) = case instruction {
    L(amount) -> wrapping_sub_with_hits(current, amount)
    R(amount) -> wrapping_add_with_hits(current, amount)
  }

  LockState(current: result, zeros_seen: zeros_seen + hits)
}

pub fn wrapping_add(current current: Int, to_add addend: Int) -> Int {
  { current + addend } % 100
}

pub fn wrapping_sub(current current: Int, to_subtract subtrahend: Int) -> Int {
  let result = { current - subtrahend } % 100
  case result < 0 {
    True -> 100 + result
    False -> result
  }
}

pub type ResultAndHits {
  ResultAndHits(result: Int, hits: Int)
}

pub fn wrapping_add_with_hits(
  current current: Int,
  to_add addend: Int,
) -> ResultAndHits {
  let result = current + addend
  ResultAndHits(result: result % 100, hits: result / 100)
}

pub fn wrapping_sub_with_hits(
  current current: Int,
  to_subtract subtrahend: Int,
) -> ResultAndHits {
  let without_wrap = current - subtrahend
  let offset = case current {
    0 -> 0
    _ -> 1
  }
  let hits = case int.compare(without_wrap, 0) {
    Gt -> 0
    Eq -> offset
    Lt -> offset + { int.negate(without_wrap / 100) }
  }

  ResultAndHits(result: wrapping_sub(current, subtrahend), hits:)
}
