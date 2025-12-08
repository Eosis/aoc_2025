import gleam/float
import gleam/int
import gleam/order.{type Order, Eq, Gt, Lt}

pub type Point {
  Point(x: Int, y: Int, z: Int)
}

// give these things an ordering to make set lookup easier ;)
pub fn compare(a: Point, b: Point) -> Order {
  case int.compare(a.x, b.x) {
    Eq ->
      case int.compare(a.y, b.y) {
        Eq -> int.compare(a.z, b.z)
        otherwise -> otherwise
      }
    otherwise -> otherwise
  }
}

pub fn get_distance(a: Point, b: Point) -> Float {
  let assert Ok(val) =
    [
      { a.x - b.x } * { a.x - b.x },
      { a.y - b.y } * { a.y - b.y },
      { a.z - b.z } * { a.z - b.z },
    ]
    |> int.sum
    |> int.to_float
    |> float.square_root

  val
}
