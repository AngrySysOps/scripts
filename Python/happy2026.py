# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin


import os, sys, time, random, shutil

ESC = "\x1b["
GREEN = ESC + "32m"
DIM = ESC + "2m"
RESET = ESC + "0m"
HIDE = ESC + "?25l"
SHOW = ESC + "?25h"

CHARS = "01アイウエオカキクケコサシスセソﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓ<>/\\|{}[]#@$%^&*"

def mv(r, c): return f"{ESC}{r};{c}H"

def main(seconds=12):
    cols, rows = shutil.get_terminal_size((80, 24))
    clear = "cls" if os.name == "nt" else "clear"
    os.system(clear)
    sys.stdout.write(HIDE + GREEN)

    drops = [random.randrange(rows) for _ in range(cols)]
    msg = ["HAPPY NEW YEAR 2026", "from Angry Admin", "please subscribe"]
    mr = rows // 2 - 1

    start = time.time()
    try:
        while time.time() - start < seconds:
            for x in range(1, cols + 1):
                y = drops[x - 1]
                # bright head + dim trail (simple but effective)
                sys.stdout.write(mv(y + 1, x) + random.choice(CHARS))
                sys.stdout.write(DIM + mv((y - 2) % rows + 1, x) + random.choice(CHARS) + RESET + GREEN)
                drops[x - 1] = (y + 1) % rows

            # centered overlay message
            for i, line in enumerate(msg):
                c = max(1, (cols - len(line)) // 2)
                sys.stdout.write(RESET + mv(mr + i + 1, c) + line + GREEN)

            sys.stdout.flush()
            time.sleep(0.03)
    finally:
        sys.stdout.write(RESET + SHOW + "\n")

if __name__ == "__main__":
    main(seconds=12)
