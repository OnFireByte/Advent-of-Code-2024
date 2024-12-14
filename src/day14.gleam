import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/regexp
import gleam/set
import gleam/string
import simplifile
import util/parser

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day14.txt")
  let data = parse(raw)
  io.debug(part1(data, 101, 103))
  io.debug(part2(data))
}

pub fn parse(raw: String) {
  let assert Ok(re) = regexp.from_string("-?\\d+")

  raw
  |> string.trim
  |> regexp.scan(re, _)
  |> list.map(fn(v) { parser.parse_int(v.content) })
  |> list.sized_chunk(4)
}

pub fn part1(robots, w, h) {
  let half_w = w / 2
  let half_h = h / 2
  let res =
    robots
    |> list.fold(#(0, 0, 0, 0), fn(acc, robot) {
      let #(c1, c2, c3, c4) = acc
      let assert [px, py, vx, vy] = robot
      let new_x = { px + vx * 100 + w * 100 } % w
      let new_y = { py + vy * 100 + h * 100 } % h
      case int.compare(new_x, half_w), int.compare(new_y, half_h) {
        order.Eq, _ | _, order.Eq -> acc
        order.Lt, order.Lt -> #(c1 + 1, c2, c3, c4)
        order.Gt, order.Lt -> #(c1, c2 + 1, c3, c4)
        order.Lt, order.Gt -> #(c1, c2, c3 + 1, c4)
        order.Gt, order.Gt -> #(c1, c2, c3, c4 + 1)
      }
    })
  res.0 * res.1 * res.2 * res.3
}

pub fn part2(robots) {
  let text = loop(1000, 10_000, robots, 101, 103, "")
  let assert Ok(Nil) = simplifile.write("./data.txt", text)
}

fn loop(start, finish, robots, w, h, acc) {
  io.debug(start)
  use <- bool.guard(start >= finish, acc)
  let res =
    robots
    |> list.map(fn(robot) {
      let assert [px, py, vx, vy] = robot
      let new_x = { px + vx * start + w * start } % w
      let new_y = { py + vy * start + h * start } % h
      #(new_x, new_y)
    })
    |> set.from_list
  let data =
    for(0, 101, "", fn(sacc, x) {
      for(0, 103, sacc, fn(sacc, y) {
        case set.contains(res, #(x, y)) {
          True -> sacc <> "#"
          False -> sacc <> "."
        }
      })
      <> "\n"
    })
  let acc = acc <> "\n" <> int.to_string(start) <> ":\n" <> data
  loop(start + 1, finish, robots, w, h, acc)
}

fn for(start, stop, acc, f) {
  case start >= stop {
    True -> acc
    False -> for(start + 1, stop, f(acc, start), f)
  }
}
