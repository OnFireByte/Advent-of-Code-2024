import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day05.txt")
  bench.run(
    [bench.Input("day 5", raw)],
    [
      bench.Function("part1", fn(v) { parse(v) |> part1 }),
      bench.Function("part2", fn(v) { parse(v) |> part2 }),
    ],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.Mean, bench.P(99)])
  |> io.println()
  let data = parse(raw)
  io.debug(part1(data))
  io.debug(part2(data))
}

pub fn parse(raw: String) {
  let assert [rules_raw, updates_raw] = string.split(raw, "\n\n")

  let rule_map =
    rules_raw
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [a, b] = string.split(line, "|")
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)
      #(a, b)
    })
    |> list.fold(dict.new(), fn(map, p) {
      let #(a, b) = p
      dict.upsert(map, b, fn(s) {
        s |> option.unwrap(list.new()) |> list.prepend(a)
      })
    })

  let updates =
    updates_raw
    |> string.split("\n")
    |> list.map(fn(line) {
      let elements = string.split(line, ",")
      elements |> list.filter_map(int.parse)
    })

  #(rule_map, updates)
}

pub fn part1(tup) {
  let #(rule_map, updates) = tup
  updates
  |> list.map(fn(line) {
    let valid = is_valid1(line, rule_map, set.new())
    case valid {
      True -> {
        let len = list.length(line)
        list_at(line, len / 2, 0) |> result.unwrap(0)
      }
      False -> 0
    }
  })
  |> int.sum
}

fn is_valid1(line, map, prev) {
  let line_set = set.from_list(line)
  case line {
    [] -> True
    [page, ..rest] -> {
      let needs = dict.get(map, page)
      case needs {
        Error(Nil) -> is_valid1(rest, map, set.insert(prev, page))
        Ok(needs) -> {
          let valid =
            list.all(needs, fn(v) {
              set.contains(prev, v) || !set.contains(line_set, v)
            })
          case valid {
            True -> is_valid1(rest, map, set.insert(prev, page))
            False -> False
          }
        }
      }
    }
  }
}

fn list_at(l, at, curr) {
  case curr == at {
    True -> list.first(l)
    False -> list_at(list.rest(l) |> result.unwrap(list.new()), at, curr + 1)
  }
}

pub fn part2(tup) {
  let #(rule_map, updates) = tup
  updates
  |> list.map(fn(line) {
    let valid = is_valid1(line, rule_map, set.new())
    case valid {
      True -> 0
      False -> {
        // let new = fix_line(set.from_list(line), [], rule_map)
        let new = fix_line_fast(line, rule_map)
        list_at(new, list.length(new) / 2, 0) |> result.unwrap(0)
      }
    }
  })
  |> int.sum
}

// Bubble sort-like implementation
pub fn fix_line(line_set, new, map) {
  case set.is_empty(line_set) {
    True -> list.reverse(new)
    False -> {
      let el = {
        use acc, v <- set.fold(line_set, 0)
        let valid =
          list.all(dict.get(map, v) |> result.unwrap([]), fn(need) {
            !set.contains(line_set, need)
          })
        case valid {
          True -> v
          False -> acc
        }
      }
      fix_line(set.delete(line_set, el), [el, ..new], map)
    }
  }
}

// Implement using sorting
// The idea is that the "require to be before" is strictly equivalent to sorting using that condition
pub fn fix_line_fast(line, map) {
  let comp = fn(a, b) {
    let b_need_a =
      dict.get(map, b) |> result.unwrap(list.new()) |> list.contains(a)
    case b_need_a {
      True -> order.Lt
      False -> order.Gt
    }
  }

  list.sort(line, comp)
}
