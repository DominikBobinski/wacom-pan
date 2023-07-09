#!/bin/bash

# This script sets button 2 (on the sylus) to "pan" mode and adjusts the threshold
# to a reddit-recommended value. This makes it possible to scroll in some applications
# (most notably firefox) by holding that button and dragging the stylus on the tablet surface.
# Setting the button to "pan" gives "" when listing button values.
# This script cycles betwwen the default button setting and "" (hopefully only "pan").

exec 3>&1 &>/dev/null # directs outputs to /dev/null, ">&3" is used to unmute a command

wacom_stylus_id=$(xsetwacom list | grep "STYLUS" | grep -oP 'id: \K\d+')

# This assumes that the values read are constructed as "button +X",
# where X is a set of characters.
button_2_mode=$(xsetwacom -s get $wacom_stylus_id Button 2 | grep -o "button[^\"]*")
# gets PanScrollThreshold, 100 = 0.1mm
threshold=$(xsetwacom get $wacom_stylus_id PanScrollThreshold)

settings_memory="$XDG_RUNTIME_DIR/wacom_pan_memory"
# The variables are named "default" instead of previous because we don't want to
# save the "pan" setting to file, we want to preserve the value before setting to "pan".
default_button=$(head -n 1 "$settings_memory")
default_threshold=$(tail -n 1 "$settings_memory")

if [[ ! "$button_2_mode" = "" ]] || [[ ! "$button_2_mode = $default_button" ]]; then
    echo "$button_2_mode" > "$settings_memory"
    echo "$threshold" >> "$settings_memory"
fi

if [[ $button_2_mode = "" ]]; then
    # non-default value, for exmaple "pan" is set, resetting to default
    xsetwacom set $wacom_stylus_id Button 2 $default_button
    xsetwacom set $wacom_stylus_id PanScrollThreshold $default_threshold
    echo "Button 2 is set to default." >&3
else
    # some default value present, setting button to pan
    threshold=200
    xsetwacom set $wacom_stylus_id Button 2 pan
    xsetwacom set $wacom_stylus_id PanScrollThreshold $threshold
    echo "Button 2 is set to pan." >&3
fi
