// http://adventofcode.com/2017/day/9

use std::io::{self, Read};
use std::str::Chars;
use std::iter::Enumerate;

enum Tag {
    Garbage,
    Group
}

enum Token {
    GarbageOpen,
    GarbageClose,
    GarbageCancelNext,

    GroupOpen,
    GroupClose,

    Character(char)
}

impl Token {
    pub fn parse(c: char) -> Token {
        match c {
            '<' => Token::GarbageOpen,
            '>' => Token::GarbageClose,
            '!' => Token::GarbageCancelNext,
            '{' => Token::GroupOpen,
            '}' => Token::GroupClose,
            _   => Token::Character(c)
        }
    }
}

struct Group {
    // Child groups of this Group
    groups: Vec<Group>,

    index_begin: usize,
    index_end: usize,

    // What type is this?
    tag: Tag,

    // If garbage, number of non-skipped garbage chars
    garbage_chars: u32

    // This tag / garbage_chars business is pretty sloppy, I realize...
}

impl Group {
    pub fn parse(s: &str) -> Group {
        let mut chars = s.chars().enumerate();
        chars.next();
        Group::parse_group(0, &mut chars)
    }

    fn parse_group(index_begin: usize, mut chars: &mut Enumerate<Chars>) -> Group {
        let mut o_group:Option<Group> = None;
        let mut groups:Vec<Group> = vec![];

        while let Some((i, oc)) = chars.next() {
            let ot = Token::parse(oc);

            match ot {
                Token::GarbageOpen  => { &groups.push(Group::parse_garbage(i, &mut chars)); },
                Token::GroupOpen    => { &groups.push(Group::parse_group(i, &mut chars));   },
                Token::GroupClose   => {
                    let g = Group {
                        groups: groups,
                        index_begin: index_begin,
                        index_end: i,
                        tag: Tag::Group,
                        garbage_chars: 0
                    };

                    o_group = Some(g);
                    break;
                },

                _ => {} 
            }
        }

        o_group.unwrap()
    }

    fn parse_garbage(index_begin: usize, chars: &mut Enumerate<Chars>) -> Group {
        let mut o_group:Option<Group> = None;
        let mut garbage_chars = 0;

        while let Some((i, oc)) = chars.next() {
            let ot = Token::parse(oc);

            match ot {
                Token::GarbageClose => {
                    o_group = Some(Group::new_garbage(index_begin, i, garbage_chars));
                    break;
                },

                Token::GarbageCancelNext => {
                    chars.next();
                },

                _ => { garbage_chars += 1; }
            }
        }

        o_group.unwrap()
    }

    fn new_garbage(index_begin: usize, index_end: usize, garbage_chars: u32) -> Group {
        Group {
            tag: Tag::Garbage,
            index_begin: index_begin,
            index_end: index_end,
            groups: vec![],
            garbage_chars: garbage_chars
        }
    }

    // Instance
    
    fn total_score(&self, depth: u32) -> u32 {
        let my_score = match self.tag {
            Tag::Group  => depth,
            _           => 0
        };

        self.groups.iter().fold(
            my_score,
            |acc, g| acc + g.total_score(depth + 1)
        )
    }

    fn total_garbage_chars(&self) -> u32 {
        match self.tag {
            Tag::Group => self.groups.iter() 
                            .fold(0, |acc, g: &Group| acc + g.total_garbage_chars()),
            Tag::Garbage => self.garbage_chars
        }

    }
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let input = input.trim();
    let group = Group::parse(input);

    let part1_solution = group.total_score(1);
    let part2_solution = group.total_garbage_chars();

    println!("Pt 1: {}", part1_solution);
    println!("Pt 2: {}", part2_solution);
}
