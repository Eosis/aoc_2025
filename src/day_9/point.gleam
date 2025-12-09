import gleam/float
import gleam/int
import gleam/order.{type Order, Eq}

pub type Point {
  Point(x: Int, y: Int)
}

// give these things an ordering, y first, then x...
// Just for top-down stuff.
pub fn compare(a: Point, b: Point) -> Order {
  case int.compare(a.y, b.y) {
    Eq -> int.compare(a.x, b.x)
    otherwise -> otherwise
  }
}
