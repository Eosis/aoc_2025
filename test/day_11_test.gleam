import day_11
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

pub fn part_1_test() {
  day_11.do_part_1(test_input)
  |> should.equal(5)
}

pub fn part_2_test() {
  Ok(Nil)
}
