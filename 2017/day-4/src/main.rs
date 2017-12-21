// http://adventofcode.com/2017/day/4

#![feature(entry_and_modify)]
use std::collections::HashMap;
use std::collections::HashSet;

use std::io::{self, Read};

fn count_valid_phrases<F>(phrases: &Vec<&str>, filter: &F) -> u32
where F: Fn(&str) -> bool {
    let valid_phrases:Vec<&&str> = phrases
        .iter()
        .filter(|p| filter(p))
        .collect()
        ;

    valid_phrases.len() as u32
}

// return true if phrase contains no repeated words
fn part1_is_valid(phrase:&str) -> bool { 
    if phrase.is_empty() {
        return false;
    }

    // Split on spaces
    let mut words:Vec<&str> = phrase
        .split(" ")
        .collect()
        ;

    let og_word_count = words.len();

    words.sort();
    words.dedup();

    let unique_words = words;
    let unique_word_count = unique_words.len();

    og_word_count == unique_word_count
}

// return Hash of char -> occurrences
fn char_count(word:&str) -> HashMap<char, u32> {
    let mut cc:HashMap<char, u32> = HashMap::new();

    for c in word.chars() {
        cc.entry(c)
            .and_modify(|e| *e += 1)
            .or_insert(0)
            ;
    }

    cc
}

// return true if a and b are anagrams
fn anagrams(a:&str, b:&str) -> bool {
    char_count(a) == char_count(b)
}

// return true if phrase contains no repeated words (with anagrams)
fn part2_is_valid(phrase:&str) -> bool {
    if phrase.is_empty() {
        return false;
    }

    let mut words:HashSet<&str> = HashSet::new();

    for word in phrase.split(" ") {
        for existing_word in words.iter() {
            let anagrams_detected = anagrams(word, existing_word);

            if anagrams_detected {
                return false;
            }
        }

        words.insert(word);
    }

    true
}

fn main() {
    let mut input = String::new();
    let mut stdin = io::stdin();
    if let Err(why) = stdin.read_to_string(&mut input) { panic!("Could not read STDIN: {}", why); }

    let lines:Vec<&str> = input.trim().split('\n').collect();

    let part1_solution = count_valid_phrases(&lines, &part1_is_valid);
    println!("Pt 1: {}", part1_solution);

    let part2_solution = count_valid_phrases(&lines, &part2_is_valid);
    println!("Pt 2: {}", part2_solution);
}

