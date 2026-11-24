# Фотография «Бабушка Соня и Мэгги в детстве» (рисунок автора, tools/art_src/photo_sonya_maggie.png)
# -> spr_photo_sonya_maggie 480x360 для попапа obj_ui_photo. Белые уголки за скруглённой рамкой — прозрачные.
import os, sys
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'village')); import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
W, H = 480, 360
im = Image.open(os.path.join(HERE, '..', 'art_src', 'photo_sonya_maggie.png')).convert('RGBA').resize((W, H), Image.LANCZOS)
# прозрачные белые уголки: заливка от каждого угла по почти белым пикселям
mask = Image.new('L', (W, H), 0)
px = im.load()
for sx, sy in [(0, 0), (W - 1, 0), (0, H - 1), (W - 1, H - 1)]:
    stack = [(sx, sy)]
    while stack:
        x, y = stack.pop()
        if not (0 <= x < W and 0 <= y < H) or mask.getpixel((x, y)): continue
        r, g, b, a = px[x, y]
        if min(r, g, b) < 225: continue
        mask.putpixel((x, y), 255)
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
for y in range(H):
    for x in range(W):
        if mask.getpixel((x, y)): px[x, y] = (0, 0, 0, 0)
rows = [[px[x, y] for x in range(W)] for y in range(H)]
gm_anim.sprite(P, 'spr_photo_sonya_maggie', [rows], (0, 0), (0, 0, W - 1, H - 1), 0, folder=('characters', 'folders/Sprites/characters.yy'))
im.save('/tmp/_photo_preview.png') if len(sys.argv) > 1 else None
print('ok')
