# Author Angry Admin - Piotr Tarnawski
# X: @TheTechWorldPod


from cryptography.fernet import Fernet
# pip install cryptography

def demo_cipher():
    # Ask the user for some text to protect
    message = input("Type a secret message: ")
    print(f"\n[+] Original message: {message}")

    # Step 1: generate a random key (symmetric key)
    key = Fernet.generate_key()
    print(f"[+] Generated key: {key!r}")

    # Step 2: create a cipher object using that key
    cipher = Fernet(key)

    # Step 3: encrypt the message (encode string -> bytes first)
    encrypted = cipher.encrypt(message.encode("utf-8"))
    print(f"[+] Encrypted token:\n{encrypted!r}\n")

    # Step 4: decrypt back to plaintext (bytes -> string)
    decrypted = cipher.decrypt(encrypted).decode("utf-8")
    print(f"[+] Decrypted message: {decrypted}")

if __name__ == "__main__":
    demo_cipher()
