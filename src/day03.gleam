import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day03.txt")
  bench.run(
    [bench.Input("day 3", raw)],
    [bench.Function("part1", part1), bench.Function("part2", part2)],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
  io.debug(part1(raw))
  io.debug(part2(raw))
}

pub fn part1(data) {
  parser1(data, list.new()) |> int.sum
}

fn parser1(tokens: String, acc: List(Int)) {
  case tokens {
    "" -> acc
    "mul(" <> rest -> inner_parser1(rest, acc)
    _ ->
      string.pop_grapheme(tokens)
      |> result.map(pair.second)
      |> result.unwrap("")
      |> parser1(acc)
  }
}

fn lazy_early(r: Result(a, b), f: fn() -> c, then: fn(a) -> c) {
  case r {
    Ok(v) -> then(v)
    Error(_) -> f()
  }
}

// fn inner_parser(tokens: String, parser, acc) {
//   use #(num1, rest) <- lazy_early(read_int(tokens, "", ","), fn() {
//     parser(tokens, acc)
//   })
//   use #(num2, rest) <- lazy_early(read_int(rest, "", ")"), fn() {
//     parser(rest, acc)
//   })
//   parser(rest, [num1 * num2, ..acc])
// }

fn inner_parser1(tokens: String, acc) {
  use #(num1, rest) <- lazy_early(read_int(tokens, "", ","), fn() {
    parser1(tokens, acc)
  })
  use #(num2, rest) <- lazy_early(read_int(rest, "", ")"), fn() {
    parser1(rest, acc)
  })
  parser1(rest, [num1 * num2, ..acc])
}

fn inner_parser2(tokens: String, acc) {
  use #(num1, rest) <- lazy_early(read_int(tokens, "", ","), fn() {
    parser2(tokens, acc, True)
  })
  use #(num2, rest) <- lazy_early(read_int(rest, "", ")"), fn() {
    parser2(rest, acc, True)
  })
  parser2(rest, [num1 * num2, ..acc], True)
}

fn read_int(tokens: String, acc: String, limiter: String) {
  case tokens {
    "" -> Error(Nil)
    "," <> rest if limiter == "," ->
      int.parse(acc) |> result.map(fn(value) { #(value, rest) })
    ")" <> rest if limiter == ")" ->
      int.parse(acc) |> result.map(fn(value) { #(value, rest) })
    _ -> {
      let assert Ok(#(char, rest)) = string.pop_grapheme(tokens)
      case char {
        "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
          read_int(rest, acc <> char, limiter)
        _ -> Error(Nil)
      }
    }
  }
}

pub fn part2(data) {
  parser2(data, list.new(), True) |> int.sum
}

fn parser2(tokens: String, acc, enable: Bool) {
  case tokens {
    "" -> acc
    "mul(" <> rest if enable -> inner_parser2(rest, acc)
    "don't()" <> rest -> parser2(rest, acc, False)
    "do()" <> rest -> parser2(rest, acc, True)
    _ ->
      string.pop_grapheme(tokens)
      |> result.map(pair.second)
      |> result.unwrap("")
      |> parser2(acc, enable)
  }
}
