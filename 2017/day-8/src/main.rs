// http://adventofcode.com/2017/day/8

use std::fmt;
use std::collections::HashMap;
use std::io::{self, Read};

enum Operation {
    INC,
    DEC
}

impl Operation {
    pub fn parse(s: &str) -> Option<Operation> {
        match s {
            "inc"   => Some(Operation::INC),
            "dec"   => Some(Operation::DEC),
            _       => None
        }
    }

    pub fn execute(&self, lh: i32, rh: i32) -> i32 {
        match *self {
            Operation::INC => lh + rh,
            Operation::DEC => lh - rh
        }
    }
}

impl fmt::Display for Operation {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f, 
            "{}", 
            match *self { 
                Operation::INC => "inc", 
                Operation::DEC => "dec"
            }
        )
    }
}

enum Comparison {
    EQ,
    GT,
    GTEQ,
    LT,
    LTEQ,
    NEQ
}

impl Comparison {
    pub fn parse(s: &str) -> Option<Comparison> {
        match s {
            "=="    => Some(Comparison::EQ),
            ">"     => Some(Comparison::GT),
            ">="    => Some(Comparison::GTEQ),
            "<"     => Some(Comparison::LT),
            "<="    => Some(Comparison::LTEQ),
            "!="    => Some(Comparison::NEQ),
            _       => None
        }
    }

    pub fn execute(&self, lh: i32, rh: i32) -> bool {
        match *self {
            Comparison::EQ      => lh == rh,
            Comparison::GT      => lh >  rh,
            Comparison::GTEQ    => lh >= rh,
            Comparison::LT      => lh <  rh,
            Comparison::LTEQ    => lh <= rh,
            Comparison::NEQ     => lh != rh
        }
    }
}

impl fmt::Display for Comparison {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let s = match *self {
            Comparison::EQ      => "==",
            Comparison::GT      => ">",
            Comparison::GTEQ    => ">=",
            Comparison::LT      => "<",
            Comparison::LTEQ    => "<=",
            Comparison::NEQ     => "!="
        };

        write!(f, "{}", s)
    }
}

struct Register {
    name: String,
    value: i32
}

impl Register {
    pub fn new(name: &str) -> Register {
        Register { name: name.to_string(), value: 0 }
   }
}

struct Instruction {
    register_name: String,
    operation: Operation,
    operation_value: i32,

    test_register_name: String,
    comparison: Comparison,
    comparison_value: i32
}

impl Instruction {
    pub fn parse(s: &str) -> Option<Instruction> {
        let tokens: Vec<&str> = s.split(" ").collect();
        
        if tokens.len() == 7 {
            let i = Instruction {
                register_name: tokens.get(0)?.to_string(),
                operation: Operation::parse(tokens.get(1)?)?,
                operation_value: tokens.get(2)?.parse::<i32>().unwrap(),

                test_register_name: tokens.get(4)?.to_string(),
                comparison: Comparison::parse(tokens.get(5)?)?,
                comparison_value: tokens.get(6)?.parse::<i32>().unwrap()
            };

            Some(i)
        } else {
            println!("\"{}\": Expected 7 tokens", s);
            None
        }
    }
}

impl fmt::Display for Instruction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f, 
            "{} {} {} if {} {} {}",
            self.register_name,
            self.operation,
            self.operation_value,
            self.test_register_name,
            self.comparison,
            self.comparison_value,
        )
    }
}

struct RegisterList {
    registers: HashMap<String, Register>
}

impl RegisterList {
    pub fn new() -> RegisterList {
        RegisterList {
            registers: HashMap::new() 
        }
    }

    pub fn get(&mut self, n: &str) -> &mut Register {
        self.registers
            .entry(n.to_string())
            .or_insert(Register::new(n))
    }

    pub fn max(&self) -> &Register {
        let values: Vec<&Register> = self.registers.values().collect();
        values.iter().max_by(|r1, r2| r1.value.cmp(&r2.value)).unwrap()
    }
}

fn solutions(instructions: &Vec<Instruction>) -> (i32, i32) {
    let mut registers = RegisterList::new();
    let mut all_time_max_value = 0;

    for i in instructions {
        let comparison_passes = {
            let test_register = registers.get(&i.test_register_name);
            i.comparison.execute(test_register.value, i.comparison_value)
        };

        if comparison_passes {
            let updated_value = {
                let register = registers.get(&i.register_name);
                i.operation.execute(register.value, i.operation_value)
            };

            let mut register = registers.get(&i.register_name);
            register.value = updated_value;

            all_time_max_value = all_time_max_value.max(register.value);
        }
    }

    (
        // Pt1 Current maximum value
        registers.max().value,

        // Pt2 All-time maximum value
        all_time_max_value
    )
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input.trim().split('\n').collect();

    let instructions:Vec<Instruction> = lines.iter()
        .map(|l| Instruction::parse(l).unwrap())
        .collect()
    ;

    let (part1_solution, part2_solution) = solutions(&instructions);

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
