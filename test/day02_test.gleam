import day02
import gleam/bool
import gleam/int
import gleam/io
import gleeunit/should

pub fn solve1_test() {
  "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"
  |> day02.parse
  |> day02.part1
  |> should.equal(2)
}

pub fn solve2_test() {
  "7 6 4 2 110000
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
100 3 6 7 9
1 10000 2
10 1 11
4 2 3 2 0 -2 -3 -4 -6 -8"
  |> day02.parse
  |> day02.part2
  |> should.equal(7)
}

pub fn random_test() {
  for(0, 100_000, fn(_) {
    let sign = {
      case int.random(1) {
        0 -> -1
        1 -> 1
        _ -> 0
      }
    }

    let l = create(int.random(10), 10, sign, True)
    let res = day02.part2([l])
    case res {
      1 -> Nil
      _ -> {
        io.debug(l)
        Nil
      }
    }
  })
}

fn create(a, n, sign, can_error) {
  case n {
    0 -> []
    _ -> {
      let delta = int.random(2) + 1
      let random = can_error && int.random(5) == 0
      let r = bool.to_int(random)
      let new = { a + delta * sign } * { 1 - r } + int.random(1_000_000) * r
      [
        new,
        ..create(
          {
            case random {
              True -> a
              False -> new
            }
          },
          n - 1,
          sign,
          can_error && !random,
        )
      ]
    }
  }
}

fn for(start, end, func) {
  case start <= end {
    False -> Nil
    True -> {
      func(start)
      for(start + 1, end, func)
    }
  }
}
