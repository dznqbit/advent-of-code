extern crate crypto;
extern crate ncurses;

use ncurses::*;

use crypto::md5::Md5;
use crypto::digest::Digest;

use std::fmt::Write;
use std::io::{self, Read};

fn check_first_five(hash:&[u8]) -> bool {
  // Nice little trick
  // https://gist.github.com/gkbrk/2e4835e3a17b3fb6e1e7
  let first_five = hash[0] as i32 + hash[1] as i32 + (hash[2] >> 4) as i32;
  first_five == 0
}

fn cool_hacker_s(pw:&[i32;8], pi:usize, pv:u8) -> String {
  let mut s = String::new();

  for (i, &c) in pw.iter().enumerate() { 

    if pi == i {
      s.push_str(format!("{:x}", pv).as_ref());
    } else {
      if c == -1 {
        s.push('_');
      } else {
        s.push_str(format!("{:x}", c).as_ref());
      }
    }
  }

  s
}

fn pt1_password_complete(p:&str)      -> bool { p.len() >= 8 }
fn pt2_password_complete(a:&[i32;8])  -> bool { for c in a { if *c == -1 { return false } }; true }

fn hack(key:&str) -> (String, String) {
  let mut md5 = Md5::new();
  let mut indices = 0..;

  let mut pt1_password = String::new();
  let mut pt2_password:[i32;8] = [-1; 8];

  while !(pt1_password_complete(&pt1_password) && pt2_password_complete(&pt2_password)) {
    let idx = indices.next().unwrap();

    md5.reset();
    md5.input(key.to_string().as_bytes());
    md5.input(idx.to_string().as_bytes());

    let mut hash = [0; 16];
    md5.result(&mut hash);

    // Bitwise AND out the 5th char, write the 6th out to password.
    let sixth_char    = hash[2] & 0x0F;
    // Bitwise downshift the 7th hex to the 8th
    let seventh_char  = hash[3] >> 4;

    if check_first_five(&hash) {
      if !pt1_password_complete(&pt1_password) {
        // Grab the 6th character in the hash.
        write!(&mut pt1_password, "{:x}", sixth_char).unwrap();
      }

      if !pt2_password_complete(&pt2_password) {
        // 6th character determines location (zero-based index).
        // 7th character determines contents.
        if sixth_char < 8 && pt2_password[sixth_char as usize] == -1 {
          pt2_password[sixth_char as usize] = seventh_char as i32;
        }
      }
    }

    // Animation

    // Pt 1
    mv(1, 2);
    printw(format!(" santops> H4XING PT 1 {}{} ", key, idx).as_ref());
    printw(&pt1_password);
    printw(format!("{:x}", sixth_char).as_ref());

    // Pt 2
    let chs = cool_hacker_s(&pt2_password, sixth_char as usize, seventh_char);
    mv(2, 2);
    printw(format!(" santops> H4XING PT 2 {}{} ", key, idx).as_ref());
    printw(&chs);

    refresh();
  }

  let mut pt2_out = String::new();
  for c in &pt2_password { write!(&mut pt2_out, "{:x}", c).unwrap(); }

  (pt1_password, pt2_out)
}

fn main() {
  initscr();

  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

  let key = input.trim().clone();

  let (pt1_password, pt2_password) = hack(&key);

  endwin();

  println!("\nPt 1: {}", pt1_password);
  println!("Pt 2: {}\n", pt2_password);
}

