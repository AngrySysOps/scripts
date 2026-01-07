# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin 
# My new TikTok account: https://www.tiktok.com/@angrysysops.com

import random
import string

HANGMAN_PICS = [
    r"""
     +---+
     |   |
         |
         |
         |
         |
    =========""",
    r"""
     +---+
     |   |
     O   |
         |
         |
         |
    =========""",
    r"""
     +---+
     |   |
     O   |
     |   |
         |
         |
    =========""",
    r"""
     +---+
     |   |
     O   |
    /|   |
         |
         |
    =========""",
    r"""
     +---+
     |   |
     O   |
    /|\  |
         |
         |
    =========""",
    r"""
     +---+
     |   |
     O   |
    /|\  |
    /    |
         |
    =========""",
    r"""
     +---+
     |   |
     O   |
    /|\  |
    / \  |
         |
    =========""",
]

WORD_BANK = {
    "Linux": ["kernel", "bash", "systemd", "iptables", "ssh", "cron", "grep", "awk", "sed", "sudo", "package"],
    "Networking": ["latency", "subnet", "gateway", "firewall", "routing", "dns", "dhcp", "ethernet", "backbone"],
    "Cybersecurity": ["phishing", "ransomware", "hashing", "payload", "exploit", "forensics", "malware", "zero-day"],
    "DevOps": ["pipeline", "container", "kubernetes", "terraform", "ansible", "observability", "rollback", "artifact"],
}

DIFFICULTY = {
    "easy": 7,     # max wrong guesses
    "normal": 6,
    "hard": 5,
}

def pick_word():
    category = random.choice(list(WORD_BANK.keys()))
    word = random.choice(WORD_BANK[category]).lower()
    return category, word

def mask_word(word, guessed):
    return " ".join([c if c in guessed else "_" for c in word])

def get_letter(prompt="Guess a letter: "):
    while True:
        guess = input(prompt).strip().lower()
        if len(guess) != 1:
            print("Type a single letter.")
            continue
        if guess not in string.ascii_lowercase:
            print("Letters only (a-z).")
            continue
        return guess

def choose_difficulty():
    while True:
        raw = input("Difficulty (easy/normal/hard): ").strip().lower()
        if raw in DIFFICULTY:
            return raw, DIFFICULTY[raw]
        print("Pick: easy, normal, or hard.")

def reveal_hint(word, guessed):
    remaining = [c for c in set(word) if c not in guessed]
    if not remaining:
        return None
    return random.choice(remaining)

def play_round():
    category, word = pick_word()
    diff_name, max_wrong = choose_difficulty()

    guessed = set()
    wrong = set()
    hints_left = 1

    print("\n--- HANGMAN ---")
    print(f"Category: {category} | Difficulty: {diff_name} | Wrong allowed: {max_wrong}")
    print("Tip: type 'hint' once per game to reveal a letter.\n")

    while True:
        # Display
        stage_index = min(len(HANGMAN_PICS) - 1, len(wrong))
        print(HANGMAN_PICS[stage_index])
        print("\nWord: ", mask_word(word, guessed))
        print(f"Guessed: {', '.join(sorted(guessed)) if guessed else '-'}")
        print(f"Wrong:   {', '.join(sorted(wrong)) if wrong else '-'}")
        print(f"Hints left: {hints_left}")
        print()

        # Win check
        if all(c in guessed for c in word):
            print(f"✅ You got it: {word}")
            return True, word, category, diff_name, len(wrong)

        # Lose check
        if len(wrong) >= max_wrong:
            final_pic = HANGMAN_PICS[-1]
            print(final_pic)
            print(f"❌ Game over. The word was: {word}")
            return False, word, category, diff_name, len(wrong)

        # Input
        raw = input("Your guess (letter or 'hint'): ").strip().lower()
        if raw == "hint":
            if hints_left <= 0:
                print("No hints left.\n")
                continue
            letter = reveal_hint(word, guessed)
            if letter is None:
                print("Nothing left to reveal.\n")
                continue
            guessed.add(letter)
            hints_left -= 1
            print(f"Hint revealed: '{letter}'\n")
            continue

        if len(raw) != 1 or raw not in string.ascii_lowercase:
            print("Invalid input. Type one letter (a-z) or 'hint'.\n")
            continue

        guess = raw
        if guess in guessed or guess in wrong:
            print("Already tried that.\n")
            continue

        if guess in word:
            guessed.add(guess)
            print("Nice!\n")
        else:
            wrong.add(guess)
            print("Nope.\n")

def main():
    wins = 0
    losses = 0

    print("Hangman (Angry Admin Edition)")

    while True:
        won, word, category, diff, wrong_count = play_round()
        if won:
            wins += 1
        else:
            losses += 1

        print(f"\nScore: {wins} win(s), {losses} loss(es)\n")
        again = input("Play again? (y/n): ").strip().lower()
        if again != "y":
            print("Bye.")
            break

if __name__ == "__main__":
    main()
