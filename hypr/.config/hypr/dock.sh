#!/bin/zsh

function handle {
	if [[ ${1:0:12} == "monitoradded" ]]; then
		echo $1
		if [[ $1 =~ "DP" ]]; then
			eww open bar-left
		fi
		if [[ $1 =~ "DVI-I-1" ]]; then
			eww open bar-right
		fi
	fi
}

socat - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done