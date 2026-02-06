#Author Piotr Tarnawski
#angrysysops.com
# X: -> @TheTechWorldPod

import hashlib, requests

pw = input("Check password: ")
h  = hashlib.sha1(pw.encode()).hexdigest().upper()

p5, rest = h[:5], h[5:]
txt = requests.get(f"https://api.pwnedpasswords.com/range/{p5}", timeout=8).text

if rest in txt:
    print("PWNED")
else:
    print("Not found")
