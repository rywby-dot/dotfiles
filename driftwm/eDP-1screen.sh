f="$HOME/Pictures/Screenshots/ScreenShot-$(date +'%Y-%m-%d_%H-%M-%S').png" && grim -c -o eDP-1 - | tee "$f" | wl-copy && notify-send "eDP-1 Screenshot" "saved to ~/Pictures/Screenshots/" -i "$f"
