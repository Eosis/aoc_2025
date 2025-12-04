import day_4.{Floor, Free, Roll}
import gleam/dict
import gleeunit/should
import pprint

const test_input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

pub fn part_1_test() {
  day_4.do_part_1(test_input)
  |> should.equal(13)
}

pub fn parsing_test() {
  day_4.parse_input(test_input)
  |> should.equal(Floor(
    bounds: #(10, 10),
    locations: dict.from_list([
      #(#(0, 0), Free),
      #(#(0, 1), Free),
      #(#(0, 2), Roll),
      #(#(0, 3), Roll),
      #(#(0, 4), Free),
      #(#(0, 5), Roll),
      #(#(0, 6), Roll),
      #(#(0, 7), Roll),
      #(#(0, 8), Roll),
      #(#(0, 9), Free),
      #(#(1, 0), Roll),
      #(#(1, 1), Roll),
      #(#(1, 2), Roll),
      #(#(1, 3), Free),
      #(#(1, 4), Roll),
      #(#(1, 5), Free),
      #(#(1, 6), Roll),
      #(#(1, 7), Free),
      #(#(1, 8), Roll),
      #(#(1, 9), Roll),
      #(#(2, 0), Roll),
      #(#(2, 1), Roll),
      #(#(2, 2), Roll),
      #(#(2, 3), Roll),
      #(#(2, 4), Roll),
      #(#(2, 5), Free),
      #(#(2, 6), Roll),
      #(#(2, 7), Free),
      #(#(2, 8), Roll),
      #(#(2, 9), Roll),
      #(#(3, 0), Roll),
      #(#(3, 1), Free),
      #(#(3, 2), Roll),
      #(#(3, 3), Roll),
      #(#(3, 4), Roll),
      #(#(3, 5), Roll),
      #(#(3, 6), Free),
      #(#(3, 7), Free),
      #(#(3, 8), Roll),
      #(#(3, 9), Free),
      #(#(4, 0), Roll),
      #(#(4, 1), Roll),
      #(#(4, 2), Free),
      #(#(4, 3), Roll),
      #(#(4, 4), Roll),
      #(#(4, 5), Roll),
      #(#(4, 6), Roll),
      #(#(4, 7), Free),
      #(#(4, 8), Roll),
      #(#(4, 9), Roll),
      #(#(5, 0), Free),
      #(#(5, 1), Roll),
      #(#(5, 2), Roll),
      #(#(5, 3), Roll),
      #(#(5, 4), Roll),
      #(#(5, 5), Roll),
      #(#(5, 6), Roll),
      #(#(5, 7), Roll),
      #(#(5, 8), Free),
      #(#(5, 9), Roll),
      #(#(6, 0), Free),
      #(#(6, 1), Roll),
      #(#(6, 2), Free),
      #(#(6, 3), Roll),
      #(#(6, 4), Free),
      #(#(6, 5), Roll),
      #(#(6, 6), Free),
      #(#(6, 7), Roll),
      #(#(6, 8), Roll),
      #(#(6, 9), Roll),
      #(#(7, 0), Roll),
      #(#(7, 1), Free),
      #(#(7, 2), Roll),
      #(#(7, 3), Roll),
      #(#(7, 4), Roll),
      #(#(7, 5), Free),
      #(#(7, 6), Roll),
      #(#(7, 7), Roll),
      #(#(7, 8), Roll),
      #(#(7, 9), Roll),
      #(#(8, 0), Free),
      #(#(8, 1), Roll),
      #(#(8, 2), Roll),
      #(#(8, 3), Roll),
      #(#(8, 4), Roll),
      #(#(8, 5), Roll),
      #(#(8, 6), Roll),
      #(#(8, 7), Roll),
      #(#(8, 8), Roll),
      #(#(8, 9), Free),
      #(#(9, 0), Roll),
      #(#(9, 1), Free),
      #(#(9, 2), Roll),
      #(#(9, 3), Free),
      #(#(9, 4), Roll),
      #(#(9, 5), Roll),
      #(#(9, 6), Roll),
      #(#(9, 7), Free),
      #(#(9, 8), Roll),
      #(#(9, 9), Free),
    ]),
  ))
}

pub fn part_2_test() {
  day_4.do_part_2(test_input)
  |> todo
}

pub fn surrounding_coordinates_test() {
  day_4.surrounding_coordinates(#(1, 0), #(3, 3))
  |> should.equal([
    #(0, 0),
    #(0, 1),
    #(1, 1),
    #(2, 0),
    #(2, 1),
  ])
  day_4.surrounding_coordinates(#(2, 0), #(3, 3))
  |> should.equal([
    #(1, 0),
    #(1, 1),
    #(2, 1),
  ])

  day_4.surrounding_coordinates(#(1, 1), #(3, 3))
  |> should.equal([
    #(0, 0),
    #(0, 1),
    #(0, 2),
    #(1, 0),
    #(1, 2),
    #(2, 0),
    #(2, 1),
    #(2, 2),
  ])
}
