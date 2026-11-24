# Миска пуддинга, которую ест лягушонок ночью: spr_pudding_eaten, 5 кадров из spr_pudding_icon.
# 0 — целый, 1 — откушен кусочек, 2 — съеден до половины, 3 — осталась последняя крошка, 4 — пустая миска.
# Запуск: python3 tools/characters/pudding_eaten.py max_farm_demo [--preview out.png]
import sys, os, re
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'village'))
import gm_anim
from PIL import Image
P = sys.argv[1]
PREVIEW = sys.argv[sys.argv.index('--preview') + 1] if '--preview' in sys.argv else None
yy = open(f'{P}/sprites/spr_pudding_icon/spr_pudding_icon.yy').read()
fid = re.findall(r'"\$GMSpriteFrame":"[^"]*","%Name":"([0-9a-f-]+)"', yy)[0]
src = Image.open(f'{P}/sprites/spr_pudding_icon/{fid}.png').convert('RGBA')
W, H = src.size
px = [[src.getpixel((x, y)) for x in range(W)] for y in range(H)]
is_rim = lambda c: c[3] and c[0] == c[1] == c[2] and c[0] >= 150
PLATE, PLATE_D, SAUCE = (226, 222, 214, 255), (196, 190, 180, 255), (55, 40, 0, 255)
PLATE_TOP = 16
# внутренность тарелки: в каждой строке от первого до последнего пикселя ободка
inside = set()
for y in range(PLATE_TOP, H):
    xs = [x for x in range(W) if is_rim(px[y][x])]
    if xs:
        for x in range(xs[0], xs[-1] + 1):
            if not is_rim(px[y][x]): inside.add((x, y))

def frame(keep):
    out = [[(0, 0, 0, 0)] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            c = px[y][x]
            if not c[3]: continue
            if is_rim(c) or keep(x, y): out[y][x] = c
            elif (x, y) in inside: out[y][x] = PLATE_D if y == min(yy for xx, yy in inside if xx == x) else PLATE
    return out

full  = frame(lambda x, y: True)
bite  = frame(lambda x, y: (x - 23) ** 2 + (y - 6) ** 2 > 30)
half  = frame(lambda x, y: y >= 17 and (x - 23) ** 2 + (y - 18) ** 2 > 20)
crumb = frame(lambda x, y: (12 <= x <= 14 and 21 <= y <= 23))
empty = frame(lambda x, y: False)
for e in (crumb, empty):   # следы карамели на донышке
    for x, y in ((9, 25), (10, 25), (19, 26), (20, 26), (21, 26), (16, 23)):
        if (x, y) in inside and not (e is crumb and 12 <= x <= 14 and 21 <= y <= 23): e[y][x] = SAUCE
frames = [full, bite, half, crumb, empty]
if PREVIEW:
    pv = Image.new('RGBA', (len(frames) * 36 + 4, 40), (40, 60, 40, 255))
    for i, f in enumerate(frames):
        im = Image.new('RGBA', (W, H)); im.putdata([c for r in f for c in r]); pv.alpha_composite(im, (4 + i * 36, 4))
    pv.resize((pv.width * 6, pv.height * 6), Image.NEAREST).save(PREVIEW)
else:
    gm_anim.sprite(P, 'spr_pudding_eaten', frames, (0, 0), (0, 4, 31, 31), 0)
    print('spr_pudding_eaten', len(frames))
