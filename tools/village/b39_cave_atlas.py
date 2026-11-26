# Партия 39: графика пещеры от автора — tools/art_src/cave_atlas.png (тайлы, убранство, Хранитель, Глиняный страж, шар, портреты).
# Режет атлас, уменьшает до масштаба игры (Макс 32x48) и записывает спрайты:
#  - тайлы: spr_cave_wall, spr_cave_backwall (64x64), spr_cave_earth_top, spr_cave_earth, spr_cave_ledge;
#  - убранство: spr_cave_deco_<имя> (см. DECO; origin — верх-центр у висящих, низ-центр у стоящих);
#  - spr_cave_keeper (9 кадров), spr_clay_guardian (10 кадров), spr_clay_ball (7 кадров), spr_cave_rock;
#  - портреты spr_keeper_portrait, spr_clay_guardian_portrait (200x200).
# Запуск (GameMaker закрыт): python3 tools/village/b39_cave_atlas.py [папка_превью]
import os, sys
import numpy as np
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
PREV = sys.argv[1] if len(sys.argv) > 1 else None
SRC = Image.open(os.path.join(HERE, '..', 'art_src', 'cave_atlas.png')).convert('RGBA')
a = np.array(SRC); a[a[:, :, 3] < 128] = 0; a[:, :, 3] = np.where(a[:, :, 3] > 0, 255, 0)   # убрать красную кайму
SRC = Image.fromarray(a)
FOLDER = ('characters', 'folders/Sprites/characters.yy')

def crop(x1, y1, x2, y2): return SRC.crop((x1, y1, x2, y2))
def shrink(im, k):
    """уменьшение с premultiplied-альфой и жёсткой кромкой — без светлого/красного ореола"""
    w, h = max(1, round(im.width * k)), max(1, round(im.height * k))
    arr = np.array(im).astype(np.float32); al = arr[:, :, 3:4] / 255
    pm = np.concatenate([arr[:, :, :3] * al, arr[:, :, 3:4]], 2)
    r = np.stack([np.array(Image.fromarray(pm[:, :, c].astype(np.uint8)).resize((w, h), Image.BOX)) for c in range(4)], 2).astype(np.float32)
    al2 = r[:, :, 3:4] / 255
    rgb = np.where(al2 > 0, r[:, :, :3] / np.maximum(al2, 1e-3), 0)
    out = np.concatenate([np.clip(rgb, 0, 255), np.where(al2 > 0.45, 255, 0)], 2).astype(np.uint8)
    out[out[:, :, 3] == 0] = 0
    return Image.fromarray(out, 'RGBA')
def reg(name, frames, origin, speed=0):
    W, H = frames[0].size
    data = [[[f.load()[x, y] for x in range(W)] for y in range(H)] for f in frames]
    gm_anim.sprite(P, name, data, origin, (0, 0, W - 1, H - 1), speed, folder=FOLDER)
    if PREV:
        strip = Image.new('RGBA', (W * len(frames), H), (40, 40, 48, 255))
        for i, f in enumerate(frames): strip.alpha_composite(f, (i * W, 0))
        strip.resize((strip.width * 3, H * 3), Image.NEAREST).save(os.path.join(PREV, name + '.png'))
def pack(items):
    """items: [(img, ax, ay)] — точка привязки в координатах кадра -> общий холст, origin = привязка"""
    L = max(ax for _, ax, _ in items); R = max(im.width - ax for im, ax, _ in items)
    T = max(ay for _, _, ay in items); B = max(im.height - ay for im, _, ay in items)
    out = []
    for im, ax, ay in items:
        c = Image.new('RGBA', (L + R, T + B), (0, 0, 0, 0)); c.alpha_composite(im, (L - ax, T - ay)); out.append(c)
    return out, (L, T)
def trim(im):
    bb = im.getbbox(); return im.crop(bb) if bb else im

# ---------- тайлы ----------
def tile(x1, y1, x2, y2, w, h, inset=7):
    return crop(x1 + inset, y1 + inset, x2 - inset, y2 - inset).resize((w, h), Image.BOX).convert('RGBA')
def solid(im):
    arr = np.array(im); arr[:, :, 3] = 255; return Image.fromarray(arr)
reg('spr_cave_wall', [solid(tile(11, 119, 155, 253, 64, 64))], (0, 0))
reg('spr_cave_backwall', [solid(tile(157, 119, 302, 253, 64, 64))], (0, 0))
et = trim(crop(304, 133, 444, 253))                      # земля: верхняя кромка + тело
top = solid(et.crop((5, 0, et.width - 5, 60)).resize((64, 28), Image.BOX))
body = solid(et.crop((14, 70, et.width - 14, et.height - 14)).resize((64, 32), Image.BOX))
reg('spr_cave_earth_top', [solid(top)], (0, 0))
reg('spr_cave_earth', [body], (0, 0))
reg('spr_cave_ledge', [shrink(trim(crop(447, 169, 570, 228)), 0.52)], (0, 0))
reg('spr_cave_rock', [shrink(trim(crop(938, 137, 1033, 205)), 0.6)], (0, 0))

from scipy import ndimage
m = np.array(SRC)[:, :, 3] > 0
lab, _ = ndimage.label(ndimage.binary_dilation(m, iterations=2))
lab0, _ = ndimage.label(m)
def by_part(x1, y1, x2, y2):
    """предметы убранства: только пятна, у которых большая часть пикселей внутри рамки"""
    sub = lab0[y1:y2, x1:x2]; keep = np.zeros_like(sub, bool)
    for L in np.unique(sub):
        if L and (sub == L).sum() * 2 > (lab0 == L).sum(): keep |= (sub == L)
    if not keep.any(): return SRC.crop((x1, y1, x2, y2))      # предмет сросся с соседом контуром — просто рамка
    arr = np.array(SRC.crop((x1, y1, x2, y2))); arr[~keep] = 0
    return Image.fromarray(arr)
def by_label(x1, y1, x2, y2):
    """кадр рамки, но только те пятна, чей центр внутри рамки (соседние кадры заходят внутрь)"""
    sub = lab[y1:y2, x1:x2]; keep = np.zeros_like(sub, bool)
    for L in np.unique(sub):
        if L == 0: continue
        ys, xs = np.nonzero(lab == L)
        if x1 <= xs.mean() < x2: keep |= (sub == L)
    arr = np.array(SRC.crop((x1, y1, x2, y2))); arr[~keep] = 0
    return Image.fromarray(arr)

# ---------- убранство ----------
# (имя, рамка в атласе, масштаб, привязка: 'top' — висит с потолка, 'bottom' — стоит на полу)
DECO = [
    ('stal_a', (567, 120, 645, 222), 0.5, 'top'), ('stal_b', (645, 120, 736, 222), 0.5, 'top'), ('stal_c', (740, 120, 818, 188), 0.5, 'top'),
    ('rock_big', (819, 127, 937, 217), 0.5, 'bottom'), ('rock_small', (938, 137, 1033, 205), 0.5, 'bottom'),
    ('moss', (1043, 127, 1145, 225), 0.5, 'top'), ('root_a', (1152, 120, 1237, 257), 0.5, 'top'), ('root_b', (1243, 122, 1341, 268), 0.5, 'top'),
    ('flower', (1348, 128, 1437, 195), 0.4, 'bottom'),
    ('crystal_big', (29, 255, 147, 347), 0.5, 'bottom'), ('crystal_mid', (157, 273, 234, 347), 0.5, 'bottom'), ('crystal_small', (244, 300, 294, 343), 0.5, 'bottom'),
    ('mush_a', (300, 293, 374, 343), 0.45, 'bottom'), ('mush_b', (375, 274, 454, 343), 0.45, 'bottom'), ('mush_c', (458, 298, 525, 343), 0.45, 'bottom'),
    ('skull', (530, 288, 595, 345), 0.4, 'bottom'), ('shell', (598, 291, 665, 344), 0.4, 'bottom'), ('bone', (665, 291, 726, 344), 0.4, 'bottom'),
    ('stalag_big', (732, 225, 835, 344), 0.5, 'bottom'), ('stalag_small', (835, 225, 917, 344), 0.5, 'bottom'),
    ('arch', (919, 225, 1089, 352), 0.85, 'bottom'), ('pillar', (1100, 238, 1207, 352), 0.6, 'bottom'),
    ('rune', (1249, 229, 1445, 347), 0.6, 'bottom'),
]
for n, (x1, y1, x2, y2), k, anchor in DECO:            # каждый предмет — свой спрайт spr_cave_deco_<имя>
    im = shrink(trim(by_part(x1, y1, x2, y2)), k)
    reg('spr_cave_deco_' + n, [im], (im.width // 2, 0 if anchor == 'top' else im.height))

# ---------- Хранитель (смотрит вправо; в игре отражается к Макс) ----------
KEEP = [(12, 129), (138, 251), (258, 370), (374, 485), (481, 588), (592, 714), (724, 855), (859, 982), (982, 1173)]
KX = [62, 61, 61, 62, 59, 62, 62, 62, 62]                  # центр тела от левого края рамки
items = []
for (x1, x2), kx in zip(KEEP, KX):
    im = by_label(x1, 380, x2, 552)
    # центр тела: левый край мантии в нижней полосе + половина ширины мантии
    arr = np.array(im)[:, :, 3]; cols = np.nonzero(arr[150:166].any(0))[0]
    cx = (cols.min() + 50) if len(cols) else kx
    s = shrink(im, 0.52)
    items.append((s, round(cx * 0.52), round(166 * 0.52)))
fr, org = pack(items)
reg('spr_cave_keeper', fr, org)

# ---------- Глиняный страж (низ — пол, центр по рамке) ----------
CLAY = [(11, 108), (108, 205), (205, 318), (318, 442), (442, 576), (576, 729), (703, 864), (851, 988), (990, 1092), (1093, 1183)]
items = []
for i, (x1, x2) in enumerate(CLAY):
    im = by_label(x1, 600, x2, 762) if i >= 5 else SRC.crop((x1, 600, x2, 762))
    bb = im.getbbox(); cx = (bb[0] + bb[2]) / 2 if i not in (6, 7) else {6: 82, 7: 72}[i]
    s = shrink(im, 0.62)
    items.append((s, round(cx * 0.62), round(150 * 0.62)))
fr, org = pack(items)
reg('spr_clay_guardian', fr, org)

BALL = [(24, 113), (116, 203), (207, 294), (298, 385), (389, 476), (480, 567), (571, 657)]
items = []
for x1, x2 in BALL:
    s = shrink(trim(crop(x1, 790, x2, 885)), 0.64); items.append((s, s.width // 2, s.height // 2))
fr, org = pack(items)
reg('spr_clay_ball', fr, org)

# ---------- портреты ----------
def portrait(y1, y2):
    im = trim(crop(1199, y1, 1445, y2)); s = min(im.size); im = im.crop((0, 0, s, s))
    return im.resize((200, 200), Image.LANCZOS)
reg('spr_keeper_portrait', [portrait(358, 601)], (0, 0))
reg('spr_clay_guardian_portrait', [portrait(603, 851)], (0, 0))
print('ok')
