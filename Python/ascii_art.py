# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod

import pywhatkit as kit

# Input image (keep it in the same directory)
img = "channel_image.png"

# Output ASCII file prefix
ascii_out = f"ascii_{img}"

print("Converting image to ASCII art...")

kit.image_to_ascii_art(img, ascii_out)

print("Done. Check the output text file.")
