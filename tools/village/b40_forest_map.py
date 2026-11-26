# Партия 40: полноэкранная карта — рисунок автора (tools/art_src/forest_map.png, 1536x1024).
# spr_map_forest, 2 кадра по 810x540 (высота GUI):
#   0 — до разговора с Джо: тайный лес и пещера скрыты туманом-пергаментом;
#   1 — после разговора: карта целиком.
# Из плашки «Сейчас нужно» текст стёрт — цель пишет игра (forest_current_goal), она меняется по сюжету.
# Запуск (GameMaker закрыт): python3 tools/village/b40_forest_map.py [превью.png]
import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
src = np.array(Image.open(os.path.join(HERE, '..', 'art_src', 'forest_map.png')).convert('RGBA')).astype(np.float32)

# --- стереть текст цели: вертикальная интерполяция фона плашки ---
X1, X2, Y1, Y2 = 280, 1272, 760, 838
top, bot = src[Y1 - 1, X1:X2], src[Y2, X1:X2]
for y in range(Y1, Y2):
    k = (y - Y1) / (Y2 - Y1)
    src[y, X1:X2] = top * (1 - k) + bot * k
full = Image.fromarray(src.astype(np.uint8))

# --- туман над тайным лесом и пещерой ---
H0, W0 = src.shape[:2]
mask = Image.new('L', (W0, H0), 0)
ImageDraw.Draw(mask).ellipse((1060, 200, 1510, 640), fill=255)
mask = mask.filter(ImageFilter.GaussianBlur(26))
m = np.array(mask).astype(np.float32)[:, :, None] / 255 * 1.0; m = np.clip(m * 1.15, 0, 1)
rng = np.random.default_rng(40)
fog = np.zeros_like(src); fog[:, :, :3] = (244, 208, 152); fog[:, :, 3] = 255
fog[:, :, :3] += rng.normal(0, 4, (H0, W0, 1))           # лёгкая зернистость, как у бумаги
hidden = src * (1 - m) + fog * m
hidden = Image.fromarray(np.clip(hidden, 0, 255).astype(np.uint8))

GH = 540; GW = round(W0 * GH / H0)
frames = [im.resize((GW, GH), Image.LANCZOS) for im in (hidden, full)]
data = [[[f.load()[x, y] for x in range(GW)] for y in range(GH)] for f in frames]
gm_anim.sprite(P, 'spr_map_forest', data, (0, 0), (0, 0, GW - 1, GH - 1), 0, folder=('Ui', 'folders/Sprites/Ui.yy'))
if len(sys.argv) > 1:
    c = Image.new('RGBA', (GW, GH * 2)); c.paste(frames[0], (0, 0)); c.paste(frames[1], (0, GH)); c.save(sys.argv[1])
print('ok', GW, GH)
