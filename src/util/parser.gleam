import gleam/int

pub fn parse_int(str) {
  let assert Ok(data) = int.parse(str)
  data
}
