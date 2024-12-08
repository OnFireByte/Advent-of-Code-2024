import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day07.txt")
  let data = parse(raw |> string.trim)
  bench.run(
    [bench.Input("day 7", raw)],
    [
      bench.Function("part1", fn(v) { parse(v) |> part1 }),
      bench.Function("part1 (bool)", fn(v) { parse(v) |> part1_bool }),
      bench.Function("part2", fn(v) { parse(v) |> part2 }),
    ],
    [bench.Duration(5000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.Mean, bench.P(99)])
  |> io.println()
  io.debug(part1(data))
  io.debug(part1_bool(data))
  io.debug(part2(data))
}

pub type Line {
  Line(want: Int, nums: List(Int))
}

pub fn parse(raw: String) {
  raw
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [want, list_str] = string.split(line, ": ")
    let assert Ok(want) = int.parse(want)
    let assert Ok(num_list) =
      list_str |> string.split(" ") |> list.map(int.parse) |> result.all
    Line(want, num_list)
  })
}

pub fn part1(lines: List(Line)) {
  lines
  |> list.map(fn(line) {
    case find_sol1(line.want, line.nums, 0, False) {
      0 -> 0
      _ -> line.want
    }
  })
  |> int.sum
}

pub fn find_sol1(want, nums, acc, first) {
  case nums {
    [] -> bool.to_int(want == acc)
    _ if acc > want -> 0
    [num, ..rest] -> {
      let add = find_sol1(want, rest, acc + num, False)
      let mult_acc = case first {
        True -> num
        False -> acc * num
      }
      let mult = find_sol1(want, rest, mult_acc, False)
      add + mult
    }
  }
}

pub fn part1_bool(lines: List(Line)) {
  lines
  |> list.map(fn(line) {
    case find_sol1_bool(line.want, line.nums, 0, False) {
      False -> 0
      True -> line.want
    }
  })
  |> int.sum
}

pub fn find_sol1_bool(want, nums, acc, first) {
  case nums {
    [] -> want == acc
    _ if acc > want -> False
    [num, ..rest] -> {
      let add = find_sol1_bool(want, rest, acc + num, False)
      use <- bool.guard(add, True)
      let mult_acc = case first {
        True -> num
        False -> acc * num
      }
      let mult = find_sol1_bool(want, rest, mult_acc, False)
      mult
    }
  }
}

pub fn part2(lines: List(Line)) {
  lines
  |> list.map(fn(line) {
    case find_sol2(line.want, line.nums, 0, False) {
      False -> 0
      True -> line.want
    }
  })
  |> int.sum
}

pub fn find_sol2(want, nums, acc, first) {
  case nums {
    [] -> want == acc
    _ if acc > want -> False
    [num, ..rest] -> {
      let add = find_sol2(want, rest, acc + num, False)
      use <- bool.guard(add, True)

      let con_acc = concat(acc, num)
      let con = find_sol2(want, rest, con_acc, False)
      use <- bool.guard(con, True)

      let mult_acc = case first {
        True -> num
        False -> acc * num
      }
      let mult = find_sol2(want, rest, mult_acc, False)
      mult
    }
  }
}

pub fn concat(a, b) {
  let mult = find_mult(b)

  a * mult + b
}

fn find_mult(n) {
  case n {
    0 -> 1
    _ -> 10 * find_mult(n / 10)
  }
}
