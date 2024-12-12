import glearray

pub fn index_fold(mat, init, run: fn(a, b, #(Int, Int)) -> a) {
  let h = glearray.length(mat)
  let assert Ok(first_line) = glearray.get(mat, 0)
  let w = glearray.length(first_line)
  use acc, i <- for(0, h, init)
  let assert Ok(line) = glearray.get(mat, i)
  use acc, j <- for(0, w, acc)
  let assert Ok(v) = glearray.get(line, j)
  run(acc, v, #(i, j))
}

fn for(start, stop, acc, run) {
  case start >= stop {
    True -> acc
    False -> for(start + 1, stop, run(acc, start), run)
  }
}
