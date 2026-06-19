import evdev
import subprocess
import os

# --- Настройки ---
LAYOUTS = ["EN", "RU"]  # Ваши раскладки
current_layout_index = 0
STATE_FILE = "/tmp/kb_layout"
WAYBAR_SIGNAL = 10      # Должен совпадать с "signal" в конфиге Waybar

def update_waybar():
    # Записываем текущую раскладку в файл
    with open(STATE_FILE, "w") as f:
        f.write(LAYOUTS[current_layout_index])
    # Посылаем сигнал Waybar (SIGRTMIN+10) для мгновенного обновления модуля
    subprocess.run(["pkill", "-RTMIN+" + str(WAYBAR_SIGNAL), "waybar"])

# Инициализируем файл при запуске
update_waybar()

# Ищем клавиатуру среди устройств ввода
devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
keyboard = None
for dev in devices:
    # Ищем устройство, в названии которого есть слово "keyboard"
    if "keyboard" in dev.name.lower():
        keyboard = dev
        break

if not keyboard:
    print("Клавиатура не найдена. Проверьте права доступа к /dev/input/")
    exit(1)

alt_pressed = False
shift_pressed = False

# Бесконечный цикл чтения событий (забирает ~0% CPU)
for event in keyboard.read_loop():
    if event.type == evdev.ecodes.EV_KEY:
        key_event = evdev.categorize(event)
        
        # Обработка случаев, когда одна клавиша имеет несколько алиасов
        keycode = key_event.keycode
        if isinstance(keycode, list):
            keycode = keycode[0]

        # Отслеживаем зажатие/отпускание Alt и Shift
        if keycode in ['KEY_LEFTALT', 'KEY_RIGHTALT']:
            alt_pressed = (key_event.keystate != 0)
        elif keycode in ['KEY_LEFTSHIFT', 'KEY_RIGHTSHIFT']:
            shift_pressed = (key_event.keystate != 0)

        # Если обе клавиши нажаты (keystate == 1 означает момент нажатия)
        if alt_pressed and shift_pressed and key_event.keystate == 1:
            current_layout_index = (current_layout_index + 1) % len(LAYOUTS)
            update_waybar()
