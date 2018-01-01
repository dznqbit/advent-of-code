// http://adventofcode.com/2017/day/12

use std::io::{self, Read};
use std::fmt;

#[derive(Debug)]
struct Node<'a> {
    index: usize,
    pipes: Vec<&'a Pipe<'a>>
}

#[derive(Debug)]
struct Pipe<'a> {
    node1: &'a Node<'a>,
    node2: &'a Node<'a>
}

impl<'a> Node<'a> {
    fn new(i: usize) -> Node<'a> {
        Node {
            index: i,
            pipes: vec![]
        }
    }
}

impl<'a> fmt::Display for Node<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f, 
            "<Node[{}] -> [{}]>", 
            self.index,
            "TODO"
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

fn connect<'a> (nodes: &'a mut Vec<Node<'a>>, pipes: &'a mut Vec<Pipe<'a>>, lnode_n: usize, rnode_n: usize)  {
    if let (Some(lnode), Some(rnode)) = (nodes.get(lnode_n), nodes.get(rnode_n)) {
        {
            let pipe = Pipe {
                node1: lnode,
                node2: rnode
            };

            pipes.push(pipe);
        }
    }
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input.trim().split('\n').collect();

    let mut nodes: Vec<Node> = Vec::with_capacity(lines.len());
    let mut pipes: Vec<Pipe> = Vec::with_capacity(lines.len());

    for i in 0..(lines.len()) {
        nodes.push(Node::new(i)); 
    }

    for line in &lines {
        if let Some((lnode_n, rnodes_n)) = parse_connection(&line) {
            for rnode_n in rnodes_n {
                //connect(&mut nodes, &mut pipes, lnode_n, rnode_n);
            }
        } else {
            panic!("\"{}\": could not build Connection", line);
        }
    }

    let part1_solution = "TODO";
    let part2_solution = "TODO";

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
