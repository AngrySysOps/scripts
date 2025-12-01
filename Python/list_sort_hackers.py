#Author Piotr Tarnawski
#angrysysops.com
# X: -> @TheTechWorldPod

# Demo: sorting hacking tools and hacker crew in Python

tools = ["nmap", "hydra", "burpsuite", "wireshark"]

hackers = [
    {"name": "Ghost",   "role": "Red Team"},
    {"name": "Oracle",  "role": "Blue Team"},
    {"name": "ZeroDay", "role": "Pentester"},
]
# 1. Basic sort - alphabeticaly by default:

tools.sort()
print("Tools A-Z:", tools )

# 2) Sort tools by length of the tool name
tools.sort(key=len)
print("Tools by length:", tools)

def by_role(hacker):
    return hacker["role"]

# 3) Sort hackers by role using a named function
hackers.sort(key=by_role)
print("Hackers by role:", hackers)

# 4) Same idea, shorter, using a lambda to sort by name
hackers.sort(key=lambda h: h["name"])
print("Hackers by name:", hackers)
