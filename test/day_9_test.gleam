import day_9.{type Edge, type Rectangle, Edge, Rectangle}
import day_9/point.{type Point, Point}
import gleam/bool
import gleeunit/should
import pprint

const test_input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn part_1_test() {
  day_9.do_part_1(test_input)
  |> should.equal(50)
}

// pub fn part_2_test() {
//   todo
//   // day_9.do_part_2(test_input)
//   // |> should.equal(24)
// }

pub fn normalize_edge_test() {
  use <- bool.guard(when: True, return: Ok(Nil))
  day_9.normalize_edge(Edge(Point(x: 34, y: 54), Point(x: 19, y: 54)))
  |> should.equal(Edge(Point(19, 54), Point(34, 54)))
  day_9.normalize_edge(Edge(Point(x: 34, y: 54), Point(x: 34, y: 19)))
  |> should.equal(Edge(Point(34, 19), Point(34, 54)))
  day_9.normalize_edge(Edge(Point(x: 34, y: 35), Point(x: 34, y: 36)))
  |> should.equal(Edge(Point(34, 35), Point(34, 36)))
  Ok(Nil)
}

fn intersects_test() {
  use <- bool.guard(when: True, return: Ok(Nil))
  // .|.
  // ---
  // .|.
  let a = Edge(Point(x: 1, y: 0), Point(x: 1, y: 2))
  let b = Edge(Point(x: 0, y: 1), Point(x: 2, y: 1))
  day_9.intersects(a, b)
  |> should.be_true
  day_9.intersects(b, a)
  |> should.be_true
  // ---
  // ---
  // ...
  let a = Edge(Point(x: 0, y: 0), Point(x: 2, y: 0))
  let b = Edge(Point(x: 0, y: 1), Point(x: 2, y: 1))
  day_9.intersects(a, b)
  |> should.be_false
  day_9.intersects(b, a)
  |> should.be_false

  // ===
  // ...
  // ...
  let a = Edge(Point(x: 0, y: 0), Point(x: 2, y: 0))
  let b = a
  day_9.intersects(a, b)
  |> should.be_false

  // |..
  // |..
  // |..
  let a = Edge(Point(x: 0, y: 0), Point(x: 0, y: 2))
  let b = a
  day_9.intersects(a, b)
  |> should.be_false

  // Some test cases found when hitting the off-by-one nonsense.
  let a = Edge(Point(7, 3), Point(7, 1))
  let b = Edge(Point(7, 1), Point(10, 1))
  day_9.intersects(a, b)
  |> should.be_false

  let a = Edge(Point(7, 3), Point(7, 1))
  let b = Edge(Point(2, 3), Point(10, 3))
  day_9.intersects(a, b)
  |> should.be_false

  let a = Edge(Point(11, 7), Point(2, 7))
  let b = Edge(Point(9, 7), Point(9, 5))
  day_9.intersects(a, b)
  |> should.be_true
  Ok(Nil)
}

pub fn rectangle_to_edges_test() {
  use <- bool.guard(when: True, return: Ok(Nil))
  let rect = Rectangle(top_left: Point(2, 3), width: 8, height: 3)
  case day_9.rectangle_edges(rect) {
    [first, ..] -> first |> should.equal(Edge(Point(2, 3), Point(9, 3)))
    _ -> panic as "Nope"
  }
  Ok(Nil)
}

pub fn pathos_test() {
  use <- bool.guard(when: True, return: Ok(Nil))
  todo
  //   let rect_points = #(Point(11, 7), Point(2, 3))
  //   let rectangle = day_9.to_rectangle(rect_points)

  //   day_9.rectangle_edges(rectangle)
  //   |> pprint.debug
}
