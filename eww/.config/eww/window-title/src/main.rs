use serde_json::Value;
use std::process::Command;
use titlecase::titlecase;

fn main() {
	let window = Command::new("hyprctl")
		.args(["-j", "activewindow"])
		.output()
		.expect("Hyprctl not working")
		.stdout;
	let window = String::from_utf8(window).unwrap();

	let root: Value = serde_json::from_str(&window).unwrap();

	// let window = root.get("class").unwrap().as_str().unwrap();
	let window = if let Some(window) = root.get("class") {
		window.as_str().unwrap()
	} else {
		"null"
	};

	let window = match window {
		"org.wezfurlong.wezterm" => "terminal",
		"Emacs" => "doom emacs",
		"null" => "",
		_ => window,
	};
	let window = titlecase(window);
	println!("{}", window);
}
