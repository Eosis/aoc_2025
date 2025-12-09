import day_9/point.{type Point, Point}
import gleam.{type Int}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_9.txt")
  do_part_1(input)
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_9.txt")
  do_part_2(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> list.combination_pairs
  |> list.map(fn(points) {
    let #(a, b) = points
    rectangle_size(a, b)
  })
  |> list.max(int.compare)
  |> result.lazy_unwrap(fn() { -1 })
}

pub fn do_part_2(input: String) -> Int {
  todo
}

fn parse_input(input: String) -> List(Point) {
  input
  |> string.split("\n")
  |> list.map(fn(item) {
    item
    |> string.split(",")
    |> list.map(fn(coordinate) {
      let assert Ok(coordinate) = int.parse(coordinate)
      coordinate
    })
    |> fn(coordinates: List(Int)) {
      case coordinates {
        [x, y] -> Point(x:, y:)
        otherwise ->
          panic as { "Invalid coordinates" <> string.inspect(otherwise) }
      }
    }
  })
}

fn rectangle_size(a: Point, b: Point) -> Int {
  int.absolute_value({ { a.x - b.x } + 1 } * { { a.y - b.y } + 1 })
}
