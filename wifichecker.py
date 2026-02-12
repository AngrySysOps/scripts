#Piotr Tarnawski
#Angry Admin
# angrysysops.com
import re, subprocess

OUI = {
    "B0:48:7A": "TP-LINK",
    "00:1B:2F": "NETGEAR",
    "F8:32:E4": "ASUS",
    "00:1E:58": "D-LINK",
    "00:1A:1E": "ARRIS",
    "3C:36:E4": "TECHNICOLOR",
}
COMMON_WPS = {"TP-LINK", "NETGEAR", "ASUS", "D-LINK", "ARRIS", "TECHNICOLOR"}

def sh(cmd):
    return subprocess.check_output(cmd, shell=True, universal_newlines=True, stderr=subprocess.DEVNULL)

def gateway_ip():
    out = sh("route -n get default")
    m = re.search(r"gateway:\s*([0-9.]+)", out)
    if not m: raise SystemExit("Could not find default gateway")
    return m.group(1)

def gateway_mac(ip):
    sh(f"ping -c 1 -W 1000 {ip} >/dev/null 2>&1 || true")
    out = sh("arp -n " + ip)
    m = re.search(r"at\s+([0-9a-f:]{17})", out, re.I)
    if not m: raise SystemExit("Could not read gateway MAC (try: sudo python3 wifichecker.py)")
    return m.group(1).lower()

gw = gateway_ip()
mac = gateway_mac(gw)
prefix = ":".join(mac.split(":")[:3]).upper()
vendor = OUI.get(prefix, "UNKNOWN")
risk = "⚠️  WPS LIKELY PRESENT" if vendor in COMMON_WPS else "ℹ️  UNKNOWN (CHECK MANUALLY)"

print("\n=== WPS QUICK AUDIT (safe) ===")
print("Gateway IP :", gw)
print("Gateway MAC:", mac)
print("Vendor     :", "%s (%s)" % (vendor, prefix))
print("Risk       :", risk)
print("\nNext steps: Disable WPS in router settings + update firmware.\n")
