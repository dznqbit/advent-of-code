// http://adventofcode.com/2017/day/14

mod lib;
use lib::knot_hash;

mod groups;
use groups::GroupBuilder;

extern crate bit_vec;
use bit_vec::BitVec;

use std::io::{self, Read};
use std::fmt;
use std::collections::HashSet;

/// Return a single BitVec
fn hex_bits(s: &str) -> BitVec {
    let chars: Vec<char> = s.chars().collect();
    let bytes: Vec<u8> = chars
        .chunks(2)
        .map(|c| { 
            // A u4 type would be more convenient, but this is easy enough...
            let b0 = c[0].to_digit(16).unwrap() as u8;
            let b1 = c[1].to_digit(16).unwrap() as u8;
            (b0 << 4) | b1
        })
        .collect()
    ;

    BitVec::from_bytes(&bytes)
}

struct Grid {
    bits: Vec<BitVec>
}

impl Grid {
    pub fn new(input: &str) -> Grid {
        let mut bits = vec![];

        for i in 0..128 {
            let s = format!("{}-{}", input, i);
            let knot_hash = knot_hash(&s);
            bits.push(hex_bits(&knot_hash));
        }

        Grid {
            bits: bits
        }
    }

    pub fn used_squares(&self) -> usize {
        self.bits.iter().fold(
            0,
            |acc, ref bv| acc + bv.iter().filter(|x| *x).count()
        )
    }
}

impl fmt::Display for Grid {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let s: Vec<String> = self.bits.iter().map(|row| bit_row(row)).collect();
        write!(f, "{}", s.join("\n"))
    }
}

impl fmt::Display for GroupBuilder {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let s: Vec<String> = self.groups.iter().map(|row| group_row(row)).collect();
        write!(f, "{}", s.join("\n"))
    }
}

fn bit_row(row: &BitVec) -> String {
    let rs: Vec<char> = row.iter().map(|ref b| match b { &true => '#', &false => '.' }).collect();
    rs.iter().cloned().collect()
}

fn group_row(row: &[Option<u16>; 128]) -> String {
    let v: Vec<String> = row.iter().map(|n| match n {
        &Some(x) => format!("{:3}", x),
        &None    => "  .".to_string(),
    }).collect();

    v.join(" ")
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }
    let trimmed_input = input.trim();

    let grid = Grid::new(&trimmed_input);
    let groups = GroupBuilder::new(&grid.bits).groups;

    let part1_solution = grid.used_squares();
    let part2_solution = {
        let mut all_groups: HashSet<u16> = HashSet::new();
        
        for row in &groups {
            for c in row.iter() {
                if let &Some(g) = c {
                    all_groups.insert(g);
                }
            }
        }

        all_groups.len()
    };

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
