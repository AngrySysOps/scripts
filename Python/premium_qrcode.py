# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod

import qrcode
from PIL import Image, ImageDraw, ImageFont

URL = "https://youtube.com/@AngryAdmin"
LOGO = "logo.png"
OUT  = "angryadmin_qr.png"

# 1) QR with high error correction (needed for logo)
qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=12, border=3)
qr.add_data(URL); qr.make(fit=True)
qr_img = qr.make_image(fill_color="black", back_color="white").convert("RGBA")

# 2) Put logo in the middle (keep it ~20% width)
logo = Image.open(LOGO).convert("RGBA")
w = qr_img.size[0]; s = int(w * 0.20)
logo = logo.resize((s, s))
patch = Image.new("RGBA", (s+16, s+16), (255, 255, 255, 235))
qr_img.alpha_composite(patch, ((w-patch.size[0])//2, (w-patch.size[1])//2))
qr_img.alpha_composite(logo, ((w-s)//2, (w-s)//2))

# 3) Premium card (1080x1080) + simple text
card = Image.new("RGB", (1080, 1080), (12, 16, 26))
d = ImageDraw.Draw(card)
try:
    f1 = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 80)
    f2 = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 32)
except:
    f1 = f2 = ImageFont.load_default()

d.text((70, 70), "AngryAdmin", font=f1, fill=(255, 255, 255))
d.text((70, 170), "Scan to subscribe", font=f2, fill=(160, 220, 255))
d.text((70, 1000), "youtube.com/@AngryAdmin", font=f2, fill=(160, 220, 255))

qr_img = qr_img.resize((640, 640))
card.paste(qr_img.convert("RGB"), (1080-640-70, 250))
card.save(OUT, quality=95)
print("Saved:", OUT)
