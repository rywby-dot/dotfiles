f="$HOME/Pictures/Screenshots/ScreenShot-$(date +'%Y-%m-%d_%H-%M-%S').png" && grim -g "$(slurp -o)" - | tee "$f" | wl-copy && notify-send "Output Screenshot" "saved to ~/Pictures/Screenshots" -i "$f"
