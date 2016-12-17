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

fn pt1_password(key:&str) -> String {
  let mut md5 = Md5::new();
  let mut password = String::new();
  let mut indices = 3000000..;

  while password.len() < 1 {
    let idx = indices.next().unwrap();

    md5.reset();
    md5.input(key.to_string().as_bytes());
    md5.input(idx.to_string().as_bytes());

    let mut hash = [0; 16];
    md5.result(&mut hash);

    let c = hash[2] & 0x0F;

    if check_first_five(&hash) {
      // Grab the 6th character in the hash.
      // Bitwise AND out the 5th char, write the 6th out to password.
      write!(&mut password, "{:x}", c).unwrap();
      continue;
    }

    // Animation
    mv(1, 2);
    printw(format!(" santops> H4XING PT 1 {}{} ", key, idx).as_ref());
    printw(&password);
    printw(format!("{:x}", c).as_ref());

    refresh();
  }

  password.clone()
}

// sloppy, but hey we're still under the rule of 3s ;D
fn pt2_password(key:&str) -> String {
  let mut md5 = Md5::new();
  let mut password:[i32;8] = [-1; 8]; // String::from("        ");
  let mut indices = 0..;

  fn password_incomplete(a:&[i32;8]) -> bool {
    for c in a { if *c == -1 { return true } }
    false
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

  while password_incomplete(&password) {
    let idx = indices.next().unwrap();

    md5.reset();
    md5.input(key.to_string().as_bytes());
    md5.input(idx.to_string().as_bytes());

    let mut hash = [0; 16];
    md5.result(&mut hash);

    let sixth_char    = (hash[2] & 0x0F) as usize;
    let seventh_char  = hash[3] >> 4;


    if check_first_five(&hash) {
      // 6th character determines location (zero-based index).
      // 7th character determines contents.
      if sixth_char < 8 && password[sixth_char] == -1 {
        password[sixth_char] = seventh_char as i32;
      }
    }

    // Animation
    let chs = cool_hacker_s(&password, sixth_char, seventh_char);
    mv(2, 2);
    printw(format!(" santops> H4XING PT 2 {}{} ", key, idx).as_ref());
    printw(&chs);
    refresh();
  }

  let mut out = String::new();
  for c in &password { write!(&mut out, "{:x}", c).unwrap(); }
  out.clone()
}

fn main() {
  initscr();

  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

  let key = input.trim().clone();

  let pt1_password = pt1_password(&key);
  let pt2_password = pt2_password(&key);

  endwin();

  println!("\nPt 1: {}", pt1_password);
  println!("\nPt 2: {}", pt2_password);
}
