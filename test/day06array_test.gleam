import day06array
import gleeunit/should

pub fn parse_test() {
  let #(map, pos) =
    "..
#<"
    |> day06array.parse
  pos |> should.equal(#(1, 1, day06array.Left))
  map |> day06array.get_map(#(0, 0)) |> should.equal(Ok(day06array.Empty))
  map |> day06array.get_map(#(0, 1)) |> should.equal(Ok(day06array.Empty))
  map |> day06array.get_map(#(1, 0)) |> should.equal(Ok(day06array.Obstruct))
  map |> day06array.get_map(#(1, 1)) |> should.equal(Ok(day06array.Empty))

  map
  |> day06array.insert_to_map(#(1, 1), day06array.Obstruct)
  |> day06array.get_map(#(1, 1))
  |> should.equal(Ok(day06array.Obstruct))
}

pub fn solve1_test() {
  "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."
  |> day06array.parse
  |> day06array.part1
  |> should.equal(41)
}

pub fn solve2_test() {
  "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."
  |> day06array.parse
  |> day06array.part2
  |> should.equal(6)
}
