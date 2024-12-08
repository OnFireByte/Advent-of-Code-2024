import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day08.txt")
  let data = parse(raw |> string.trim)
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
  let str_map =
    raw
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)
  let h = list.length(str_map)
  let w = str_map |> list.first |> result.unwrap([]) |> list.length
  let map =
    str_map
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      list.index_fold(line, acc, fn(acc, tile, j) {
        case tile {
          "." -> acc
          freq ->
            dict.upsert(acc, freq, fn(opt) {
              case opt {
                option.Some(l) -> set.insert(l, #(i, j))
                option.None -> set.new() |> set.insert(#(i, j))
              }
            })
        }
      })
    })

  #(w, h, map)
}

pub fn part1(tup: #(Int, Int, dict.Dict(String, set.Set(#(Int, Int))))) {
  let #(w, h, map) = tup
  map
  |> dict.fold(set.new(), fn(acc, _freq, pos_set) {
    pos_set
    |> set.fold(acc, fn(acc, pos) {
      pos_set
      |> set.fold(acc, fn(acc, another) {
        let y = 2 * another.0 - pos.0
        let x = 2 * another.1 - pos.1
        case y >= 0 && y < h && x >= 0 && x < w && another != pos {
          True -> set.insert(acc, #(x, y))
          False -> acc
        }
      })
    })
  })
  |> set.size
}

pub fn part2(tup: #(Int, Int, dict.Dict(String, set.Set(#(Int, Int))))) {
  let #(w, h, map) = tup
  let res =
    map
    |> dict.fold(set.new(), fn(acc, _freq, pos_set) {
      pos_set
      |> set.fold(acc, fn(acc, pos) {
        pos_set
        |> set.fold(acc, fn(acc, another) {
          create_anti_nodes(pos, another, w, h, acc)
        })
      })
    })
  set.size(res)
}

fn create_anti_nodes(pos1: #(Int, Int), pos2: #(Int, Int), w, h, acc) {
  use <- bool.guard(pos1 == pos2, set.insert(acc, pos1))
  let y = 2 * pos2.0 - pos1.0
  let x = 2 * pos2.1 - pos1.1
  case y >= 0 && y < h && x >= 0 && x < w {
    True -> {
      set.insert(acc, #(y, x))
      |> create_anti_nodes(pos2, #(y, x), w, h, _)
    }
    False -> acc
  }
}
