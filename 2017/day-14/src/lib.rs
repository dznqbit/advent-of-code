pub fn knot_hash(s: &str) -> String {
    let mut ascii: Vec<usize> = s.chars().map(|c| c as usize).collect();
    let mut standard_suffix = vec![17, 31, 73, 47, 23];
    ascii.append(&mut standard_suffix);

    let mut list = List::new_with_capacity(256);

    // Twist 64 times
    for _ in 0..64 {
        list.twist_by_lengths(&ascii);
    }

    list.dense_hash()
}

struct List {
    marks: Vec<u32>,
    index: usize,
    skip_size: usize
}

impl List {
    pub fn new_with_capacity(c: usize) -> List {
        let mut marks = Vec::with_capacity(c);

        for i in 0..c { 
            marks.push(i as u32); 
        }

        List {
            marks: marks,
            index: 0,
            skip_size: 0
        }
    }

    fn circular_index(&self, i: usize) -> usize {
        i % self.marks.len()
    }

    pub fn len(&self) -> usize {
        self.marks.len()
    }

    pub fn twist(&mut self, length: usize) {
        if length > self.len() { panic!("Can't twist longer than list length!"); }

        let sublist_begin = self.index; 
        let sublist_end = self.index + length - 1;

        // Reverse the order of that length of elements in the list, starting with the element at the current position.
        for i in 0..(length / 2) {
            let a_index = self.circular_index(sublist_begin + i);
            let b_index = self.circular_index(sublist_end - i);

            let old_a_value = { *self.marks.get(a_index).unwrap() };
            let old_b_value = { *self.marks.get(b_index).unwrap() };

            {
                let mut a = self.marks.get_mut(a_index).unwrap();
                *a = old_b_value;
            }

            {
                let mut b = self.marks.get_mut(b_index).unwrap();
                *b = old_a_value;
            }
        }

        // Move the current position forward by that length plus the skip size.
        self.index += length + self.skip_size;

        // Increase the skip size by one.
        self.skip_size += 1;
    }

    pub fn twist_by_lengths(&mut self, lengths: &Vec<usize>) {
        for i in lengths {
            self.twist(*i);
        }
    }

    pub fn dense_hash(&self) -> String {
        let chunks_xor: Vec<u32> = self.marks.chunks(16)
            .map(|chunk| { chunk.iter().fold(0, |acc, c| acc ^ c) })
            .collect()
        ;

        let hexed_chunks: Vec<String> = chunks_xor.iter().map(|n| format!("{:02x}", n)).collect();
        hexed_chunks.join("")
    }
}
