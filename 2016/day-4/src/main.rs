use std::fmt;
use std::io::{self, Read};
use std::collections::HashMap;

#[derive(Debug)]
struct Room { name: String, sector_id: i32, checksum: String }

impl Room {
  /// Construct a `Room` from a string.
  fn parse(s: &str) -> Room {
    let mut split:Vec<&str> = s.split('-').collect();
    // Set up sector_id_and_cksum as a "draining iterator", pretty cool...
    let mut sector_id_and_cksum = String::from(split.pop().unwrap());
    let name = split.join("-");

    let first_bracket_offset = sector_id_and_cksum.find('[').unwrap_or(sector_id_and_cksum.len());
    let sector_id_s:String = sector_id_and_cksum.drain(..first_bracket_offset).collect();
    // http://stackoverflow.com/questions/23430735/how-to-convert-vecchar-to-a-string
    let sector_id:i32 = sector_id_s.parse::<i32>().unwrap();

    // skip the bracket, probably a better way to do this.
    sector_id_and_cksum.drain(0..1);
    let last_bracket_offset = sector_id_and_cksum.find(']').unwrap_or(sector_id_and_cksum.len());
    let checksum = sector_id_and_cksum.drain(..last_bracket_offset).collect();

    Room { name: name, sector_id: sector_id, checksum: checksum }
  }

  /// Returns true if the room + checksum line up.
  ///
  /// A room is real (not a decoy) if the checksum is the five most common letters in the encrypted 
  /// name, in order, with ties broken by alphabetization.
  fn is_real(&self) -> bool {
    self.checksum == self.computed_checksum()
  }

  /// Decrypted room name
  ///
  /// To decrypt a room name, rotate each letter forward through the alphabet a number of times 
  /// equal to the room's sector ID.
  fn decrypted_name(&self) -> String {
    fn rotate(c:char, steps:u32) -> char {
      if c == '-' { return ' '; }

      let base_i          = 'a' as u8;
      let char_i          = c as u8;
      let small_steps     = (steps % 26) as u8;
      let rotated_char_i  = (((char_i - base_i) + small_steps) % 26) + base_i;

      rotated_char_i as char
    }

    let rotated_room_name = self.name.chars().map(|c| rotate(c, self.sector_id as u32)).collect();

    rotated_room_name 
  }



  /// Compute the checksum for the room.
  fn computed_checksum(&self) -> String {
    // Get hash
    let cc = self.char_counts();

    // Build vec
    let mut occ:Vec<(char, i32)> = Vec::with_capacity(cc.len());
    for (chr, count) in cc { occ.push((chr, count)); }

    // Sort vec by alpha.
    occ.sort_by(|&(a_chr, _), &(b_chr, _)| a_chr.cmp(&b_chr));

    // Sort vec by count.
    occ.sort_by(|&(_, a_count), &(_, b_count)| b_count.cmp(&a_count));

    let mut chrs:Vec<char> = occ.iter().map(|&(a_chr, _)| a_chr).collect();
    chrs.truncate(5);
    let checksum = chrs.into_iter().collect();

    checksum
  }

  /// Hash of char -> count.
  fn char_counts(&self) -> HashMap<char, i32> {
    let mut cc:HashMap<char, i32> = HashMap::new();

    for c in self.name.chars() {
      if c == '-' { continue; }
      let count = cc.entry(c).or_insert(0);
      *count += 1;
    }

    cc
  }
}

impl fmt::Display for Room {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { 
    write!(
      f,
      "{}\n\tSID {}\n\tCKS {}\n\tACK {}\n\tCK? {}\n", 
      self.name, 
      self.sector_id, 
      self.checksum,
      self.computed_checksum(),
      if self.is_real() { "real" } else { "fake" }
    )
  }
}

fn main() {
  let mut input = String::new();
  let mut stdin = io::stdin();
  if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

  let lines:Vec<&str> = input.trim().split('\n').collect();
  let rooms:Vec<Room> = lines.iter().map(|s| Room::parse(s)).collect();

  {
    let real_rooms:Vec<&Room> = rooms.iter().filter(|room| room.is_real()).collect();
    let pt1:i32 = real_rooms.iter().fold(0, |sum, room| sum + room.sector_id);
    println!("Pt 1: {} ({}/{} real rooms)", pt1, real_rooms.len(), rooms.len());
  }

  // for room in rooms { println!("{} -> {}", room.name, room.decrypted_name()); }
  // This is hacky, but whatever.
  // The magic string is "northpole object storage".

  let ref northpole_room = rooms.iter().find(|room| room.decrypted_name() == "northpole object storage").unwrap();
  println!("Pt 2: {}", northpole_room.sector_id);
}
