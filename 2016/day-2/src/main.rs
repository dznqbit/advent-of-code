use std::io::{self, Read};
use std::fmt;
use std::collections::HashMap;

#[derive(Debug)]
enum Direction { Up, Right, Down, Left }
impl Direction {
  fn parse(s: char) -> Direction {
    match s {
      'U' => Direction::Up,
      'R' => Direction::Right,
      'D' => Direction::Down,
      'L' => Direction::Left,
       _  => panic!()
    }
  }
}

// Origin: upper-right.
#[derive(PartialEq, Eq, Hash)]
struct Coordinates { x: i32, y: i32 }

impl fmt::Display for Coordinates {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "({}, {})", self.x, self.y) }  
}

struct Keypad { buttons: HashMap<Coordinates, char>, cursor: Coordinates }

impl Keypad {
  fn new_part_one() -> Keypad {
    let mut buttons:HashMap<Coordinates, char> = HashMap::new();

    for i in 0..9 {
      let coordinates = Coordinates { x: i % 3, y: i / 3 };
      let v = (i + 1).to_string().chars().next().unwrap();
      buttons.insert(coordinates, v);
    }

    Keypad { buttons: buttons, cursor: Coordinates { x: 1, y: 1 } }
  }

  fn new_part_two() -> Keypad {
    let mut buttons:HashMap<Coordinates, char> = HashMap::new();

    // Hand-build this weird ass star thing.
    buttons.insert(Coordinates { x: 2, y: 0 }, '1');
    buttons.insert(Coordinates { x: 1, y: 1 }, '2');
    buttons.insert(Coordinates { x: 2, y: 1 }, '3');
    buttons.insert(Coordinates { x: 3, y: 1 }, '4');
    buttons.insert(Coordinates { x: 0, y: 2 }, '5');
    buttons.insert(Coordinates { x: 1, y: 2 }, '6');
    buttons.insert(Coordinates { x: 2, y: 2 }, '7');
    buttons.insert(Coordinates { x: 3, y: 2 }, '8');
    buttons.insert(Coordinates { x: 4, y: 2 }, '9');
    buttons.insert(Coordinates { x: 1, y: 3 }, 'A');
    buttons.insert(Coordinates { x: 2, y: 3 }, 'B');
    buttons.insert(Coordinates { x: 3, y: 3 }, 'C');
    buttons.insert(Coordinates { x: 2, y: 4 }, 'D');

    Keypad { buttons: buttons, cursor: Coordinates { x: 0, y: 2 } }
  }

  fn mv(&mut self, d: Direction) -> char {
    let update = match d {
      Direction::Up     => ( 0, -1),
      Direction::Right  => ( 1,  0),
      Direction::Down   => ( 0,  1),
      Direction::Left   => (-1,  0)
    };

    let nc = Coordinates { x: self.cursor.x + update.0, y: self.cursor.y + update.1 };
    if self.buttons.contains_key(&nc) { self.cursor = nc; }
    self.v()
  }

  fn v(&self) -> char { *(self.buttons.get(&self.cursor).unwrap()) }
}

fn parse(keypad: &mut Keypad, lines: &Vec<&str>) -> String {
  let mut codes:Vec<char> = Vec::new();

  for line in lines.iter() {
    for s in line.chars() { keypad.mv(Direction::parse(s)); }
    codes.push(keypad.v());
  }

  let code_strings:Vec<String> = codes.iter().map(|i| { i.to_string() }).collect();
  let s = code_strings.join("");

  s
}

fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }
  let lines:Vec<&str> = input.trim().split('\n').collect();

  let mut keypad_part_one = Keypad::new_part_one();
  let code_part_one = parse(&mut keypad_part_one, &lines);
  println!("Part 1: {}", code_part_one);

  let mut keypad_part_two = Keypad::new_part_two();
  let code_part_two = parse(&mut keypad_part_two, &lines);
  println!("Part 2: {}", code_part_two);
}
