#!/bin/bash
case $1 in
up) wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
MUTED=$(echo $VOL | grep -c MUTED)
PERCENT=$(echo $VOL | grep -oP '\d+\.\d+' | awk '{printf "%d", $1*100}')

if [ $MUTED -eq 1 ]; then
  ICON="󰝟"
  MSG="Muted"
elif [ $PERCENT -lt 33 ]; then
  ICON="󰕿"
elif [ $PERCENT -lt 66 ]; then
  ICON="󰖀"
else
  ICON="󰕾"
fi

notify-send -a "dunst-volume" \
  -h string:x-dunst-stack-tag:volume \
  -h int:value:$PERCENT \
  "$ICON Volume" "$PERCENT%"
