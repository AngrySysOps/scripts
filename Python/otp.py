# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin 
# My new TikTok account: https://www.tiktok.com/@angrysysops.com

import random
import time

def main():
    otp_code = random.randint(100000, 999999)
    ttl_seconds = 10

    print(f"[DEBUG] OTP generated: {otp_code}")

    start = time.monotonic()
    user_input = input(f"Enter OTP within {ttl_seconds} seconds: ")
    elapsed = time.monotonic() - start

    if elapsed > ttl_seconds:
        print("❌ OTP expired")
        return

    if user_input.isdigit() and int(user_input) == otp_code:
        print("✅ OTP verified successfully")
    else:
        print("❌ Invalid OTP")

if __name__ == "__main__":
    main()
