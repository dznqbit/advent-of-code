use std::fmt;
use std::io::{self, Read};
use std::iter::Peekable;
use std::str::Chars;

struct Marker { num_chars: usize, repeats: u32 }

impl fmt::Display for Marker {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    write!(f, "({}x{})", self.num_chars, self.repeats) 
  }  
}

impl Marker {
  fn decompressed_length(&self) -> usize { self.num_chars * (self.repeats as usize) }
  fn decompress(&self, s:&str) -> String {
    if s.len() != self.num_chars { panic!("Cannot decompress \"{}\" ({} != {})", s, self.num_chars, s.len()); }

    let mut out = String::with_capacity(self.decompressed_length());
    for _ in 0..self.repeats { out.push_str(s); }
      
    out
  }
}

/*
  The format compresses a sequence of characters. Whitespace is ignored. 
  
  To indicate that some sequence should be repeated, a marker is added to the file, 
  like (10x2). 
  
  To decompress this marker, take the subsequent 10 characters and repeat them 2
  times. Then, continue reading the file after the repeated data. 
  
  The marker itself is not included in the decompressed output.

  If parentheses or other characters appear within the data referenced by a marker, 
  that's okay - treat it like normal data, not a marker, and then resume looking for markers 
  after the decompressed section.
*/
fn scan_digits(mut pi:&mut Peekable<Chars>) -> usize {
  let mut ds = String::new();

  loop {
    match pi.peek() {
      c @ Some(&'0'...'9') => ds.push(*c.unwrap()),
      _                   => break
    }

    pi.next();
  }

  if ds.len() > 0 {
    ds.parse().unwrap()
  } else {
    0
  }
}

fn consume_compressed(mut pi:&mut Peekable<Chars>) -> (Marker, String) {
  // Marker will match /\((\d+)x(\d+)\)/

  // Grab the char count
  let sc = scan_digits(pi);

  // Skip the 'x'
  pi.next();

  // Grab the repeat count
  let rc = scan_digits(pi) as u32;

  // Skip the )
  pi.next();

  let mut s = String::new();
  for _ in 0..sc {
    match pi.next() {
      Some(x) => s.push(x),
      _       => panic!("Expected {} characters", sc)
    }
  }

  // Find Marker
  // Take num chars
  (Marker { num_chars: sc, repeats: rc }, s)
}

fn consume_simple(mut pi:&mut Peekable<Chars>, first_char:char) -> (Marker, String) { 
  let mut s:String = String::new();
  s.push(first_char);

  loop {
    match pi.peek() {
      Some(&'(')  => break,
      Some(&x)    => s.push(x),
      None        => break
    }

    pi.next();
  }

  (Marker { num_chars: s.len(), repeats: 1 }, s)
}

fn split(s:&str) -> Vec<(Marker, String)> {
  let mut ms:Vec<(Marker, String)> = Vec::new();
  let mut ci = s.chars().peekable();

  loop {
    let nms = match ci.next() {
      Some('(')   => consume_compressed(&mut ci),
      Some(x)     => consume_simple(&mut ci, x),
      None        => break
    };

    ms.push(nms);
  }

  ms
}

/// compute the decompressed length of a string, don't expand markers
/// `s` : str to compute
fn cdl(s:&str) -> u32 {
  split(s)
    .iter()
    .fold(0, |a, &(ref m, ref s)| a + m.decompress(&s).len() as u32)
}

/// compute the decompressed length of a string, do expand markers
/// `s` : str to compute
fn cdl2(s:&str) -> u32 {
  split(s)
    .iter()
    .fold(0, |a, &(ref m, ref s)| {
      let sl = if s.contains('(') { m.repeats * cdl2(s) }
               else               { m.decompress(&s).len() as u32 }
      ;
      
      a + sl
    })
}

fn tests() {
  let mut tests:Vec<(String, u32)> = Vec::new();
  
  // ADVENT contains no markers and decompresses to itself with no changes, 
  //   resulting in a decompressed length of 6.
  tests.push(("ADVENT".to_string(), 6));

  // A(1x5)BC repeats only the B a total of 5 times, 
  //   becoming ABBBBBC for a decompressed length of 7.
  tests.push(("A(1x5)BC".to_string(), 7));

  // (3x3)XYZ becomes XYZXYZXYZ for a decompressed length of 9.
  tests.push(("(3x3)XYZ".to_string(), 9));

  // A(2x2)BCD(2x2)EFG doubles the BC and EF, 
  //   becoming ABCBCDEFEFG for a decompressed length of 11.
  tests.push(("A(2x2)BCD(2x2)EFG".to_string(), 11));

  // (6x1)(1x3)A simply becomes (1x3)A - the (1x3) looks like a marker, 
  //   but because it's within a data section of another marker, 
  //   it is not treated any differently from the A that comes after it. 
  //   It has a decompressed length of 6.
  tests.push(("(6x1)(1x3)A".to_string(), 6));

  // X(8x2)(3x3)ABCY becomes X(3x3)ABC(3x3)ABCY (for a decompressed length of 18), 
  //   because the decompressed data from the (8x2) marker (the (3x3)ABC) is skipped and not 
  //   processed further.
  tests.push(("X(8x2)(3x3)ABCY".to_string(), 18));

  for (s, l) in tests { 
    let cdl = compute_decompressed_length(&s);
    println!("{:02} == {:02} {}\t{}", cdl, l, if cdl == l { "OK" } else { "NO" }, s);
  }
}

fn pt2_tests() {
  let mut tests:Vec<(String, u32)> = Vec::new();

  // (3x3)XYZ still becomes XYZXYZXYZ, as the decompressed section contains no markers.
  tests.push(("(3x3)XYZ".to_string(), 9));

  // X(8x2)(3x3)ABCY becomes XABCABCABCABCABCABCY, because the decompressed data from the 
  //   (8x2) marker is then further decompressed, thus triggering the (3x3) marker twice 
  //   for a total of six ABC sequences.
  tests.push(("X(8x2)(3x3)ABCY".to_string(), 20));

fn pt2_tests() {
  let mut tests:Vec<(String, u32)> = Vec::new();

  // (3x3)XYZ still becomes XYZXYZXYZ, as the decompressed section contains no markers.
  tests.push(("(3x3)XYZ".to_string(), 9));

  // X(8x2)(3x3)ABCY becomes XABCABCABCABCABCABCY, because the decompressed data from the 
  //   (8x2) marker is then further decompressed, thus triggering the (3x3) marker twice 
  //   for a total of six ABC sequences.
  tests.push(("X(8x2)(3x3)ABCY".to_string(), 20));

  // (27x12)(20x12)(13x14)(7x10)(1x12)A decompresses into a string of A repeated 241920 times.
  tests.push(("(27x12)(20x12)(13x14)(7x10)(1x12)A".to_string(), 241920));

  // (25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN becomes 445 characters long.
  tests.push(("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN".to_string(), 445));

  for (s, l) in tests { 
    let cdl = cdl2(&s);
    println!("{:06} == {:06} {}\t{}", cdl, l, if cdl == l { "OK" } else { "NO" }, s);
  }
}

fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }
  let s = input.trim().clone();

  println!("Pt 1: {}", cdl(s));
  println!("Pt 2: {}", cdl2(s));
}
