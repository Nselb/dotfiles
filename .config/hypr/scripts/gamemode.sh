#!/bin/bash

STATE_FILE="/tmp/gamemode_state"

if [ -f "$STATE_FILE" ]; then
  # Game mode ON -> apagar
  rm "$STATE_FILE"

  waybar &
  dunst &
  powerprofilesctl set balanced
  echo auto | sudo tee /sys/class/drm/card1/device/power_dpm_force_performance_level
  hyprctl keyword decoration:blur:enabled true
  hyprctl keyword decoration:shadow:enabled true
  hyprctl keyword animations:enabled true
  hyprctl reload

  notify-send "🖥️ Game Mode OFF" "Servicios restaurados"
else
  # Game mode OFF -> encender
  touch "$STATE_FILE"

  notify-send "🎮 Game Mode ON" "Servicios detenidos, performance máximo"

  pkill waybar
  pkill dunst
  powerprofilesctl set performance
  echo high | sudo tee /sys/class/drm/card1/device/power_dpm_force_performance_level
  hyprctl keyword decoration:blur:enabled false
  hyprctl keyword decoration:shadow:enabled false
  hyprctl keyword animations:enabled false
  hyprctl reload
fi
