import gleam/float
import gleam/int
import gleam/order.{type Order, Eq}

pub type Point {
  Point(x: Int, y: Int)
}

// give these things an ordering
pub fn compare(a: Point, b: Point) -> Order {
  case int.compare(a.x, b.x) {
    Eq -> int.compare(a.y, b.y)
    otherwise -> otherwise
  }
}
