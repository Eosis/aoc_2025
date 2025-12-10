import day_9/point.{type Point, Point}
import gleam.{type Int}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import pprint

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
  let points = parse_input(input)
  let rectangles = to_rectangles(points)
  let edges = to_edges(points)
  rectangles
  |> list.filter(fn(rectangle) {
    !rectangle_overlaps_any_edge(rectangle, edges)
  })
  |> pprint.debug
  |> list.map(rectangle_area)
  |> list.max(int.compare)
  |> result.lazy_unwrap(fn() { -1 })
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

pub type Edge {
  Edge(a: Point, b: Point)
}

pub type Rectangle {
  Rectangle(top_left: Point, width: Int, height: Int)
}

fn rectangle_overlaps_any_edge(rect: Rectangle, edges: List(Edge)) -> Bool {
  rectangle_edges(rect)
  |> list.any(fn(rectangle_edge) {
    list.any(edges, fn(edge) { intersects(edge, rectangle_edge) })
  })
}

fn rectangle_area(rect: Rectangle) {
  rect.width * rect.height
}

fn to_rectangles(points: List(Point)) -> List(Rectangle) {
  points
  |> list.combination_pairs
  |> list.map(to_rectangle)
}

// Note + 1 here...
pub fn to_rectangle(points: #(Point, Point)) -> Rectangle {
  let #(a, b) = points
  let width = int.absolute_value({ a.x - b.x } + 1)
  let height = int.absolute_value({ a.y - b.y } + 1)
  // assuming top-left is min y, min x
  let top_left = Point(x: int.min(a.x, b.x), y: int.min(a.y, b.y))
  Rectangle(top_left:, width:, height:)
}

pub fn rectangle_edges(rect: Rectangle) -> List(Edge) {
  let Rectangle(top_left:, width:, height:) = rect
  let top =
    Edge(a: rect.top_left, b: Point(x: top_left.x + width - 1, y: top_left.y))
  let right = Edge(a: top.b, b: Point(x: top.b.x, y: top.b.y + { height - 1 }))
  let bottom =
    Edge(a: right.b, b: Point(x: right.b.x - { width - 1 }, y: right.b.y))
  let left = Edge(a: bottom.b, b: top_left)
  [top, right, bottom, left]
}

fn to_edges(points: List(Point)) -> List(Edge) {
  let last_edge = {
    let assert Ok(a) = list.last(points)
    let assert Ok(b) = list.first(points)
    Edge(a:, b:)
  }
  let edges =
    points
    |> list.window_by_2
    |> list.map(fn(points) {
      let #(a, b) = points
      Edge(a:, b:)
    })
  [last_edge, ..edges]
}

fn rectangle_size(a: Point, b: Point) -> Int {
  int.absolute_value({ { a.x - b.x } + 1 } * { { a.y - b.y } + 1 })
}

pub fn intersects(a a: Edge, b b: Edge) -> Bool {
  // ensure always left to right or up to down
  let a = normalize_edge(a)
  let b = normalize_edge(b)
  case a.a.x == a.b.x, b.a.x == b.b.x {
    // both vertical or horizontal, nopes
    True, True | False, False -> False

    // a Vert, b Horizontal
    True, False -> {
      let a_x = a.a.x
      let b_y = b.a.y
      { b_y >= a.a.y && b_y <= a.b.y } && { b.a.x < a_x && b.b.x > a_x }
    }
    // a Horizontal, b Vertical
    False, True -> {
      let a_y = a.a.y
      let b_x = b.a.x
      { a_y >= b.a.y && a_y <= b.b.y } && { a.a.x < b_x && a.b.x > b_x }
    }
  }
}

pub fn normalize_edge(a: Edge) -> Edge {
  case a.a.x == a.b.x {
    // Vertical, ensure lowest y first
    True -> {
      let x = a.a.x
      let #(y0, y1) = #(int.min(a.a.y, a.b.y), int.max(a.a.y, a.b.y))
      Edge(a: Point(x:, y: y0), b: Point(x:, y: y1))
    }
    False -> {
      let y = a.a.y
      let #(x0, x1) = #(int.min(a.a.x, a.b.x), int.max(a.a.x, a.b.x))
      Edge(a: Point(x: x0, y:), b: Point(x: x1, y:))
    }
  }
}
