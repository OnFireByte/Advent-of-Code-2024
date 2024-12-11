import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day11.txt")
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
  |> string.split(" ")
  |> list.map(fn(v) { v |> int.parse |> result.unwrap(0) })
}

pub fn part1(line) {
  solve(line, dict.new(), 25).0
}

pub fn part2(line) {
  solve(line, dict.new(), 75).0
}

fn solve(line, memo, n) {
  use <- bool.lazy_guard(n == 0, fn() { #(list.length(line), memo) })
  line
  |> list.fold(#(0, memo), fn(acc, v) {
    let memo = acc.1
    case dict.get(memo, #(v, n)) {
      Ok(len) -> {
        #(acc.0 + len, memo)
      }

      _ -> {
        let digit = digit_count(v)
        let new_list = case v, int.is_even(digit) {
          0, _ -> [1]
          _, True -> {
            let half = pow10(digit / 2)
            [v / half, v % half]
          }
          _, _ -> [v * 2024]
        }
        let #(len, memo) = solve(new_list, memo, n - 1)
        let memo = dict.insert(memo, #(v, n), len)
        #(acc.0 + len, memo)
      }
    }
  })
}

fn pow10(n) {
  case n <= 0 {
    True -> 1
    False -> 10 * pow10(n - 1)
  }
}

fn digit_count(n) {
  case n < 10 {
    True -> 1
    False -> 1 + digit_count(n / 10)
  }
}
