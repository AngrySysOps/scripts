# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin 
# My new TikTok account: https://www.tiktok.com/@angrysysops.com

import tkinter as tk
from tkinter import ttk
import secrets
import string

LENGTH = 16
ALPHABET = string.ascii_letters + string.digits + "!@#$%^&*()-_=+[]{};:,.?/"

def generate():
    pwd.set("".join(secrets.choice(ALPHABET) for _ in range(LENGTH)))

def copy():
    root.clipboard_clear()
    root.clipboard_append(pwd.get())
    root.update()  # ensures clipboard persists after closing

root = tk.Tk()
root.title("Secure Password Generator")
root.resizable(False, False)
root.geometry("460x160")

pwd = tk.StringVar()

ttk.Label(root, text="Generate a secure password (local only):").pack(pady=(14, 6))

entry = ttk.Entry(root, textvariable=pwd, font=("Arial", 18), justify="center", width=32)
entry.pack(pady=6)

btns = ttk.Frame(root)
btns.pack(pady=10)

ttk.Button(btns, text="New Password", command=generate).pack(side="left", padx=6)
ttk.Button(btns, text="Copy", command=copy).pack(side="left", padx=6)

generate()
root.mainloop()
