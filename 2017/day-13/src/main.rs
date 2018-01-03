// http://adventofcode.com/2017/day/13

use std::io::{self, Read};
use std::collections::HashMap;
use std::fmt;

#[derive(Debug)]
enum ScannerDirection {
    UP,
    DOWN
}

#[derive(Debug)]
struct FirewallLayer {
    range: usize,
    // Ideally this would be a usize, but it's not playing nicely with -1
    scanner_index: i32,
    scanner_direction: ScannerDirection
}

impl FirewallLayer {
    pub fn new(range: usize) -> FirewallLayer {
        FirewallLayer {
            range: range,
            scanner_index: 0,
            scanner_direction: ScannerDirection::UP
        }
    }

    pub fn empty() -> FirewallLayer {
        FirewallLayer {
            range: 0,
            scanner_index: 0,
            scanner_direction: ScannerDirection::UP
        }
    }

    pub fn is_active(&self) -> bool { self.range > 0 }

    pub fn tick(&mut self) {
        if !self.is_active() { return }

        // Update direction, if necessary
        let end_of_range: i32 = (self.range as i32) - 1;
        match (self.scanner_index, &self.scanner_direction) {
            (s, &ScannerDirection::UP) if s == end_of_range => self.scanner_direction = ScannerDirection::DOWN,
            (0, &ScannerDirection::DOWN)                    => self.scanner_direction = ScannerDirection::UP,
            _                                               => {}
        };

        // Update position
        self.scanner_index += match &self.scanner_direction {
            &ScannerDirection::UP    =>  1,
            &ScannerDirection::DOWN  => -1
        };

        // Idiot check
        if self.scanner_index < 0 { panic!("Never expect scanner_index to be < 0"); }
    }
}

impl fmt::Display for FirewallLayer {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.range == 0 {
            write!(f, "...")
        } else {
            let rs:Vec<String> = (0..self.range).map(|n| if n == (self.scanner_index as usize) { "[S]".to_string() } else { "[ ]".to_string() }).collect();
            write!(f, "{}", rs.join(" "))
        }
    }
}

fn build_firewall(input: &String) -> Vec<FirewallLayer> {
    let lines:Vec<&str> = input.trim().split('\n').collect();
    let security_layers_definitions: Vec<(usize, usize)> = lines.iter()
        .map(|s| {
            let layers_and_depths: Vec<&str> = s.split(": ").collect();
            let ns: Vec<usize> = layers_and_depths
                .iter()
                .map(|ns| ns.parse::<usize>().unwrap())
                .collect()
            ;

            (ns[0], ns[1])
        })
        .collect()
    ;

    let mut firewall: Vec<FirewallLayer> = vec![];

    for (layer, depth) in security_layers_definitions {
        for _ in firewall.len()..layer {
            firewall.push(FirewallLayer::empty());
        }

        firewall.push(FirewallLayer::new(depth));
    }

    firewall
}

/// Vec of layers on which we're "caught". Vec<(depth, range)>
fn traverse_firewall(firewall: &mut Vec<FirewallLayer>) -> Vec<(usize, usize)> {
    let mut catches = vec![];

    for i in 0..firewall.len() {
        // Check for catches
        if let Some(fl) = firewall.get(i) {
            if fl.is_active() && fl.scanner_index == 0 {
                catches.push((i, fl.range));
            }
        }

        // Update all scanners
        for fl in firewall.iter_mut() {
            fl.tick();
        }
    }

    catches
}

/// Return the shortest delay possible for an undetected run
fn delay_for_first_undetected_run(firewall: &mut Vec<FirewallLayer>) -> usize {
    let mut runners: HashMap<usize, usize> = HashMap::new();

    for i in 0.. {
        // Manage runner positions
        //     Tick existing runner poisitions
        for (_, position) in runners.iter_mut() {
            *position += 1;
        }
        //     Insert new runner
        runners.insert(i, 0);

        // Remove any collided runners
        runners.retain(|_, &mut p| {
            if p < firewall.len() { 
                let fl = firewall.get(p).unwrap();
                !fl.is_active() || fl.scanner_index > 0
            } else {
                true 
            }
        });

        if let Some((successful_delay, _)) = runners.iter()
            .find(|&(_, p)| p >= &firewall.len()) {
            return *successful_delay
        }

        // Tick guard positions
        for fl in firewall.iter_mut() {
            fl.tick();
        }
    }

    0
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let part1_solution = {
        let mut firewall = build_firewall(&input);
        let catches = traverse_firewall(&mut firewall);
        catches.iter().fold(0, |acc, &(depth, range)| acc + depth * range)
    };

    let part2_solution = {
        let mut firewall = build_firewall(&input);
        delay_for_first_undetected_run(&mut firewall)
    };

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
