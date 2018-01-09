extern crate bit_vec;
use bit_vec::BitVec;

const WIDTH: usize = 128;

pub struct GroupBuilder {
    pub groups: Vec<[Option<u16>; 128]>
}

impl GroupBuilder {
    pub fn new(bits: &Vec<BitVec>) -> GroupBuilder {
        let groups = GroupBuilder::build(&bits);

        // All rows are "grouped", but we need to consider column "neighbors"
        let mut gb = GroupBuilder { groups: groups };

        for row_i in 1..WIDTH {
            for col_i in 0..WIDTH {
                if let (&Some(cell), &Some(up_cell)) = (gb.get_cell(row_i, col_i), gb.get_cell(row_i - 1, col_i)) {
                    if cell != up_cell {
                        gb.substitute(cell, up_cell);
                    }
                }
            }
        }

        gb
    }

    fn build(bits: &Vec<BitVec>) -> Vec<[Option<u16>; 128]> {
        let mut groups = vec![];
        let mut max_group_id = 0;

        for bv in bits.iter() {
            let mut group_row = [None; 128];
            let mut current_row_group: Option<u16> = None;

            for (col_i, b) in bv.iter().enumerate() {
                current_row_group = if b {
                    let group_id = match current_row_group {
                        Some(cr) => cr,
                        None     => {
                            max_group_id += 1;
                            max_group_id
                        }
                    };

                    Some(group_id)
                } else {
                    None
                };

                group_row[col_i] = current_row_group;
            }

            groups.push(group_row);
        }

        groups
    }

    /// substitute r for all instances of s
    fn substitute(&mut self, s: u16, r: u16) {
        for row in self.groups.iter_mut() {
            for og in row.iter_mut() {
                if let &mut Some(g) = og {
                    if g == s {
                        *og = Some(r);
                    }
                }
            }
        }
    }

    /// get cell at (x,y)
    fn get_cell(&self, row_i: usize, col_i: usize) -> &Option<u16> {
        let row = self.groups.get(row_i).unwrap();
        row.get(col_i).unwrap()
    }
}

