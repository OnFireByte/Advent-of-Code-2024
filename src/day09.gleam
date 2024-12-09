import gleam/bool
import gleam/deque
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleamy/bench
import simplifile

pub fn main() {
  let assert Ok(raw) = simplifile.read("./day09.txt")
  let data1 = parse(raw)
  let data2 = parse2(raw)
  bench.run(
    [bench.Input("day 8", raw)],
    [
      bench.Function("part1", fn(v) { parse(v) |> part1 }),
      bench.Function("part2", fn(v) { parse2(v) |> part2 }),
    ],
    [bench.Duration(10_000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.Mean, bench.P(99)])
  |> io.println()
  io.debug(part1(data1))
  io.debug(part2(data2))
}

pub fn parse(raw: String) {
  let #(_, l) =
    raw
    |> string.to_graphemes
    |> list.index_fold(#(0, []), fn(acc, char, i) {
      let len = char |> int.parse |> result.unwrap(0)
      case int.is_even(i) {
        True -> #(acc.0 + 1, [list.repeat(Some(acc.0), len), ..acc.1])
        False -> #(acc.0, [list.repeat(None, len), ..acc.1])
      }
    })

  let blocks = list.flatten(l)
  deque.from_list(blocks) |> deque.reverse
}

pub fn part1(q) {
  defrag(q, [])
  |> list.index_fold(0, fn(acc, v, i) { acc + v * i })
}

fn defrag(q, acc) {
  case deque.pop_front(q) {
    Error(Nil) -> list.reverse(acc)
    Ok(#(Some(v), new_q)) -> defrag(new_q, [v, ..acc])
    Ok(#(None, new_q)) -> {
      let #(new_q, acc) = get_back_until_found(new_q, acc)
      defrag(new_q, acc)
    }
  }
}

fn get_back_until_found(q, acc) {
  case deque.pop_back(q) {
    Error(Nil) -> #(deque.new(), acc)
    Ok(#(Some(v), new_q)) -> #(new_q, [v, ..acc])
    Ok(#(None, new_q)) -> get_back_until_found(new_q, acc)
  }
}

pub fn parse2(raw: String) {
  let #(_, l) =
    raw
    |> string.to_graphemes
    |> list.index_fold(#(0, []), fn(acc, char, i) {
      let len = char |> int.parse |> result.unwrap(0)
      case int.is_even(i) {
        True -> #(acc.0 + 1, [#(Some(acc.0), len), ..acc.1])
        False -> #(acc.0, [#(None, len), ..acc.1])
      }
    })

  let l = l |> list.filter(fn(v) { v.0 != None || v.1 != 0 })

  let start_addr = list.length(l) - 1
  let map =
    l
    |> list.index_fold(dict.new(), fn(acc, v, i) {
      acc |> dict.insert(i, Node(v, i - 1, i + 1))
    })

  let assert Ok(start) = dict.get(map, start_addr)
  let map = map |> dict.insert(start_addr, Node(start.value, start.next, -1))

  let with_index = l |> list.index_map(fn(v, i) { #(i, v) })

  #(with_index, map, list.length(l) - 1)
}

pub type Node(a) {
  Node(value: a, next: Int, prev: Int)
}

pub fn part2(tup) {
  let #(l, map, start_addr) = tup
  let map = defrag2(l, map, start_addr, start_addr + 1)
  to_list(map, start_addr, [])
  |> cal_checksum(0, 0)
}

pub fn to_list(
  map: dict.Dict(Int, Node(#(option.Option(Int), Int))),
  start_addr,
  acc,
) {
  case start_addr == -1 {
    True -> list.reverse(acc)
    False -> {
      let assert Ok(node) = dict.get(map, start_addr)

      to_list(map, node.next, [node.value, ..acc])
    }
  }
}

fn defrag2(
  l: List(#(Int, #(option.Option(Int), Int))),
  map,
  start_addr,
  running_id,
) {
  case l {
    [] -> map
    [#(_, #(None, _size)), ..rest] -> defrag2(rest, map, start_addr, running_id)
    [#(addr, #(Some(id), size)), ..rest] -> {
      case find_fit(map, start_addr, id, size, addr, running_id + 1) {
        None -> defrag2(rest, map, start_addr, running_id)
        Some(#(new_map, new_id)) -> defrag2(rest, new_map, start_addr, new_id)
      }
    }
  }
}

fn find_fit(map, curr_addr, need_id, need_size, need_addr, running_id) {
  case dict.get(map, curr_addr) {
    Error(Nil) -> None
    Ok(Node(#(Some(id), _size), _, _)) if id == need_id -> None
    Ok(Node(#(Some(_id), _size), next, _prev)) -> {
      find_fit(map, next, need_id, need_size, need_addr, running_id)
    }
    Ok(Node(#(None, size), next, _prev)) if size < need_size ->
      find_fit(map, next, need_id, need_size, need_addr, running_id)

    Ok(Node(#(None, size), next_addr, prev_addr)) -> {
      let assert Ok(prev_node) = dict.get(map, prev_addr)
      let assert Ok(next_node) = dict.get(map, next_addr)
      case size == need_size {
        True -> {
          let new_map =
            map
            |> dict.insert(
              prev_addr,
              Node(prev_node.value, running_id + 1, prev_node.prev),
            )
            |> dict.insert(
              running_id + 1,
              Node(#(Some(need_id), size), next_addr, prev_addr),
            )
            |> dict.insert(
              next_addr,
              Node(next_node.value, next_node.next, running_id + 1),
            )
            |> remove(need_addr, running_id)

          Some(#(new_map, running_id + 1))
        }
        False -> {
          let new_prev_node = Node(prev_node.value, running_id, prev_node.prev)
          let new_node1 =
            Node(#(Some(need_id), need_size), running_id + 2, prev_addr)
          let new_node2 = Node(#(None, size - need_size), next_addr, running_id)
          let new_next_node =
            Node(next_node.value, next_node.next, running_id + 2)
          let new_map =
            map
            |> dict.insert(prev_addr, new_prev_node)
            |> dict.insert(running_id, new_node1)
            |> dict.insert(running_id + 2, new_node2)
            |> dict.insert(next_addr, new_next_node)
            |> remove(need_addr, running_id + 1)

          Some(#(new_map, running_id + 2))
        }
      }
    }
  }
}

type NextNode(a) {
  Next(size: Int, value: a, addr: Int)
  End(size: Int)
}

fn remove(
  map: dict.Dict(Int, Node(#(option.Option(Int), Int))),
  node_addr,
  running_id,
) {
  let assert Ok(node) = dict.get(map, node_addr)
  let #(prev, prev_addr, prev_empty_size) = {
    let assert Ok(first) = dict.get(map, node.prev)
    case first.value {
      #(Some(_), _) -> #(first, node.prev, 0)
      #(None, size) -> {
        let assert Ok(second) = dict.get(map, first.prev)
        #(second, first.prev, size)
      }
    }
  }

  let next_tup = {
    use <- bool.guard(node.next == -1, End(0))
    let assert Ok(first) = dict.get(map, node.next)
    case first.value {
      #(Some(_), _) -> Next(0, first, node.next)
      #(None, size) -> {
        use <- bool.guard(first.next == -1, End(size))
        let assert Ok(second) = dict.get(map, first.next)
        Next(size, second, first.next)
      }
    }
  }

  let new_node_addr = running_id
  let next_addr = case next_tup {
    Next(_, _, addr) -> addr
    End(_) -> -1
  }

  let new_size = next_tup.size + node.value.1 + prev_empty_size
  let new_node = Node(#(None, new_size), next_addr, prev_addr)

  let map =
    map
    |> dict.insert(
      prev_addr,
      Node(value: prev.value, prev: prev.prev, next: new_node_addr),
    )
    |> dict.insert(new_node_addr, new_node)
  case next_tup {
    End(_) -> map
    Next(_, next_node, addr) -> {
      map
      |> dict.insert(
        addr,
        Node(value: next_node.value, next: next_node.next, prev: new_node_addr),
      )
    }
  }
}

fn cal_checksum(l: List(#(option.Option(Int), Int)), i, acc) {
  case l {
    [] -> acc
    [#(None, size), ..rest] -> cal_checksum(rest, i + size, acc)
    [#(Some(v), size), ..rest] ->
      cal_checksum(rest, i + size, cal(i, i + size, v, acc))
  }
}

fn cal(from, to, v, acc) {
  case from == to {
    True -> acc
    False -> cal(from + 1, to, v, acc + v * from)
  }
}
