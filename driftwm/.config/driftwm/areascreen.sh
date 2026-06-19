f="$HOME/Pictures/Screenshots/ScreenShot-$(date +'%Y-%m-%d_%H-%M-%S').png" && grim -g "$(slurp)" - | tee "$f" | wl-copy && notify-send "Area Screenshot" "saved to ~/Pictures/Screenshots" -i "$f"
