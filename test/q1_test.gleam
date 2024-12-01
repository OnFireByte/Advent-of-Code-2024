import gleeunit/should
import q1

pub fn solve_test() {
  "3   4
4   3
2   5
1   3
3   9
3   3"
  |> q1.solve()
  |> should.equal(11)
}

pub fn solve2_test() {
  "3   4
4   3
2   5
1   3
3   9
3   3"
  |> q1.solve2()
  |> should.equal(31)
}
