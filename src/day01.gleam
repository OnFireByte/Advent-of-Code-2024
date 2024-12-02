import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day01.txt")
  io.debug(solve2(raw))
}

pub fn solve(raw) {
  let #(a, b) = parse(raw)
  let a = list.sort(a, int.compare)
  let b = list.sort(b, int.compare)
  loop(a, b, 0)
}

fn loop(a, b, acc) {
  case a, b {
    [], [] -> acc
    [x, ..rest_a], [y, ..rest_b] ->
      loop(rest_a, rest_b, acc + int.absolute_value(x - y))
    _, _ -> panic as "size of list a and b must be equal"
  }
}

pub fn solve2(raw) {
  let #(a, b) = parse(raw)

  let counter =
    b
    |> list.fold(dict.new(), fn(map, v) {
      let count = dict.get(map, v) |> result.unwrap(0)
      dict.insert(map, v, count + 1)
    })

  a
  |> list.fold(0, fn(acc, v) {
    let count = dict.get(counter, v) |> result.unwrap(0)
    acc + v * count
  })
}

fn parse(raw) {
  raw
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    let res =
      line
      |> string.split("   ")
      |> list.map(int.parse)
    case res {
      [Ok(a), Ok(b)] -> Ok(#(a, b))
      _ -> Error(Nil)
    }
  })
  |> list.unzip
}
