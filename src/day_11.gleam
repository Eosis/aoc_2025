import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_11.txt")
  do_part_1(input)
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_11.txt")
  do_part_2(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> find_paths
  |> list.length
}

pub fn do_part_2(input: String) -> Int {
  parse_input(input)
  |> todo
}

pub type Node {
  Node(name: String, nexts: List(String))
}

pub fn parse_input(input: String) -> Dict(String, Node) {
  input
  |> string.split("\n")
  |> list.fold(from: dict.new(), with: fn(acc, line) {
    let node = parse_node_from_line(line)
    dict.insert(acc, node.name, node)
  })
}

fn parse_node_from_line(line line: String) -> Node {
  let parts =
    line
    |> string.split(":")

  case parts {
    [name, nexts] -> {
      let name = string.trim(name)
      let nexts =
        nexts
        |> string.trim
        |> string.split(" ")
      Node(name:, nexts:)
    }
    _ -> panic as { "Invalid line" <> line }
  }
}

fn find_paths(graph: Dict(String, Node)) {
  find_paths_loop([["you"]], graph)
}

fn find_paths_loop(
  prefixes: List(List(String)),
  graph: Dict(String, Node),
) -> List(List(String)) {
  let assert Ok(head) =
    list.first(prefixes)
    |> result.try(list.first)

  case head {
    "out" -> prefixes
    head -> {
      let assert Ok(Node(_name, nexts:)) = dict.get(graph, head)
      nexts
      |> list.map(fn(next) {
        list.map(prefixes, fn(prefix) { [next, ..prefix] })
      })
      |> list.flat_map(find_paths_loop(_, graph))
    }
  }
}
