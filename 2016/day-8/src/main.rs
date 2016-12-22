use std::io::{self, Read};
use std::fmt;
use std::result;

struct Screen {
  rows: Vec<Vec<bool>>,
  w: u32,
  h: u32,
}

impl fmt::Display for Screen {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    fn _border(f: &mut fmt::Formatter, w:u32) -> fmt::Result {
      write!(f, "+");
      let hb:String = (0..w).map(|_| '-').collect();
      write!(f, "{}", hb);
      write!(f, "+");
      write!(f, "\n")
    }

    _border(f, self.w);

    for row in &(self.rows) {
      write!(f, "|");
      for pixel in row {
        let b = if *pixel { '#' } else { '.' };
        write!(f, "{}", b);
      }
      write!(f, "|\n");
    }

    _border(f, self.w)
  }
}

impl Screen {
  fn new(w:u32, h:u32) -> Screen {
    let mut rows:Vec<Vec<bool>> = Vec::with_capacity(h as usize);
    for _ in 0..h { rows.push((0..w).map(|_| false).collect()); }
    Screen { rows: rows, w: w, h: h }
  }

  fn execute(&mut self, op:&Operation) -> Result<(), &'static str> {
    match *op {
      Operation::Rect { x, y }        => self.rect(x, y),
      Operation::RotateRow { y, num } => self.rotate_row(y, num),
      Operation::RotateCol { x, num } => self.rotate_col(x, num),
    }
  }

  /// Return the values in a column.
  fn col(&self, x:u32) -> Vec<bool> { self.rows.iter().map(|r| r[x as usize]).collect() }

  /// Returns the count of lit pixels.
  fn lit_pixel_count(&self) -> u32 {
    self.rows.iter().fold(0, |acc, ref r| acc + (r.iter().filter(|&p| *p).count() as u32))
  }

  /// Draw a rectangle.
  fn rect(&mut self, x:u32, y:u32) -> Result<(), &'static str> {
    for yi in 0..y {
      for xi in 0..x { self.rows[yi as usize][xi as usize] = true; }
    }

    Ok(())
  }

  /// Rotate a row
  fn rotate_row(&mut self, y:u32, num:u32) -> Result<(), &'static str> {
    let ref mut row:Vec<bool> = self.rows[y as usize];
    let old_row:Vec<bool> = row.clone();

    for xi in 0..self.w {
      row[((xi + num) % self.w) as usize] = old_row[xi as usize];
    }

    Ok(())
  }

  /// Rotate a col
  fn rotate_col(&mut self, x:u32, num:u32) -> Result<(), &'static str> {
    let old_col:Vec<bool> = self.col(x);

    for yi in 0..self.h {
      self.rows[((yi + num) % self.h) as usize][x as usize] = old_col[yi as usize];
    }

    Ok(())
  }
}

enum Operation {
  Rect      {   x: u32,   y: u32 },
  RotateRow {   y: u32, num: u32 },
  RotateCol {   x: u32, num: u32 },
}

impl fmt::Display for Operation {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    match *self {
      Operation::Rect { x, y }        => write!(f, "Rect({}x{})", x, y),
      Operation::RotateRow { y, num } => write!(f, "RotateRow({} by {})", y, num),
      Operation::RotateCol { x, num } => write!(f, "RotateCol({} by {})", x, num), 
    }
  }  
}

impl Operation {
  fn parse(s:&str) -> Operation {
    fn _parse_rect(s:&str) -> Operation {
      // "rect 1x2"
      let dims_s:String = s.chars().skip(5).collect();
      let dims:Vec<u32> = dims_s
        .split('x')
        .map(|s| s.parse::<u32>().unwrap())
        .collect()
      ;

      Operation::Rect { x: dims[0], y: dims[1] }
    }

    fn _parse_rotate_row(s:&str) -> Operation {
      // "rotate row y=0 by 2"
      let sliced_s:String = s.chars().skip(13).collect();
      let dims:Vec<u32>  = sliced_s
        .split(" by ")
        .map(|s| s.parse::<u32>().unwrap())
        .collect()
      ;

      Operation::RotateRow { y: dims[0], num: dims[1] }
    }

    fn _parse_rotate_col(s:&str) -> Operation {
      // "rotate column x=32 by 1"
      let sliced_s:String = s.chars().skip(16).collect();
      let dims:Vec<u32>  = sliced_s
        .split(" by ")
        .map(|s| s.parse::<u32>().unwrap())
        .collect()
      ;

      Operation::RotateCol { x: dims[0], num: dims[1] }
    }

    if s.contains("rect ")           { return _parse_rect(s);       }
    if s.contains("rotate row y")    { return _parse_rotate_row(s); }
    if s.contains("rotate column x") { return _parse_rotate_col(s); }

    panic!("Could not parse \"{}\"", s);
  }
}

fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }
  let s = input.trim().clone();

  let lines:Vec<&str> = s.split("\n").collect();
  let operations:Vec<Operation> = lines.iter().map(|s| Operation::parse(&s)).collect();
  let mut screen:Screen = Screen::new(50, 6);

  for op in &operations { screen.execute(&op); }

  println!("Pt 1: {}", screen.lit_pixel_count());
  println!("Pt 2: \n{}", screen);
}
