import day07
import gleeunit/should

pub fn solve1_test() {
  let data =
    "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"
    |> day07.parse

  data
  |> day07.part1
  |> should.equal(3749)

  data
  |> day07.part1_bool
  |> should.equal(3749)
}

pub fn solve2_test() {
  "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"
  |> day07.parse
  |> day07.part2
  |> should.equal(11_387)
}

pub fn concat_test() {
  day07.concat(19, 10) |> should.equal(1910)
  day07.concat(17, 16) |> should.equal(1716)
}
