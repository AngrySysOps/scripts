#Author Piotr Tarnawski
#angrysysops.com
# X: -> @TheTechWorldPod

import subprocess
import platform

def ping_host(host):
    os_name = platform.system().lower()
    flag = "-n" if os_name == "windows" else "-c"
    cmd = ["ping", flag, "4", host]

    print(f"\n[+] Pinging {host}...\n")

    try:
        result = subprocess.run(cmd)
    except Exception as e:
        print(f"[!] Ping failed: {e}")
        return

    if result.returncode == 0:
        print(f"\n[OK] {host} is reachable")
    else:
        print(f"\n[!] {host} is NOT reachable")

if __name__ == "__main__":
    target = input("Enter IP or hostname: ").strip()
    if target:
        ping_host(target)
    else:
        print("No target provided.")
