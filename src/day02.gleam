import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day02.txt")
  let data = parse(raw)
  list.each(data, io.debug)
  io.debug(part1(data))
  io.debug(part2(data))
}

pub fn parse(raw: String) {
  raw
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) {
    x
    |> string.split(" ")
    |> list.map(fn(a) { int.parse(a) |> result.unwrap(0) })
  })
}

pub fn part1(data: List(List(Int))) {
  list.count(data, is_safe1)
}

fn is_safe1(report) {
  let assert [first, ..rest] = report
  is_safe1_loop(rest, first, order.Gt) || is_safe1_loop(rest, first, order.Lt)
}

fn is_safe1_loop(report: List(Int), first, order) {
  case report {
    [] -> True
    [second, ..rest] ->
      int.compare(first, second) == order
      && int.absolute_value(first - second) <= 3
      && is_safe1_loop(rest, second, order)
  }
}

pub fn part2(data: List(List(Int))) {
  list.count(data, is_safe2)
}

fn is_safe2(report) {
  let assert [first, ..rest] = report
  is_safe2_loop(rest, None, first, order.Gt, False)
  || is_safe2_loop(rest, None, first, order.Lt, False)
}

fn is_safe2_loop(
  report: List(Int),
  old: option.Option(Int),
  first: Int,
  order: order.Order,
  is_skipped: Bool,
) {
  case report {
    [] -> True
    [second, ..rest] -> {
      let valid = is_valid(Some(first), second, order)

      case valid, is_skipped {
        True, _ -> is_safe2_loop(rest, Some(first), second, order, is_skipped)
        False, False ->
          is_safe2_loop(rest, old, first, order, True)
          || {
            is_valid(old, second, order)
            && is_safe2_loop(rest, old, second, order, True)
          }
        _, _ -> False
      }
    }
  }
}

fn is_valid(a, b, order) {
  case a {
    None -> True
    Some(a) -> int.compare(a, b) == order && int.absolute_value(a - b) <= 3
  }
}
