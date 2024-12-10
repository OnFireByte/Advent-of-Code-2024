import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleamy/bench
import glearray
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day10.txt")
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

pub type Point {
  Point(r: Int, c: Int)
}

fn get(arr, r, c) {
  glearray.get(arr, r)
  |> result.then(glearray.get(_, c))
}

pub fn parse(raw: String) {
  raw
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> list.map(fn(v) { v |> int.parse |> result.unwrap(0) })
    |> glearray.from_list
  })
  |> glearray.from_list
}

fn add_set(acc, r, c) {
  set.insert(acc, #(r, c))
}

fn add(acc, _r, _c) {
  acc + 1
}

pub fn part1(map) {
  map
  |> glearray.to_list
  |> list.index_fold(0, fn(acc, line, i) {
    let res =
      line
      |> glearray.to_list
      |> list.index_fold(0, fn(acc, h, j) {
        case h {
          0 -> { dfs(set.new(), i, j, 0, map, add_set) |> set.size } + acc
          _ -> acc
        }
      })
    acc + res
  })
}

fn dfs(acc, r, c, h, map, adder) {
  case h, get(map, r, c) {
    9, Ok(9) -> {
      adder(acc, r, c)
    }
    _, Ok(v) if v == h -> {
      acc
      |> dfs(r - 1, c, h + 1, map, adder)
      |> dfs(r + 1, c, h + 1, map, adder)
      |> dfs(r, c - 1, h + 1, map, adder)
      |> dfs(r, c + 1, h + 1, map, adder)
    }
    _, _ -> acc
  }
}

pub fn part2(map) {
  map
  |> glearray.to_list
  |> list.index_fold(0, fn(acc, line, i) {
    let res =
      line
      |> glearray.to_list
      |> list.index_fold(0, fn(acc, h, j) {
        case h {
          0 -> dfs(0, i, j, 0, map, add) + acc
          _ -> acc
        }
      })
    acc + res
  })
}
