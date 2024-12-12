import gleam/bool
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleamy/bench
import glearray
import simplifile
import util/matrix

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day12.txt")
  let data = parse(raw)
  bench.run(
    [bench.Input("day 8", raw)],
    [
      bench.Function("part1", fn(v) { parse(v) |> part1 }),
      bench.Function("part2", fn(v) { parse(v) |> part2 }),
    ],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.Mean, bench.P(99)])
  |> io.println()
  io.debug(part1(data))
  io.debug(part2(data))
}

pub fn parse(raw: String) {
  raw
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> glearray.from_list
  })
  |> glearray.from_list
}

pub fn part1(map) {
  matrix.index_fold(map, #(0, set.new()), fn(acc, v, pos) {
    let #(sum, visited) = acc
    let #(i, j) = pos
    let is_visited = set.contains(visited, pos)
    use <- bool.guard(is_visited, acc)
    let #(area, border, visited) = dfs(#(0, 0, visited), map, i, j, v)
    #(sum + area * border, visited)
  }).0
}

pub fn part2(map) {
  matrix.index_fold(map, #(0, set.new()), fn(acc, v, pos) {
    let #(sum, visited) = acc
    let #(i, j) = pos
    let is_visited = set.contains(visited, pos)
    use <- bool.guard(is_visited, acc)
    let #(area, border, visited) = dfs2(#(0, 0, visited), map, i, j, v)
    #(sum + area * border, visited)
  }).0
}

fn get(arr, r, c) {
  glearray.get(arr, r)
  |> result.then(glearray.get(_, c))
}

fn dfs(acc, map, i, j, expected) {
  let #(area, border, visited) = acc
  let res = get(map, i, j)
  case res {
    Error(Nil) -> #(area, border + 1, visited)
    Ok(v) ->
      case v == expected {
        False -> #(area, border + 1, visited)
        True -> {
          use <- bool.guard(set.contains(visited, #(i, j)), acc)
          let visited = set.insert(visited, #(i, j))
          #(area + 1, border, visited)
          |> dfs(map, i + 1, j, v)
          |> dfs(map, i - 1, j, v)
          |> dfs(map, i, j + 1, v)
          |> dfs(map, i, j - 1, v)
        }
      }
  }
}

fn check_corner(map, i, j, expected) {
  //  a
  // dAb
  //  c
  case
    check(map, i - 1, j, expected),
    check(map, i, j + 1, expected),
    check(map, i + 1, j, expected),
    check(map, i, j - 1, expected)
  {
    1, 1, 1, 1 ->
      4
      - check(map, i + 1, j + 1, expected)
      - check(map, i + 1, j - 1, expected)
      - check(map, i - 1, j + 1, expected)
      - check(map, i - 1, j - 1, expected)
    1, 0, 1, 0 | 0, 1, 0, 1 -> 0
    1, 1, 0, 0 -> 2 - check(map, i - 1, j + 1, expected)
    0, 1, 1, 0 -> 2 - check(map, i + 1, j + 1, expected)
    0, 0, 1, 1 -> 2 - check(map, i + 1, j - 1, expected)
    1, 0, 0, 1 -> 2 - check(map, i - 1, j - 1, expected)
    1, 1, 1, 0 ->
      2
      - check(map, i - 1, j + 1, expected)
      - check(map, i + 1, j + 1, expected)
    1, 1, 0, 1 ->
      2
      - check(map, i - 1, j + 1, expected)
      - check(map, i - 1, j - 1, expected)
    1, 0, 1, 1 ->
      2
      - check(map, i + 1, j - 1, expected)
      - check(map, i - 1, j - 1, expected)
    0, 1, 1, 1 ->
      2
      - check(map, i + 1, j - 1, expected)
      - check(map, i + 1, j + 1, expected)
    a, b, c, d -> {
      let count = a + b + c + d
      case count {
        0 -> 4
        1 -> 2
        _ -> 1
      }
    }
  }
}

fn check(map, i, j, expected) {
  bool.to_int(get(map, i, j) |> result.unwrap("") == expected)
}

fn dfs2(acc, map, i, j, expected) {
  let #(area, border, visited) = acc
  let res = get(map, i, j)
  case res {
    Error(Nil) -> acc
    Ok(v) ->
      case v == expected {
        False -> acc
        True -> {
          use <- bool.guard(set.contains(visited, #(i, j)), acc)
          let visited = set.insert(visited, #(i, j))
          let corner_count = check_corner(map, i, j, expected)
          #(area + 1, border + corner_count, visited)
          |> dfs2(map, i + 1, j, v)
          |> dfs2(map, i - 1, j, v)
          |> dfs2(map, i, j + 1, v)
          |> dfs2(map, i, j - 1, v)
        }
      }
  }
}
