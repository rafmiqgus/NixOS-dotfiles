#!/usr/bin/env bash
A_1080=400
B_1080=400

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect monitor resolution and scaling factor
resolution=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .height / .scale' | awk -F'.' '{print $1}')
hypr_scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale')
# wlogout --protocol layer-shell -b 5 -T $(awk "BEGIN {printf \"%.0f\", $A_1080 * 1080 * $hypr_scale / $resolution}") -B $(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $hypr_scale / $resolution}") &

wlogout \
  --protocol layer-shell \
  -b 5 \
  -T "$(awk -v a="$A_1080" -v r="$resolution" 'BEGIN{printf "%.0f", a * r / 1080}')" \
  -B "$(awk -v b="$B_1080" -v r="$resolution" 'BEGIN{printf "%.0f", b * r / 1080}')" &

