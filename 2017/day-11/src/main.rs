// http://adventofcode.com/%YEAR%/day/%DAY%

use std::cmp;
use std::fmt;
use std::io::{self, Read};

enum HexDirection {
    North,
    NorthEast,
    SouthEast,
    South,
    SouthWest,
    NorthWest
}

impl HexDirection {
    pub fn parse(s: &str) -> HexDirection {
        match s {
            "n"     => HexDirection::North,
            "ne"    => HexDirection::NorthEast,
            "se"    => HexDirection::SouthEast,
            "s"     => HexDirection::South,
            "sw"    => HexDirection::SouthWest,
            "nw"    => HexDirection::NorthWest,
            _       => panic!(format!("Didnt expect \"{}\"", s))
        }
    }

    pub fn to_s(&self) -> String {
        let s = match *self {
            HexDirection::North     => "n",
            HexDirection::NorthEast => "ne",
            HexDirection::SouthEast => "se",
            HexDirection::South     => "s",
            HexDirection::SouthWest => "sw",
            HexDirection::NorthWest => "nw"
        };

        String::from(s)
    }

    pub fn from_rr(rr: &(i32, i32)) -> HexDirection {
        match *rr {
            // Absolute Matches
            ( 0,  1) => HexDirection::North,
            ( 1,  0) => HexDirection::NorthEast,
            ( 1, -1) => HexDirection::SouthEast,
            ( 0, -1) => HexDirection::South,
            (-1,  0) => HexDirection::SouthWest,
            (-1,  1) => HexDirection::NorthWest,

            // Fuzzy Matches
            ( 1,  1) => HexDirection::North,
            (-1, -1) => HexDirection::South,

            _        => panic!("Cannot parse rr {:?}", rr)
        }
    }

    pub fn to_rr(&self) -> (i32, i32) {
        match *self {
            HexDirection::North     => (0, 1),
            HexDirection::NorthEast => (1, 0),
            HexDirection::SouthEast => (1, -1),
            HexDirection::South     => (0, -1),
            HexDirection::SouthWest => (-1, 0),
            HexDirection::NorthWest => (-1, 1)
        }
    }
}

impl fmt::Display for HexDirection {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.to_s())
    }
}

#[derive(PartialEq)]
#[derive(Clone)]
struct HexCoordinate {
    ray: i32,
    col: i32
}

impl HexCoordinate {
    fn new() -> HexCoordinate {
        HexCoordinate {
            ray: 0,
            col: 0
        }
    }

    /// Move 1 step in direction
    pub fn mv(&self, direction: &HexDirection) -> HexCoordinate {
        let (c, r) = direction.to_rr();

        HexCoordinate {
            ray: self.ray + r,
            col: self.col + c
        }
    }

    /// Number of steps between self and hc
    pub fn distance(&self, hc: &HexCoordinate) -> u32 {
        let mut steps = 0;
        let mut current_hc = self.clone();

        while current_hc != *hc {
            let d = current_hc.direction(hc);
            let new_hc = current_hc.mv(&d);
            steps += 1;
            current_hc = new_hc;
        }

        steps
    }

    /// Direction from self to hc
    pub fn direction(&self, hc: &HexCoordinate) -> HexDirection {
        let diff_col = hc.col - self.col;
        let diff_ray = hc.ray - self.ray;

        let max_diff = cmp::max(diff_col.abs(), diff_ray.abs());
        let rr = (diff_col / max_diff, diff_ray / max_diff);

        HexDirection::from_rr(&rr)
    }

    pub fn to_s(&self) -> String {
        format!("<{:3}/{:3}>", self.col, self.ray)
    }
}

impl fmt::Display for HexCoordinate {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.to_s())
    }
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let moves_s:Vec<&str> = input.trim().split(',').collect();
    let moves: Vec<HexDirection> = moves_s.iter()
        .map(|s| HexDirection::parse(s))
        .collect()
    ;

    let origin = HexCoordinate::new();

    let (location, max_distance) = moves.iter().fold(
        // (coords, longest distance)
        (HexCoordinate::new(), 0),
        |(hex_c, max_d), hex_d| {
            let next_hex_c = hex_c.mv(&hex_d);
            let next_max_d = cmp::max(next_hex_c.distance(&origin), max_d);

            (next_hex_c, next_max_d)
        }
    );

    let part1_solution = location.distance(&origin);
    let part2_solution = max_distance;

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
