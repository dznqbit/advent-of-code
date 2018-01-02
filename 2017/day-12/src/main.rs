// http://adventofcode.com/2017/day/12

use std::io::{self, Read};
use std::collections::HashSet;
use std::fmt;

#[derive(Debug)]
struct Node {
    index: usize,
    connected_node_indices: Vec<usize>
}

impl Node {}

impl fmt::Display for Node {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let node_names: Vec<String> = self.connected_node_indices.iter().map(|n| n.to_string()).collect();
        write!(
            f, 
            "<Node[{}] -> [{}]>", 
            self.index,
            node_names.join(", ")
        )
    }
}

fn parse_connection(s: &str) -> Option<(usize, Vec<usize>)> {
    let pieces: Vec<&str> = s.split(" <-> ").collect();

    if pieces.len() == 2 {
        let lnode = pieces.get(0).unwrap()
            .parse::<usize>().unwrap()
        ;

        let rnode_strs: Vec<&str> = pieces.get(1).unwrap().split(", ").collect();
        let rnodes: Vec<usize> = rnode_strs.iter()
            .map(|s| s.parse::<usize>().unwrap())
            .collect()
        ;

        Some((lnode, rnodes))
    } else {
        None
    }
}

fn count_distinct_groups(nodes: &Vec<Node>) -> usize {
    fn chase_references(
        groups: &mut Vec<HashSet<usize>>, 
        nodes: &Vec<Node>, 
        visited_indices: &mut HashSet<usize>, 
        i: usize
    ) {
        if visited_indices.contains(&i) {
            return; 
        } else {
            visited_indices.insert(i);
        }

        if let Some(node) = nodes.get(i) {
            if let Some(_) = groups.iter().find(|g| g.contains(&i)) {
                // We've already chased it down, skip
            } else {
                let mut g: HashSet<usize> = HashSet::new();
                g.insert(i);
                groups.push(g);
            }

            {
                let mut group = groups.iter_mut().find(|g| g.contains(&i)).unwrap();
                for cni in &node.connected_node_indices {
                    group.insert(*cni);
                }
            }

            for cni in &node.connected_node_indices {
                chase_references(groups, nodes, visited_indices, *cni);
            }
        }
    };

    let mut visited_indicies: HashSet<usize> = HashSet::new();
    let mut groups: Vec<HashSet<usize>> = vec![];

    for i in 0..nodes.len() {
        chase_references(&mut groups, &nodes, &mut visited_indicies, i);
    }

    groups.len()
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input.trim().split('\n').collect();
    let mut nodes: Vec<Node> = Vec::with_capacity(lines.len());

    for line in &lines {
        if let Some((lnode_n, rnodes_n)) = parse_connection(&line) {
            let index = nodes.len();

            if index != lnode_n { 
                panic!("{} did not match expected index {}", index, lnode_n); 
            }

            nodes.push(Node { 
                index: index,
                connected_node_indices: rnodes_n
            });
        } else {
            panic!("\"{}\": could not build Connection", line);
        }
    }

    let part1_solution = {
        fn count_references(nodes: &Vec<Node>, mut visited_nodes: &mut HashSet<usize>, current_index: usize) -> u32 {
            if visited_nodes.contains(&current_index) { return 0 }

            if let Some(node) = nodes.get(current_index) {
                visited_nodes.insert(current_index);
                node.connected_node_indices.iter().fold(
                    1,
                    |acc, node_n| acc + count_references(&nodes, &mut visited_nodes, *node_n)
                )
            } else {
                panic!("Bad Node Index {}", current_index);
            }
        };

        let mut visited_nodes: HashSet<usize> = HashSet::new();
        count_references(&nodes, &mut visited_nodes, 0)
    };

    let part2_solution = count_distinct_groups(&nodes); 

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
