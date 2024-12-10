import day10
import gleeunit/should

pub fn solve1_test() {
  "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"
  |> day10.parse
  |> day10.part1
  |> should.equal(36)
}

pub fn solve2_test() {
  "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"
  |> day10.parse
  |> day10.part2
  |> should.equal(81)
}
