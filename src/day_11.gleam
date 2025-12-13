import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn part_1() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_11.txt")
  do_part_1(input)
}

pub fn part_2() -> Int {
  let assert Ok(input) = simplifile.read("./inputs/day_11.txt")
  do_speedy_part_2(input)
}

pub fn do_part_1(input: String) -> Int {
  parse_input(input)
  |> find_paths
  |> list.length
}

pub fn do_part_2(input: String) -> Int {
  parse_input(input)
  |> find_paths_loop([["fft"]], "out", _)
  |> echo
  |> fn(paths) {
    echo list.length(paths) as "total paths"
    paths
  }
  |> list.filter(fn(path) {
    list.contains(path, "dac") && list.contains(path, "fft")
  })
  |> list.length
}

pub fn do_speedy_part_2(input: String) -> Int {
  let whole_graph = parse_input(input)
  let sorted_nodes = topologically_sort_graph("svr", whole_graph)
  let #(first_subgraph_end, second_subgraph_end) =
    determine_relevant_sub_graph_order(sorted_nodes)
  let first_sub_graph =
    sub_graph_nodes(sorted_nodes, from: "svr", to: first_subgraph_end)
    |> dict.take(whole_graph, _)

  let second_sub_graph =
    sub_graph_nodes(
      sorted_nodes,
      from: first_subgraph_end,
      to: second_subgraph_end,
    )
    |> dict.take(whole_graph, _)

  let third_sub_graph =
    sub_graph_nodes(sorted_nodes, from: second_subgraph_end, to: "out")
    |> dict.take(whole_graph, _)

  let first_sub_paths =
    find_paths_loop([["svr"]], first_subgraph_end, first_sub_graph)
  let second_sub_paths =
    find_paths_loop(
      [[first_subgraph_end]],
      second_subgraph_end,
      second_sub_graph,
    )
  let third_sub_paths =
    find_paths_loop([[second_subgraph_end]], "out", third_sub_graph)
  int.product([
    list.length(first_sub_paths),
    list.length(second_sub_paths),
    list.length(third_sub_paths),
  ])
}

fn determine_relevant_sub_graph_order(sorted: List(String)) -> #(String, String) {
  let #(founds, _) =
    sorted
    |> list.map(fn(name) {
      use <- bool.guard(
        when: { name != "dac" && name != "fft" },
        return: Error(Nil),
      )
      Ok(name)
    })
    |> result.partition

  case founds {
    // These are flipped, a little surprisingly. See result docs.
    [first, second] -> #(second, first)
    _ ->
      panic as {
        "These should have both been found..." <> string.inspect(founds)
      }
  }
}

pub fn sub_graph_nodes(
  sorted_nodes: List(String),
  from from: String,
  to to: String,
) -> List(String) {
  sorted_nodes
  |> list.drop_while(fn(name) { name != from })
  |> list.reverse
  |> list.drop_while(fn(name) { name != to })
  |> list.reverse
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
  // Put last node in for completeness and to make the code simpler.
  |> dict.insert("out", Node(name: "out", nexts: []))
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
  find_paths_loop([["you"]], "out", graph)
}

fn find_paths_loop(
  prefixes: List(List(String)),
  target: String,
  graph: Dict(String, Node),
) -> List(List(String)) {
  let assert Ok(first_prefix) = list.first(prefixes)
  let assert Ok(head) = list.first(first_prefix)

  case target == head {
    True -> prefixes
    False -> {
      case dict.get(graph, head) {
        Error(Nil) -> []
        Ok(Node(_, nexts:)) -> {
          nexts
          |> list.map(fn(next) {
            list.map(prefixes, fn(prefix) { [next, ..prefix] })
          })
          |> list.flat_map(find_paths_loop(_, target, graph))
        }
      }
    }
  }
}

pub type Desired {
  Dac
  Fft
}

pub fn topologically_sort_graph(
  start: String,
  graph: Dict(String, Node),
) -> List(String) {
  let #(_, sorted) = topologically_sort_loop(#(set.new(), []), start, graph)
  sorted
}

fn topologically_sort_loop(
  acc: #(Set(String), List(String)),
  current: String,
  graph: Dict(String, Node),
) -> #(Set(String), List(String)) {
  let #(visited, _) = acc
  use <- bool.guard(when: set.contains(visited, current), return: acc)
  use <- bool.guard(when: !dict.has_key(graph, current), return: acc)
  let assert Ok(Node(_, nexts:)) = dict.get(graph, current)
  let #(new_visited, new_sorted) =
    list.fold(
      from: acc,
      over: nexts,
      with: fn(acc: #(Set(String), List(String)), next_name: String) {
        topologically_sort_loop(acc, next_name, graph)
      },
    )
  #(set.insert(new_visited, current), [current, ..new_sorted])
}
