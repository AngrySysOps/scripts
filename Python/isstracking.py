# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin 
# My new TikTok account: https://www.tiktok.com/@angrysysops.com


import requests
import plotly.graph_objects as go

iss = requests.get("https://api.wheretheiss.at/v1/satellites/25544").json()

fig = go.Figure(go.Scattergeo(
    lat=[iss["latitude"]],
    lon=[iss["longitude"]],
    mode="markers",
))

fig.update_layout(title="ISS Live Position")
fig.show()
