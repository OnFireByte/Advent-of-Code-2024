import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import gleamy/bench
import simplifile
import util/parser

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day13.txt")
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
  let assert Ok(re) = regexp.from_string("\\b\\d+\\b")

  raw
  |> string.trim
  |> regexp.scan(re, _)
  |> list.map(fn(v) { parser.parse_int(v.content) })
  |> list.sized_chunk(6)
}

pub fn part1(lines) {
  lines
  |> list.map(fn(line) {
    let assert [ax, ay, bx, by, want_x, want_y] = line
    let a_top = by * want_x - bx * want_y
    let b_top = -ay * want_x + ax * want_y
    let d = det(ax, bx, ay, by)

    case a_top % d == 0 && b_top % d == 0 {
      True -> a_top * 3 / d + b_top / d
      False -> 0
    }
  })
  |> int.sum
}

pub fn part2(lines) {
  lines
  |> list.map(fn(line) {
    let assert [ax, ay, bx, by, want_x, want_y] = line
    let want_x = want_x + 10_000_000_000_000
    let want_y = want_y + 10_000_000_000_000
    let a_top = by * want_x - bx * want_y
    let b_top = -ay * want_x + ax * want_y
    let d = det(ax, bx, ay, by)

    case a_top % d == 0 && b_top % d == 0 {
      True -> a_top * 3 / d + b_top / d
      False -> 0
    }
  })
  |> int.sum
}

fn det(a, b, c, d) {
  a * d - b * c
}
