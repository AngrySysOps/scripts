# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin

import time

ZW0 = "\u200b"   # bit 0 (zero width space)
ZW1 = "\u200c"   # bit 1 (zero width non-joiner)
END = "\u2060"   # end marker (word joiner)

BITS_PER_WORD = 8  # pack 8 bits per word (1 byte per word)

def to_bits(s: str) -> str:
    return "".join(f"{b:08b}" for b in s.encode("utf-8"))

def from_bits(bits: str) -> str:
    data = bytes(int(bits[i:i+8], 2) for i in range(0, len(bits), 8))
    return data.decode("utf-8", errors="replace")

def chunk(s: str, n: int):
    return [s[i:i+n] for i in range(0, len(s), n)]

def hide(secret: str, cover: str) -> str:
    bits = to_bits(secret) + "00000000"  # padding for clean byte trimming
    words = cover.split()
    needed = (len(bits) + BITS_PER_WORD - 1) // BITS_PER_WORD
    if len(words) < needed:
        raise ValueError(f"Cover needs at least {needed} words (has {len(words)}).")

    out = []
    bit_chunks = chunk(bits, BITS_PER_WORD)
    for i, w in enumerate(words):
        if i < len(bit_chunks):
            zw = "".join(ZW1 if b == "1" else ZW0 for b in bit_chunks[i])
            out.append(w + zw)
        else:
            out.append(w)
    return " ".join(out) + END

def reveal(stego: str) -> str:
    zw = "".join(ch for ch in stego if ch in (ZW0, ZW1, END))
    if END not in zw:
        return "[no hidden message]"
    payload = zw.split(END)[0]
    bits = "".join("1" if ch == ZW1 else "0" for ch in payload)
    bits = bits[:len(bits) - (len(bits) % 8)]  # full bytes only
    return from_bits(bits).rstrip("\x00")

def hacker_view(text: str) -> str:
    return text.replace(ZW0, "·").replace(ZW1, "¦").replace(END, "⟂")

if __name__ == "__main__":
    cover = ("Nothing to see here. Just a normal status update. "
             "Coffee is strong today and logs are quiet for once.")
    secret = input("Secret to hide: ").strip()

    print("\nInjecting payload", end="", flush=True)
    for _ in range(6):
        time.sleep(0.2); print(".", end="", flush=True)
    print(" done.\n")

    stego = hide(secret, cover)
    print("Stego text (looks normal):\n", stego)

    # Clean visual for video: show only the last 120 chars in hacker view
    hv = hacker_view(stego)
    print("\nHacker view (tail):\n", hv[-120:])

    print("\nRecovered:\n", reveal(stego))
