// An interface between eww and i3
// This makes it so when I switch to left, I can just rewrite this and keep everything else the
// same
// (literal :content "${workspace0text}")
extern crate clap;
use std::process::Command;

use clap::{App, Arg, SubCommand};

static MONITOR_MAP: [&str; 3] = ["DP-2", "DVI-I-0", "HDMI-0"];

fn main() {
	let matches = App::new("i3 Interface Program")
		.version("1.0")
		.author("Justin Frank")
		.about("Interfaces between eww and i3-msg")
		.subcommand(
			SubCommand::with_name("get")
				.about("Gets workspaces by monitor name")
				.arg(
					Arg::with_name("Monitor")
						.short("m")
						.long("monitor")
						.help("Select monitor to get workspaces")
						.value_name("MONITOR")
						.required(true)
						.takes_value(true),
				)
				.arg(
					Arg::with_name("Verbose")
						.short("v")
						.long("verbose")
						.help("Print output"),
				),
		)
		.subcommand(
			SubCommand::with_name("yuck")
				.about("Gets the yuck for a monitor")
				.arg(
					Arg::with_name("Monitor")
						.short("m")
						.long("Monitor")
						.help("Select monitor to get yuck")
						.required(true)
						.value_name("MONITOR")
						.takes_value(true),
				),
		)
		.subcommand(
			SubCommand::with_name("set")
				.about("sets the active workspace")
				.arg(
					Arg::with_name("Workspace")
						.short("w")
						.long("workspace")
						.help("Switch to a specific workspace")
						.value_name("WORKSPACE")
						.required(true)
						.takes_value(true),
				),
		)
		.subcommand(
			SubCommand::with_name("update")
				.about("Update the workspace of a monitor")
				.arg(
					Arg::with_name("Monitor")
						.short("m")
						.long("monitor")
						.help("Update the workspace of a monitor")
						.value_name("MONITOR")
						.required(true)
						.takes_value(true),
				),
		)
		.get_matches();
	if let Some(matches) = matches.subcommand_matches("get") {
		get_workspaces(
			matches
				.value_of("Monitor")
				.unwrap_or("0")
				.parse()
				.unwrap_or(0),
			matches.is_present("Verbose"),
		);
	}
	if let Some(matches) = matches.subcommand_matches("yuck") {
		get_yuck(
			matches
				.value_of("Monitor")
				.unwrap_or("0")
				.parse()
				.unwrap_or(0),
		);
	}
	if let Some(matches) = matches.subcommand_matches("set") {
		set_workspace(matches.value_of("Workspace").unwrap_or("1"));
	}
	if let Some(matches) = matches.subcommand_matches("update") {
		update(
			matches
				.value_of("Monitor")
				.unwrap_or("0")
				.parse()
				.unwrap_or(0),
		);
	}
}

fn get_workspaces(monitor: usize, verbose: bool) -> Vec<String> {
	// i3-msg -t get_workspaces
	let output = Command::new("i3-msg")
		.args(["-t", "get_workspaces"])
		.output()
		.expect("Failed to execute program")
		.stdout
		.iter()
		.map(|num| *num as char)
		.collect::<String>();
	let mut final_list: Vec<String> = vec![];
	json::parse(output.as_str())
		.expect("unable to parse")
		.members_mut()
		.filter(|item| item["output"] == MONITOR_MAP[monitor])
		.for_each(|item| {
			if item["visible"] == true {
				final_list.insert(0, item["num"].take().to_string());
			} else {
				final_list.push(item["num"].take().to_string());
			}
		});
	if verbose {
		let final_str = final_list.join(" ");
		println!("{}", final_str);
	}
	final_list
}

fn get_yuck(monitor: usize) -> String {
	// Gets yuck for the Monitor
	fn get_button(workspace: String) -> String {
		format!(
			r#"
			(button
			:tooltip "{workspace}"
			:onclick "./interface set -w {workspace}"
			"{workspace}")
			"#
		)
	}

	let mut workspaces = get_workspaces(monitor, false);
	let first = get_button(workspaces.remove(0));
	let buttons = workspaces
		.iter()
		.map(|workspace| get_button(workspace.to_owned()))
		.collect::<String>();
	// (literal :content workspace0text)
	let string = format!(
		r#"
	(eventbox
	:onhover "eww update show-workspace{monitor}=true"
	:onhoverlost "eww update show-workspace{monitor}=false"
	(box
	:orientation "h"
	:space-evenly "false"
	:vexpand "false"
	{first}
	(revealer
	:transition "slideright"
	:reveal show-workspace{monitor}
	:duration "550ms"
	(box
	:orientation "h"
	:space-evenly false
	{buttons}))))"#
	);
	println!("{string}");
	string
}

fn set_workspace(workspace: &str) {
	Command::new("i3-msg")
		.args(["workspace", workspace])
		.output()
		.expect("Failed to execute program");
	// update(0);
}

//update
fn update(monitor: usize) {
	let yuck = get_yuck(monitor);
	let out = Command::new("eww")
		.args(["update", format!("workspace{monitor}text={yuck}").as_str()])
		.output()
		.expect("Failed to execute program")
		.stderr
		.iter()
		.map(|num| *num as char)
		.collect::<String>();
	println!("{out}");
}
