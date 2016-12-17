use std::slice;
use std::str;
use std::fmt::Write;
use std::io::{self, Read};

use std::collections::HashMap;

fn build_cols(lines:&Vec<&str>) -> Vec<String> {
  let num_cols = lines.first().unwrap().len();
  let mut cols:Vec<String> = Vec::with_capacity(num_cols);
  for _ in 0..num_cols { cols.push(String::new()); }

  for line in lines {
    for (i, c) in line.char_indices() { cols[i].push(c) }
  }

  cols
}

fn most_frequent_char(s:&str) -> char {
  let counts:HashMap<char, u32> = s.chars()
    .fold(HashMap::new(), |mut counts, c| { *(counts.entry(c).or_insert(0)) += 1; counts })
  ;

  let mfc:(char, u32) = counts.iter().fold((' ', 0), |cur, chr| if cur.1 > *chr.1 { cur } else { (*chr.0, *chr.1) });

  mfc.0
}

fn least_frequent_char(s:&str) -> char {
  let counts:HashMap<char, u32> = s.chars()
    .fold(HashMap::new(), |mut counts, c| { *(counts.entry(c).or_insert(0)) += 1; counts })
  ;

  let lfc:(char, u32) = counts.iter().fold((' ', 1000), |cur, chr| if cur.1 < *chr.1 { cur } else { (*chr.0, *chr.1) });

  lfc.0
}


fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

  let s = input.trim().clone();
  let lines:Vec<&str> = s.split("\n").collect();

  if lines.len() == 0 { println!("No lines! :("); return; }
  // for (i, line) in lines.iter().enumerate() { println!("{:03}: {}", i, line); }

  let cols = build_cols(&lines);
  
  // for col in cols { println!("{}", col); }
  let pt1_code:String = cols.iter().map(|col| most_frequent_char(&col)).collect();
  println!("Pt 1: {}", pt1_code);

  let pt2_code:String = cols.iter().map(|col| least_frequent_char(&col)).collect();
  println!("Pt 2: {}", pt2_code);
}
