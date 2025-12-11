# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod

import qrcode
import os

# --- Output folder ---
SAVE_PATH = r"C:\temp"   # raw string so backslashes work

def create_qr(data: str, filename: str) -> None:
    """Generate a basic QR code and save it into C:\temp."""
    full_path = os.path.join(SAVE_PATH, filename)
    img = qrcode.make(data)
    img.save(full_path)
    print(f"Saved QR code to: {full_path}")

# --- HackMeNow QR ---
create_qr(
    "https://playhackmenow.com",
    "qr_hackmenow.png"
)

# --- Angry Admin YouTube Subscribe (+1) QR ---
create_qr(
    "https://www.youtube.com/channel/UCRTcKGl0neismSRpDMK_M4A?sub_confirmation=1",
    "qr_angryadmin_subscribe.png"
)

# --- ByuMeaCoffee QR ---
create_qr(
    "https://buymeacoffee.com/angrysysops",
    "qr_buycoffee.png"
)
