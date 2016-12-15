use std::io::{self, Read};

fn split(s: &str) -> [i32;3] { 
  let vec:Vec<i32> = s.split_whitespace().map(|x| x.trim().parse::<i32>().unwrap()).collect();
  [vec[0], vec[1], vec[2]]
}

#[derive(Debug)]
struct Triangle { a: i32, b: i32, c: i32 }
impl Triangle {
  fn parse(s: &str) -> Triangle {
    let splits = split(s);
    Triangle { a: splits[0], b: splits[1], c: splits[2] }
  }

  fn is_valid(&self) -> bool {
    (self.a + self.b > self.c) &&
    (self.b + self.c > self.a) &&
    (self.c + self.a > self.b)
  }
}

fn part_one(lines: &Vec<&str>) {
  let triangles: Vec<Triangle> = lines.iter().map(|s| Triangle::parse(s)).collect();
  let valid_triangles: Vec<&Triangle> = triangles.iter().filter(|t| (*t).is_valid()).collect();

  let num_triangles = triangles.len();
  let num_valid_triangles = valid_triangles.len();
  println!("Day 3 Pt. 1: {}/{} Valid Triangles", num_valid_triangles, num_triangles);
}

fn part_two(lines: &Vec<&str>) {
  let num_lines = lines.len();
  let mut triangles: Vec<Triangle> = Vec::with_capacity(num_lines);

  for i in 0..(num_lines / 3) {
    let base = i * 3;
    let rows = [split(lines[base + 0]), split(lines[base + 1]), split(lines[base + 2])]; 
    for x in 0..3 { 
      let triangle = Triangle { a: rows[0][x], b: rows[1][x], c: rows[2][x] };
      triangles.push(triangle) 
    }
  }

  let valid_triangles: Vec<&Triangle> = triangles.iter().filter(|t| (*t).is_valid()).collect();

  let num_triangles = triangles.len();
  let num_valid_triangles = valid_triangles.len();
  println!("Day 3 Pt. 2: {}/{} Valid Triangles", num_valid_triangles, num_triangles);
}

fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }
  let lines:Vec<&str> = input.trim().split('\n').collect();

  part_one(&lines);
  part_two(&lines);
}
