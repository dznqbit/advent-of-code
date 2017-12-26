// http://adventofcode.com/2017/day/7
extern crate regex;

use std::io::{self, Read};
use std::fmt;
use std::collections::HashMap;
use regex::Regex;

/// Disc on which our Programs are balancing
#[derive(Debug)]
struct Disc {
    programs: Vec<Program>
}

impl Disc {
    pub fn unbalanced_program(&self) -> Option<&Program> {
        let mut weights_and_programs = HashMap::new();

        for p in &self.programs {
            let total_weight = p.total_weight();
            let mut list = weights_and_programs.entry(total_weight).or_insert(vec![]);
            list.push(p);
        }

        match weights_and_programs.len() {
            0 => None,
            1 => None,
            2 => {
                for v in weights_and_programs.values() {
                    if v.len() == 1 {
                        return Some(v.get(0).unwrap())
                    }
                }

                None
            },
            _ => None
        }
    }

    pub fn to_string(&self) -> Vec<String> {
        self.programs.iter()
            .map(|p| format!("{}", p))
            .collect()
    }

    pub fn total_weight(&self) -> u32 {
        self.programs.iter()
            .fold(0, |acc, p| acc + p.total_weight())
    }
}

impl fmt::Display for Disc {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.to_string().join(", "))
    }
}

/// Used for intermediate step in algorithm.
struct ProgramReference {
    name: String,
    weight: u32,
    program_names: Vec<String>
}

impl ProgramReference {
    /// Parse a string into a Some(ProgramReference), if possible.
    ///
    /// exmple: pbga (66)
    /// result: name=pbga weight=66
    /// exmple: fwft (72) -> ktlj, cntj, xhth
    /// result: name=fwft weight=72 child program names=ktlj,cntj,xhth
    pub fn parse(s: &str) -> Option<ProgramReference> {
        let parts: Vec<&str> = s.trim().split(" -> ").collect();

        if let (Some(name), Some(weight)) = ProgramReference::parse_name_and_weight(parts.get(0).unwrap()) {
            let program_names: Vec<String> = if let Some(children_s) = parts.get(1) {
                children_s
                    .split(", ")
                    .map(|s| s.to_string())
                    .collect()
            } else {
                vec![]
            };

            Some(ProgramReference {
                name: name.to_string(),
                weight: weight,
                program_names: program_names
            })
        } else {
            None
        }
    }

    fn parse_name_and_weight(name_and_weight: &str) 
        -> (Option<&str>, Option<u32>) {
        let re = Regex::new(r"(\w+)\s\((\d+)\)").unwrap();
        if let Some(captures) = re.captures(name_and_weight) {
            if let (Some(name), Some(weight)) = (captures.get(1), captures.get(2)) {
                (
                    Some(name.as_str()), 
                    Some(weight.as_str().parse().unwrap())
                )
            } else {
                (None, None)
            }
        } else {
            (None, None)
        }
    }
}

impl fmt::Display for ProgramReference {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let option_str = if self.program_names.len() > 0 {
            format!(" -> {}", self.program_names.join(", ")).to_string()
        } else {
            "".to_string()
        };

        write!(f, "{} ({}){}", self.name, self.weight, option_str)
    }
}

#[derive(Debug)]
struct Program {
    name: String,
    weight: u32,
    disc: Option<Disc>
}

impl Program {
    /// Return personal weight + sum of child weights
    pub fn total_weight(&self) -> u32 {
        self.weight + if let Some(ref d) = self.disc {
            d.total_weight()
        } else {
            0
        }
    }
}

impl fmt::Display for Program {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let option_str = if let Some(ref disc) = self.disc {
            format!(" -> {}", disc).to_string()
        } else {
            "".to_string()
        };

        write!(f, "{} ({}){}", self.name, self.weight, option_str)
    }
}

fn build_program(
    prfn: String,
    prfs: &HashMap<String, &ProgramReference>
) -> Program {
    let prf = prfs.get(&prfn).unwrap();
    let odisc = if prf.program_names.is_empty() {
        None
    } else {
        let programs = prf.program_names
            .iter()
            .map(|pn| build_program(pn.to_string(), &prfs))
            .collect()
        ;

        Some(Disc { programs: programs })
    };

    Program { 
        name: prf.name.to_string(), 
        weight: prf.weight, 
        disc: odisc
    }
}

fn find_bottom_disc(programs: &Vec<Program>) -> &Program {
    programs
        .iter()
        .fold(
            programs.first().unwrap(),
            |cp, p| if cp.total_weight() >= p.total_weight() { cp } else { p }
        )
}

fn find_unbalanced_program(p: &Program) -> (Option<&Program>, Option<&Disc>) {
    if let Some(ref d) = p.disc {
        if let Some(up) = d.unbalanced_program() {
            if let (Some(ucp), Some(ucd)) = find_unbalanced_program(&up) {
                (Some(ucp), Some(ucd))
            } else {
                (Some(up), Some(d))
            }
        } else {
            (None, None)
        }
    } else {
        (None, None)
    }
}

/// Return the weight needed to balance the tower
fn find_part2_solution(root: &Program) -> u32 {
    if let (Some(p), Some(d)) = find_unbalanced_program(&root) {
        let target_total_weight = d.programs.iter()
            .find(|dp| dp.total_weight() != p.total_weight())
            .map(|dp| dp.total_weight())
            .unwrap()
        ;

        let difference = (target_total_weight as i32) - (p.total_weight() as i32);
        let target_weight = (p.weight as i32) + difference;

        target_weight as u32
    } else {
        0
    }
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input
        .trim()
        .split('\n')
        .collect()
    ;

    let program_references: Vec<ProgramReference> = lines.iter()
        .map(|line| ProgramReference::parse(line))
        .filter(|o| match o { &Some(_) => true, &None => false })
        .map(|o| o.unwrap())
        .collect()
    ;

    let mut prs: HashMap<String, &ProgramReference> = HashMap::new();
    for pr in &program_references { prs.insert(pr.name.to_string(), &pr); }

    let mut programs: Vec<Program> = vec![];
    for pr in &program_references { programs.push(build_program(pr.name.to_string(), &prs)); }

    let root = find_bottom_disc(&programs);

    let part1_solution = root.name.to_string();
    let part2_solution = find_part2_solution(&root);

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
