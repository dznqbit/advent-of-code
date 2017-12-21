// http://adventofcode.com/2017/day/5

use std::io::{self, Read};
use std::str::FromStr;
use std::fmt;

#[derive(Debug)]
struct InstructionList {
    // Current instruction index
    i: i32,

    // Number of steps taken
    steps: u32,

    // Instruction list
    instructions: Vec<i32>
}

impl InstructionList {
    pub fn new(l:Vec<i32>) -> InstructionList {
        InstructionList {
            i: 0,       
            steps: 0,
            instructions: l
        }
    }

    /*
     * - Evaluate the jump instruction and update self.i to the new index
     * - Increment the original instruction by 1
     * - Return self.i
     */
    pub fn next<F>(&mut self, increment_instruction: F) -> Option<i32> 
        where F: Fn(i32) -> i32 {
        let initial_i = self.i;

        if let Some(instruction) = self.instructions.get_mut(self.i as usize) {
            let offset = *instruction;
            self.i = initial_i + offset;
            self.steps += 1;
            *instruction += increment_instruction(offset);
            Some(self.i)
        } else {
            None
        }
    }

    pub fn to_string(&self) -> String {
        let cells:Vec<String> = self.instructions.iter()
            .enumerate()
            .map(|(i, s)| format!("{}{}{}", if (self.i as usize) == i { "(" } else { "" }, s, if (self.i as usize) == i { ")" } else { "" }))

            .collect()
        ;

        cells.join(" ")
    }
} 

impl fmt::Display for InstructionList {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.to_string())
    }
}

fn solution<F>(lines:&Vec<&str>, increment_instruction: F) -> u32 
    where F: Fn(i32) -> i32 {
    let parsed_lines = lines.iter()
        .map(|s| i32::from_str(s).unwrap())
        .collect()
    ;

    let mut instructions = InstructionList::new(parsed_lines);

    while let Some(_) = instructions.next(&increment_instruction) {}

    instructions.steps
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input.trim().split('\n').collect();

    let part1_solution = solution(&lines, |_x| 1);
    let part2_solution = solution(&lines, |x| if x >= 3 { -1 } else { 1 });

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
