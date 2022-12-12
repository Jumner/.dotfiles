use std::{collections::HashSet, fs};

fn main() {
	let urls = fs::read_to_string("unsplash.txt").unwrap();
	let mut initial_size = 0;

	let mut set = HashSet::new();
	for line in urls.lines() {
		initial_size += 1;
		let line = line.split('?').next().unwrap(); // Get first one
		if !line.is_empty() {
			set.insert(line);
		}
	}

	// Reconstruction

	let final_size = set.len();
	let mut urls = String::new();
	for item in set {
		urls.push_str(item);
		urls.push('\n');
	}

	fs::write("unsplash.txt", urls).unwrap();
	println!(
		"List Purged {} of {} items",
		initial_size - final_size,
		initial_size
	);
}
