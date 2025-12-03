# Piotr Tarnawski aka Angry Admin
# angrysysops.com 
# X -> @TheTechWorldPod

following = {"Mom", "Dad", "Boss", "Crush", "Elon"}
followers = {"Mom", "Dad", "SpamBot", "Boss"}

# People I follow that don’t follow me back
ghosts = following - followers

# People where we both follow each other
mutuals = following & followers

# Everyone in my tiny social bubble
network = following | followers

# People who follow me but I don't follow back
lurkers = followers - following

print(f"ghosts   = {ghosts}")
print(f"mutuals  = {mutuals}")
print(f"lurkers  = {lurkers}")
print(f"network  = {network}")
