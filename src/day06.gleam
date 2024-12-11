import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day06.txt")
  let data = parse(raw)
  bench.run(
    [bench.Input("day 6", raw)],
    [
      bench.Function("part1", fn(v) { parse(v) |> part1 }),
      bench.Function("part2", fn(v) { parse(v) |> part2 }),
    ],
    [bench.Duration(5000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.Mean, bench.P(99)])
  |> io.println()
  io.debug(part1(data))
  io.debug(part2(data))
}

pub type Floor {
  Empty
  Obstruct
}

pub type Direction {
  Up
  Down
  Left
  Right
}

pub fn parse(raw: String) {
  raw
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), #(0, 0, Up)), fn(acc, line, i) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, v, j) {
      case v {
        "#" -> #(dict.insert(acc.0, #(i, j), Obstruct), acc.1)
        "^" -> #(dict.insert(acc.0, #(i, j), Empty), #(i, j, Up))
        "v" -> #(dict.insert(acc.0, #(i, j), Empty), #(i, j, Down))
        "<" -> #(dict.insert(acc.0, #(i, j), Empty), #(i, j, Left))
        ">" -> #(dict.insert(acc.0, #(i, j), Empty), #(i, j, Right))
        _ -> #(dict.insert(acc.0, #(i, j), Empty), acc.1)
      }
    })
  })
}

pub fn part1(tup) {
  let #(map, #(r, c, direction)) = tup
  walk1(map, r, c, direction, set.new())
  |> set.size()
}

fn walk1(map, r, c, direction, memo) {
  let new_pos = next_pos(r, c, direction)

  case dict.get(map, new_pos) {
    Error(Nil) -> memo |> set.insert(#(r, c))
    Ok(Empty) -> {
      let #(new_r, new_c) = new_pos
      walk1(map, new_r, new_c, direction, set.insert(memo, #(r, c)))
    }
    Ok(Obstruct) -> {
      let #(#(new_r, new_c), new_direction) =
        rotate_until_valid(map, r, c, direction)
      walk1(map, new_r, new_c, new_direction, set.insert(memo, #(r, c)))
    }
  }
}

fn next_pos(r, c, direction) {
  case direction {
    Up -> #(r - 1, c)
    Down -> #(r + 1, c)
    Left -> #(r, c - 1)
    Right -> #(r, c + 1)
  }
}

// Imagine if we have like
// .#
// .^#
// ...
// then it should rotate 2 times and u-turn back
fn rotate_until_valid(map, r, c, direction) {
  let new_d = rotate(direction)
  let next_p = next_pos(r, c, new_d)
  case dict.get(map, next_p) {
    Ok(Obstruct) -> rotate_until_valid(map, r, c, new_d)
    _ -> #(next_p, new_d)
  }
}

fn rotate(direction) {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

pub fn part2(tup) {
  let #(map, #(r, c, direction)) = tup
  let visited = walk1(map, r, c, direction, set.new())
  visited
  |> set.delete(#(r, c))
  |> set.to_list
  // Parallelized, but iterator is deprecated
  // |> iterator.from_list
  // |> parallel_map.iterator_pmap(
  //   fn(pos) {
  //     walk2(map |> dict.insert(pos, Obstruct), r, c, direction, set.new())
  //   },
  //   parallel_map.WorkerAmount(16),
  //   1_000_000,
  // )
  // |> iterator.fold(0, fn(acc, res) { acc + { res |> result.unwrap(0) } })
  |> list.map(fn(pos) {
    walk2(map |> dict.insert(pos, Obstruct), r, c, direction, set.new())
  })
  |> int.sum
}

fn walk2(map, r, c, direction, memo) {
  let new_pos = next_pos(r, c, direction)

  case dict.get(map, new_pos), set.contains(memo, #(r, c, direction)) {
    Error(Nil), _ -> 0
    _, True -> 1
    Ok(Empty), _ -> {
      let #(new_r, new_c) = new_pos
      walk2(map, new_r, new_c, direction, memo)
    }
    Ok(Obstruct), _ -> {
      let #(#(new_r, new_c), new_direction) =
        rotate_until_valid(map, r, c, direction)
      walk2(
        map,
        new_r,
        new_c,
        new_direction,
        set.insert(memo, #(r, c, direction)),
      )
    }
  }
}
