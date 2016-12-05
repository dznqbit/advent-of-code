use std::io::{self, Read};
use std::fmt;
use std::str::FromStr;

use std::collections::HashMap;

// Intersection
#[derive(Clone)]
struct  Intersection  { x: i32, y: i32 }

impl fmt::Display for Intersection {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "({}, {})", self.x, self.y) }  
}

impl Intersection {
  fn origin() -> Intersection { Intersection { x: 0, y: 0 } }

  // move is apparently reserved keyword
  fn mv(&self, cd: &CardinalDirection, steps: i32) -> Intersection {
    match *cd  {
      CardinalDirection::North => Intersection { x: self.x, y: self.y + steps },
      CardinalDirection::East  => Intersection { x: self.x + steps, y: self.y },
      CardinalDirection::South => Intersection { x: self.x, y: self.y - steps },
      CardinalDirection::West  => Intersection { x: self.x - steps, y: self.y },
    }
  }

  fn distance_in_blocks(&self, rh: &Intersection) -> i32 {
    (self.x - rh.x).abs() + (self.y - rh.y).abs()
  }

  fn to_tuple(&self) -> (i32, i32) { (self.x, self.y) }
}
// END Intersection

enum CardinalDirection { North, East, South, West }
impl fmt::Display for CardinalDirection {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    match *self {
      CardinalDirection::North  => write!(f, "N"),
      CardinalDirection::East   => write!(f, "E"),
      CardinalDirection::South  => write!(f, "S"),
      CardinalDirection::West   => write!(f, "W")
    }
  }
}

impl CardinalDirection {
  fn turn(&self, direction: &Direction) -> CardinalDirection {
    match (self, direction) {
      (&CardinalDirection::North, &Direction::Left)   => CardinalDirection::West,
      (&CardinalDirection::North, &Direction::Right)  => CardinalDirection::East,
      (&CardinalDirection::North, &Direction::None)   => CardinalDirection::North,

      (&CardinalDirection::East, &Direction::Left)    => CardinalDirection::North,
      (&CardinalDirection::East, &Direction::Right)   => CardinalDirection::South,
      (&CardinalDirection::East, &Direction::None)    => CardinalDirection::East,

      (&CardinalDirection::South, &Direction::Left)   => CardinalDirection::East,
      (&CardinalDirection::South, &Direction::Right)  => CardinalDirection::West,
      (&CardinalDirection::South, &Direction::None)   => CardinalDirection::South,

      (&CardinalDirection::West, &Direction::Left)    => CardinalDirection::South,
      (&CardinalDirection::West, &Direction::Right)   => CardinalDirection::North,
      (&CardinalDirection::West, &Direction::None)    => CardinalDirection::West,
    }
  }
}

// Direction
#[derive(Clone)]
enum Direction     { Right, Left, None }
impl fmt::Display for Direction {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    match *self {
      Direction::Right  => write!(f, "R"),
      Direction::Left   => write!(f, "L"),
      Direction::None   => write!(f, "N")
    }
  }
}
// END Direction

// Instruction
#[derive(Clone)]
struct Instruction   { direction: Direction, steps: i32 }

impl fmt::Display for Instruction {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "{}{}", self.direction, self.steps) }  
}

impl Instruction {
  fn nothing() -> Instruction { 
    Instruction { direction: Direction::None, steps: 0 } 
  }

  fn parse(s: &str) -> Instruction {
    let direction = if s.starts_with('R') { Direction::Right } else { Direction::Left };
    let sub = &(*s.trim())[1..]; // I have no idea why this works.
    let steps = i32::from_str(sub).unwrap();

    Instruction { direction: direction, steps: steps }
  }
}
// END Instruction

// Frame
// instruction begat frame
struct Frame { 
  index: i32, 

  // Current Intersection.
  intersection: Intersection,
  // Current CardinalDirection.
  cardinal_direction: CardinalDirection, 

  // The Instruction that directed you to intersection/cardinal_direction.
  instruction: Instruction 
}

impl Frame {
  fn apply(frame: &Frame, instruction: Instruction) -> Frame {
    let new_cardinal_direction = frame.cardinal_direction.turn(&instruction.direction);

    Frame { 
      index: frame.index + 1, 
      intersection: frame.intersection.mv(&new_cardinal_direction, instruction.steps),
      cardinal_direction: new_cardinal_direction,
      instruction: instruction 
    }
  }
}

impl fmt::Display for Frame {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    write!(f, "F({}) {} -> {}{}", self.index, self.instruction, self.cardinal_direction, self.intersection)
  }  
}
// END Frame

fn build_frames(moves: &Vec<Instruction>) -> Vec<Frame> {
  let mut frames = Vec::with_capacity(moves.len());

  let first_frame = Frame { 
    index: 0, 
    intersection: Intersection::origin(),
    cardinal_direction: CardinalDirection::North, 
    instruction: Instruction::nothing() 
  };

  frames.push(first_frame);

  for mv in moves {
    let frame;
    let instruction = mv.clone();

    {
      // We need this scope here to avoid immutable/mutable borrow on frames.
      let ref last_frame = frames.last().unwrap();

      frame = Frame::apply(last_frame, instruction);
    }

    frames.push(frame);
  }

  frames
}


fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  
  if let Err(why) = stdin.read_to_string(&mut input) {
    panic!("Could not read STDIN: {}", why);
  }

  let move_strings: Vec<&str> = input.split(", ").collect();
  let moves: Vec<Instruction> = move_strings.iter().map(|s| { Instruction::parse(s) }).collect();
  let frames: Vec<Frame> = build_frames(&moves);

  // pt #1
  let origin = Intersection::origin();
  let pt1_bunny_hq_intersection;
  
  let ref last_frame = frames.last().unwrap();
  pt1_bunny_hq_intersection = last_frame.intersection.clone(); 

  let pt1_bunny_hq_distance_in_blocks = pt1_bunny_hq_intersection.distance_in_blocks(&origin);

  println!("Pt 1: Bunny HQ is {} blocks away", pt1_bunny_hq_distance_in_blocks);

  // pt #2
  let mut intersection_visits:HashMap<(i32, i32), i32> = HashMap::new();

  let mut cardinal_direction = CardinalDirection::North;
  let mut current_intersection = Intersection::origin();
  let mut pt2_bunny_hq_distance_in_blocks:Option<i32> = None;

  intersection_visits.insert(current_intersection.to_tuple(), 1);

  for mv in moves {
    // Turn
    cardinal_direction = cardinal_direction.turn(&mv.direction);

    // Now we're facing the correct direction, walk x steps.
    for i in 0..mv.steps {
      // "Walk"
      current_intersection = current_intersection.mv(&cardinal_direction, 1);

      let hk = current_intersection.to_tuple();
      let vc = intersection_visits.entry(hk).or_insert(0);

      *vc += 1;

      if *vc > 1 {
        let ref pt2_bunny_hq_intersection = current_intersection;
        pt2_bunny_hq_distance_in_blocks = Some(pt2_bunny_hq_intersection.distance_in_blocks(&origin));

        println!(
          "Pt 2: Bunny HQ {} is {} blocks away", 
          pt2_bunny_hq_intersection,
          pt2_bunny_hq_distance_in_blocks.unwrap()
        );

        break;
      }
    }

    if pt2_bunny_hq_distance_in_blocks != None { break;  } 
  }
}
