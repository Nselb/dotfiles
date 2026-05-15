#!/bin/bash
case $1 in
up) brightnessctl set 5%+ ;;
down) brightnessctl set 5%- ;;
esac

MAX=$(brightnessctl max)
CUR=$(brightnessctl get)
PERCENT=$(awk "BEGIN {printf \"%d\", ($CUR/$MAX)*100}")

if [ $PERCENT -lt 33 ]; then
  ICON="󰃞 "
elif [ $PERCENT -lt 66 ]; then
  ICON="󰃟 "
else
  ICON="󰃠 "
fi

notify-send -a "dunst-brightness" \
  -h string:x-dunst-stack-tag:brightness \
  -h int:value:$PERCENT \
  "$ICON Brightness" "$PERCENT%"
