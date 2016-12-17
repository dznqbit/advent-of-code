use std::str;
use std::io::{self, Read};
use std::collections::VecDeque;

/// Starting indices of all abbas inside s.
fn abba_positions(s:&str) -> Vec<usize> {
  let mut window: VecDeque<char> = VecDeque::with_capacity(4);
  let mut positions: Vec<usize> = Vec::new();

  for (i, c) in s.chars().enumerate() {
    if window.len() >= 4 { window.pop_front(); } 
    
    window.push_back(c);

    // Wait until the window is loaded up before detection.
    if window.len() < 4 { continue; }

    let is_abba = window[0] == window[3] && // Outer match
                  window[1] == window[2] && // Inner match
                  window[0] != window[1]    // Out-in mismatch
    ;

    if is_abba { positions.push(i - 3); } 
  }

  positions
}

/// Starting indices of all abas inside s.
fn aba_positions(s:&str) -> Vec<usize> {
  let mut window: VecDeque<char> = VecDeque::with_capacity(3);
  let mut positions: Vec<usize> = Vec::new();

  for (i, c) in s.chars().enumerate() {
    if window.len() >= 3 { window.pop_front(); } 
    
    window.push_back(c);

    // Wait until the window is loaded up before detection.
    if window.len() < 3 { continue; }

    let is_aba = window[0] == window[2] && // Outer match
                 window[0] != window[1]    // Out-in mismatch
    ;

    if is_aba { positions.push(i - 2); } 
  }

  positions
}

/// All (index, aba) inside s.
fn abas(s:&str) -> Vec<(usize, String)> {
  aba_positions(s).iter().map(|&i| {
    let mut si = s.chars();
    if i > 0 { si.nth(i - 1); }
    let aba = si.take(3).collect();
    (i, aba)
  }).collect()
}

#[derive(Debug)]
/// Bunny Network IP. 
/// `address`   : the actual address
/// `hypernets` : the network sequences inside [] brackets
/// `supernets` : the network sequences outside [] brackets
struct IP { address: String, supernets: Vec<String>, hypernets: Vec<String> }

impl IP {
  fn new(address:&str) -> IP {
    let mut current_open_bracket_idx:Option<usize> = None;

    let mut supernet = String::new();
    let mut supernets:Vec<String> = Vec::new();

    let mut hypernet = String::new();
    let mut hypernets:Vec<String> = Vec::new();

    for (i, c) in address.chars().enumerate() {
      match c {
        '[' => {
          supernets.push(supernet.clone());
          supernet.clear();
          current_open_bracket_idx = Some(i); 
        },

        ']' => {
          hypernets.push(hypernet.clone());
          hypernet.clear();
          current_open_bracket_idx = None;    
        },

        _ => {
          match current_open_bracket_idx {
            Some(_) => hypernet.push(c),
            None    => supernet.push(c)
          }
        }
      }
    }

    if !supernet.is_empty() { supernets.push(supernet.clone()); }
    if !hypernet.is_empty() { hypernets.push(hypernet.clone()); }

    IP { address: address.to_string(), supernets: supernets, hypernets: hypernets }
  }

  /// An address is TLS if it contains at least 1 abba in the supernets and 0 abbas in the hypernets.
  fn is_tls(&self) -> bool {
    self.hypernets.iter().all(|s|  abba_positions(s).is_empty()) &&
    self.supernets.iter().any(|s| !abba_positions(s).is_empty())
  }

  /// An address is SSL if it contains 1 ABA in the supernets _and_ corresponding BAB in hypernets.
  fn is_ssl(&self) -> bool {
    self.supernets.iter().any(|supernet| {
      abas(&supernet).iter().any(|&(_, ref aba)| {
        let mut aba_chars = aba.chars();
        
        let a:char = aba_chars.next().unwrap();
        let b:char = aba_chars.next().unwrap();
        let bab:String = format!("{}{}{}", b, a, b);

        self.hypernets.iter().any(|&ref s| s.contains(&bab))
      })
    })
  }
}

fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

  let s = input.trim().clone();
  let lines:Vec<&str> = s.split("\n").collect();
  let ips:Vec<IP> = lines.iter().map(|line| IP::new(line)).collect();

  let tls_ips:Vec<&IP> = ips.iter().filter(|ip| ip.is_tls()).collect();
  println!("Pt 1: {}", tls_ips.len());

  let ssl_ips:Vec<&IP> = ips.iter().filter(|ip| ip.is_ssl()).collect();
  println!("Pt 2: {}", ssl_ips.len());
}
