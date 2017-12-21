// http://adventofcode.com/2017/day/6

use std::io::{self, Read};
use std::fmt;
use std::collections::HashSet;

struct MemoryBank {
    block_count: u32
}

impl MemoryBank {
    fn len(&self) -> u32 {
        self.block_count
    }

    fn clear_blocks(&mut self) -> u32 {
        self.block_count = 0;
        self.block_count
    }

    fn add_block(&mut self) -> u32 {
        self.block_count += 1;
        self.block_count
    }

    fn to_string(&self) -> String {
        format!("[{:3}]", self.block_count)
    }
}

impl fmt::Display for MemoryBank {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.to_string())
    }
}

struct MemoryArea {
    memory_banks: Vec<MemoryBank>
}

impl MemoryArea {
    /// Constructor
    pub fn new(banks:Vec<u32>) -> MemoryArea {
        MemoryArea {
            memory_banks: banks
                .iter()
                .map(|i| MemoryBank { block_count: *i })
                .collect()
        }
    }

    /// Returns number of MemoryBanks available
    pub fn len(&self) -> usize { return self.memory_banks.len() }

    /// Returns the index of the memory bank with the most blocks 
    /// (ties won by the lowest-numbered memory bank)
    pub fn largest_bank_index(&self) -> usize {
        let largest_bank = self.memory_banks
            .iter()
            .enumerate()
            .fold(
                (0, 0), 
                |(gi, glen), (i, mb)| 
                if mb.len() > glen {
                    (i, mb.len())
                } else {
                    (gi, glen)
                }
            )
        ;

        largest_bank.0
    }

    /// Rebalance the entire area until we find a previous state
    pub fn rebalance(&mut self) -> u32 {
        let mut states = HashSet::new();
        let mut num_rebalances = 0;

        states.insert(self.hash_key());

        loop {
            self.rebalance_single();
            num_rebalances += 1;

            if states.contains(&self.hash_key()) {
                break;
            } else {
                states.insert(self.hash_key());
            }
        }

        num_rebalances
    }

    /// Rebalance the largest bank with round-robin allocation
    /// Starting with the following bank
    fn rebalance_single(&mut self) {
        let lbi = self.largest_bank_index();
        let blocks_to_distribute = self.memory_banks.get(lbi).unwrap().len();

        // Clear 
        self.memory_banks.get_mut(lbi).unwrap().clear_blocks();

        // Redistribute
        for i in 1..(blocks_to_distribute + 1) {
            let cbi = (lbi + i as usize) % self.len();
            self.memory_banks.get_mut(cbi).unwrap().add_block();
            // println!("Rebalance Step {:3}: {}", i, self);
        }
    }

    /// Return a string suitable for hashing
    fn hash_key(&self) -> String {
         let memory_bank_strs: Vec<String> = self.memory_banks
            .iter()
            .map(|mb| mb.to_string())
            .collect()
        ;

        memory_bank_strs.join(" ")
    }
}

impl fmt::Display for MemoryArea {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let memory_bank_strs: Vec<String> = self.memory_banks
            .iter()
            .map(|mb| mb.to_string())
            .collect()
        ;

        write!(f, "{}", memory_bank_strs.join(" "))
    }
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let banks:Vec<u32> = input
        .trim()
        .split('\t')
        .map(|s| s.parse().unwrap())
        .collect()
    ;

    let mut memory_area = MemoryArea::new(banks);

    let part1_solution = memory_area.rebalance(); 
    let part2_solution = memory_area.rebalance(); 

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
