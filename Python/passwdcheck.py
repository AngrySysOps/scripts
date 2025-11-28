#Author Piotr Tarnawski
#angrysysops.com
# X: -> @TheTechWorldPod

import string

password = input("Enter password to test: ")

lenght_ok = len(password) >= 8
has_upper = any(c.isupper() for c in password)
has_digit = any(c.isdigit() for c in password)
has_symbol = any(c in string.punctuation for c in password)

if lenght_ok and has_upper and has_digit and has_symbol:
    print("✅ Strong password!")
elif lenght_ok and (has_upper or has_digit or has_symbol):
    missing = []

    if not has_upper:
        missing.append("an uppercase letter")
    if not has_digit:
        missing.append("a number")
    if not has_symbol:
        missing.append("a special character")

    print("⚠ Almost there! Add: "+", ".join(missing))
else:
    print("X! Week password - use at least 8 chars , with UPPERCASE, number and symbols")
                        
