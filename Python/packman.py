# Author Piotr Tarnawski
# Angry Admin
# angrysysops.com
# X: @TheTechWorldPod
# Please subscribe to my youtube channel: @AngryAdmin 
# My new TikTok account: https://www.tiktok.com/@angrysysops.com

import pygame, sys, random
pygame.init()

T = 24
M = [
    "###################",
    "#........#........#",
    "#.###.###.#.###.###",
    "#.................#",
    "###.#.#####.#.###.#",
    "#...#...#...#.....#",
    "#.#####.#.#####.###",
    "#........#........#",
    "###################",
]
W, H = len(M[0]) * T, len(M) * T
sc = pygame.display.set_mode((W, H))
clock = pygame.time.Clock()
font = pygame.font.SysFont(None, 28)

WALL = {
    (x, y)
    for y, row in enumerate(M)
    for x, ch in enumerate(row)
    if ch == "#"
}
PEL0 = {
    (x, y)
    for y, row in enumerate(M)
    for x, ch in enumerate(row)
    if ch == "."
}

DIR = {
    pygame.K_LEFT:  (-1, 0),
    pygame.K_RIGHT: ( 1, 0),
    pygame.K_UP:    ( 0,-1),
    pygame.K_DOWN:  ( 0, 1),
}

def reset():
    p = [1, 1]
    g = [len(M[0]) - 2, len(M) - 2]
    return p, g, set(PEL0), ""


def step(pos, d):
    nx, ny = pos[0] + d[0], pos[1] + d[1]
    return pos if (nx, ny) in WALL else [nx, ny]


def ghost_move(g, p):
    opts = [(1,0), (-1,0), (0,1), (0,-1)]
    random.shuffle(opts)
    best, bd = g, 10**9
    for d in opts:
        ng = step(g, d)
        dist = abs(ng[0] - p[0]) + abs(ng[1] - p[1])
        if dist < bd:
            best, bd = ng, dist
    return best
def draw(p, g, pel, msg):
    sc.fill((0, 0, 0))
    for x, y in WALL:
        pygame.draw.rect(sc, (30, 30, 180), (x*T, y*T, T, T))
    for x, y in pel:
        pygame.draw.circle(sc, (240, 220, 120), (x*T+T//2, y*T+T//2), 3)

    pygame.draw.circle(sc, (250, 240, 60),
        (p[0]*T + T//2, p[1]*T + T//2), T//2 - 2)

    pygame.draw.circle(sc, (220, 60, 60),
        (g[0]*T + T//2, g[1]*T + T//2), T//2 - 2)

    if msg:
        t = font.render(msg, True, (255, 255, 255))
        sc.blit(t, (W//2 - t.get_width()//2, H//2 - t.get_height()//2))


p, g, pel, msg = reset()
last_ghost = 0

while True:
    for e in pygame.event.get():
        if e.type == pygame.QUIT:
            pygame.quit(); sys.exit()

        if e.type == pygame.KEYDOWN:
            if e.key == pygame.K_r:
                p, g, pel, msg = reset()
            elif not msg:
                d = DIR.get(e.key)
                if d:
                    p = step(p, d)



    pel.discard(tuple(p))
    now = pygame.time.get_ticks()
    if not msg and now - last_ghost > 140:
        g = ghost_move(g, p)
        last_ghost = now

    if p == g:
        msg = "GAME OVER  (R to restart)"
    elif not pel:
        msg = "YOU WIN  (R to restart)"

    draw(p, g, pel, msg)
    pygame.display.flip()
    clock.tick(60)
 
