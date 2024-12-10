import day09
import gleeunit/should

pub fn solve1_test() {
  "2333133121414131402"
  |> day09.parse
  |> day09.part1
  |> should.equal(1928)
}

pub fn solve2_test() {
  "2333133121414131402"
  |> day09.parse2
  |> day09.part2
  |> should.equal(2858)
}
