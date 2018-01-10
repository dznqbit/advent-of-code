// http://adventofcode.com/2017/day/15

use std::io::{self, Read};

#[derive(Debug)]
struct Generator {
    factor: u64,
    divisor: u64,
    value: u64
}

impl Generator {
    pub fn next(&mut self) -> u64 {
        self.value = (self.value * self.factor) % self.divisor;
        self.value
    }
}

const GEN_A_FACTOR: u64 =        16_807;
const GEN_B_FACTOR: u64 =        48_271;
const DIVISOR:      u64 = 2_147_483_647;
const TWO_16:       u64 =        65_536;

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input.trim().split('\n').collect();
    let (gen_a_init, gen_b_init) = if let (Some(gen_a_line), Some(gen_b_line)) = (lines.get(0), lines.get(1)) {
        (
            gen_a_line.replace("Generator A starts with ", "").parse::<u64>().unwrap(),
            gen_b_line.replace("Generator B starts with ", "").parse::<u64>().unwrap()
        )
    } else {
        (666, 666)
    };

    let part1_solution = {
        let mut gen_a = Generator { factor: GEN_A_FACTOR, divisor: DIVISOR, value: gen_a_init };
        let mut gen_b = Generator { factor: GEN_B_FACTOR, divisor: DIVISOR, value: gen_b_init };

        let matches = (0..40_000_000).fold(vec![], |mut acc, _| {
            let (va, vb) = (gen_a.next(), gen_b.next());

            // Compare lowest 16 bits
            if va % TWO_16 == vb % TWO_16 {
                acc.push((va, vb));
            }

            acc
        });

        matches.len()
    };

    let part2_solution = {
        let mut gen_a = Generator { factor: GEN_A_FACTOR, divisor: DIVISOR, value: gen_a_init };
        let mut gen_b = Generator { factor: GEN_B_FACTOR, divisor: DIVISOR, value: gen_b_init };

        let matches = (0..5_000_000).fold(vec![], |mut acc, _| {
            let mut va = gen_a.next();
            while va % 4 > 0 {
                va = gen_a.next();
            }

            let mut vb = gen_b.next();
            while vb % 8 > 0 {
                vb = gen_b.next();
            }

            // Compare lowest 16 bits
            if va % TWO_16 == vb % TWO_16 {
                acc.push((va, vb));
            }

            acc
        });

        matches.len()
    };

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
