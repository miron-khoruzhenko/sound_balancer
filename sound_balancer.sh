#!/bin/bash
 
# if [ $# -gt 1 ]; then echo "Error: Only one argument is allowed." exit 1 fi

if [ "$#" -ne 1 ];then
	echo "Error: Only one argument is allowed."
	# завершение программы
	exit 1
fi

sink_id="alsa_output.pci-0000_00_1b.0.analog-stereo"
desired_difference=830
my_operator=""

if [ "$1" = "--sound-up" ]; then
	my_operator="+"
elif [ "$1" = "--sound-down" ]; then
	my_operator="-"
else
	echo "Error: Only --sound-up or --sound-down arguments are allowed."
fi


# 65536 - Громкость в единицах при ста процентах
let "one_percent=65536/100"

current_right_volume=$(pactl get-sink-volume $sink_id | awk '{print $10}' | sed 's/%//g')


let "right_volume=$current_right_volume $my_operator one_percent*5"
let "left_volume=right_volume*desired_difference/1000"

pactl set-sink-volume $sink_id {${left_volume},${right_volume}}

