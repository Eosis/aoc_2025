import day_11.{Node}
import gleam/dict
import gleeunit/should

const test_input = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

const part_2_test_input = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

pub fn part_1_test() {
  day_11.do_part_1(test_input)
  |> should.equal(5)
}

pub fn part_2_test() {
  day_11.do_speedy_part_2(part_2_test_input)
  |> should.equal(2)
}

pub fn topological_sort_test() {
  day_11.parse_input(part_2_test_input)
  |> day_11.topologically_sort_graph("svr", _)
  |> echo
}
