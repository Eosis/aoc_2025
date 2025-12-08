import day_8/point.{type Point, Point}
import gleam.{type Int}
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string
import pprint
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_8.txt")
  do_part_1(input, 1000)
}

pub fn do_part_1(input: String, number: Int) -> Int {
  let circuits = dict.new()
  parse_input(input)
  |> get_distances_of_pairs()
  |> get_n_shortest_connections(number)
  |> pprint.debug
  |> list.fold(from: circuits, with: add_connection_to_circuits)
  |> pprint.debug
  |> dict.to_list
  |> list.sort(
    order.reverse(fn(a, b) {
      let #(#(_, a), #(_, b)) = #(a, b)
      int.compare(set.size(a), set.size(b))
    }),
  )
  |> pprint.debug
  |> list.take(3)
  |> list.map(fn(entry) { set.size(entry.1) })
  |> int.product
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_8.txt")
  do_part_2(input)
}

pub fn do_part_2(input: String) -> Int {
  todo
}

fn parse_input(input: String) -> List(Point) {
  input
  |> string.split("\n")
  |> list.map(fn(item) {
    item
    |> string.split(",")
    |> list.map(fn(coordinate) {
      let assert Ok(coordinate) = int.parse(coordinate)
      coordinate
    })
    |> fn(coordinates: List(Int)) {
      case coordinates {
        [x, y, z] -> Point(x:, y:, z:)
        otherwise ->
          panic as { "Invalid coordinates" <> string.inspect(otherwise) }
      }
    }
  })
}

type Connection {
  Connection(a: Point, b: Point, distance: Float)
}

fn get_distances_of_pairs(points: List(Point)) -> List(Connection) {
  list.combination_pairs(points)
  |> list.map(fn(points) {
    let #(a, b) = points
    Connection(a:, b:, distance: point.get_distance(a, b))
  })
}

fn get_n_shortest_connections(
  distances: List(Connection),
  take: Int,
) -> List(Connection) {
  distances
  |> list.sort(fn(a, b) { float.compare(a.distance, b.distance) })
  |> list.take(take)
}

fn add_connection_to_circuits(
  circuits: Dict(Int, Set(Point)),
  connection: Connection,
) -> Dict(Int, Set(Point)) {
  let find_result =
    circuits
    |> dict.to_list
    |> list.filter(fn(entry) {
      let #(_, circuit) = entry
      connection_in_circuit(circuit, connection)
    })

  case find_result {
    [] -> {
      let current_size = dict.size(circuits)
      dict.insert(
        circuits,
        current_size,
        set.from_list([connection.a, connection.b]),
      )
    }
    [#(id, circuit)] -> {
      let new_set =
        circuit
        |> set.insert(connection.a)
        |> set.insert(connection.b)

      dict.insert(circuits, id, new_set)
    }
    [#(left_key, left_circuit), #(right_key, right_circuit)] -> {
      let new_set = set.union(left_circuit, right_circuit)
      let without_existing =
        circuits
        |> dict.delete(left_key)
        |> dict.delete(right_key)
        |> dict.values

      [new_set, ..without_existing]
      |> list.index_map(fn(item, idx) -> #(Int, Set(Point)) { #(idx, item) })
      |> dict.from_list
    }
    wot -> {
      panic as {
        "I shouldn't match more than two, that's frigging mad."
        <> pprint.styled(wot)
      }
    }
  }
}

fn connection_in_circuit(circuit: Set(Point), connection: Connection) -> Bool {
  set.contains(circuit, connection.a) || set.contains(circuit, connection.b)
}
