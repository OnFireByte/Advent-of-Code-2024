import day11
import gleeunit/should

pub fn solve1_test() {
  "125 17"
  |> day11.parse
  |> day11.part1
  |> should.equal(55_312)
}
