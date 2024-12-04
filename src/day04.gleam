import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day04.txt")
  bench.run(
    [bench.Input("day 4", raw)],
    [
      bench.Function("part1", fn(v) { parse(v) |> part1 }),
      bench.Function("part2", fn(v) { parse(v) |> part2 }),
    ],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
  let data = parse(raw)
  io.debug(part1(data))
  io.debug(part2(data))
}

pub fn parse(raw: String) {
  let lines = string.split(raw, "\n")
  let map =
    lines
    |> list.map(string.to_graphemes)
    |> list.index_fold(dict.new(), fn(map, line, i) {
      list.index_fold(line, map, fn(map, char, j) {
        dict.insert(map, #(i, j), char)
      })
    })
  let height = list.length(lines)
  let assert Ok(width) = list.first(lines) |> result.map(string.length)
  #(map, width, height)
}

pub fn part1(tup) {
  let #(map, w, h) = tup
  loop1(map, 0, 0, 0, w, h)
}

fn loop1(map, i, j, acc, width, height) {
  case i < height, j < width {
    True, True -> {
      let count = case dict.get(map, #(i, j)) {
        Ok("X") -> find_xmas(map, i, j)
        _ -> 0
      }
      loop1(map, i, j + 1, acc + count, width, height)
    }
    True, False -> loop1(map, i + 1, 0, acc, width, height)
    _, _ -> acc
  }
}

fn find_xmas(map, i, j) {
  [#(0, 1), #(1, 0), #(1, 1), #(1, -1), #(-1, 1), #(0, -1), #(-1, 0), #(-1, -1)]
  |> list.fold(0, fn(acc, cord) {
    acc + check_adj(map, i + cord.0, j + cord.1, cord.0, cord.1, "M")
  })
}

fn check_adj(map, i, j, x, y, char) {
  case char == "", dict.get(map, #(i, j)) {
    True, _ -> 1
    _, Ok(v) if v == char ->
      check_adj(map, i + x, j + y, x, y, get_next_xmas_char(char))
    _, _ -> 0
  }
}

fn get_next_xmas_char(char) {
  case char {
    "X" -> "M"
    "M" -> "A"
    "A" -> "S"
    _ -> ""
  }
}

pub fn part2(tup) {
  let #(map, w, h) = tup
  loop2(map, 0, 0, 0, w, h)
}

fn loop2(map, i, j, acc, width, height) {
  case i < height, j < width {
    True, True -> {
      let count = bool.to_int(find_cross_mas(map, i, j))

      loop2(map, i, j + 1, acc + count, width, height)
    }
    True, False -> loop2(map, i + 1, 0, acc, width, height)
    _, _ -> acc
  }
}

fn find_cross_mas(map, i, j) {
  let res = dict.get(map, #(i, j))
  use char <- try_else(res, False)
  use <- bool.guard(char != "A", False)
  [#(1, 1), #(1, -1)]
  |> list.fold(True, fn(acc1, cord) {
    acc1
    && list.fold([#("M", "S"), #("S", "M")], False, fn(acc2, chars) {
      acc2
      || {
        is_equal(map, i + cord.0, j + cord.1, chars.0)
        && is_equal(map, i - cord.0, j - cord.1, chars.1)
      }
    })
  })
}

fn is_equal(map, i, j, char) {
  case dict.get(map, #(i, j)) {
    Ok(v) -> v == char
    _ -> False
  }
}

fn try_else(res, default, then) {
  case res {
    Ok(data) -> then(data)
    Error(_) -> default
  }
}
