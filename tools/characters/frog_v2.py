# Лягушонок v2 (рисунок автора, tools/art_src/frog_atlas.png, 11-26): в шляпе со звёздами.
# Заменяет кадры spr_frog_* (размер 32x32 и origin 0,0 прежние — код не меняется) и добавляет новые позы:
#   spr_frog_walk_down, spr_frog_idle_left/right, spr_frog_happy, spr_frog_sit, spr_frog_wave, spr_frog_love, spr_frog_sleep.
# Запуск (GameMaker закрыт): python3 tools/characters/frog_v2.py [папка_превью]
import os, sys
import numpy as np
from PIL import Image
from scipy import ndimage
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.join(HERE, '..', 'village'))
import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
PREV = sys.argv[1] if len(sys.argv) > 1 else None
a = np.array(Image.open(os.path.join(HERE, '..', 'art_src', 'frog_atlas.png')).convert('RGBA'))
a[a[:, :, 3] < 128] = 0; a[:, :, 3] = np.where(a[:, :, 3] > 0, 255, 0)
SRC = Image.fromarray(a)
lab, _ = ndimage.label(ndimage.binary_dilation(a[:, :, 3] > 0, iterations=3))
W = H = 32
K = 0.158                                            # общий масштаб: лягушонок ~30 px ростом, как раньше

def cut(x1, y1, x2, y2):
    """кадр: только пятна, чей центр в рамке (значки «!», сердечко, Zzz — тоже)"""
    sub = lab[y1:y2, x1:x2]; keep = np.zeros(sub.shape, bool)
    for L in np.unique(sub):
        if not L: continue
        ys, xs = np.nonzero(lab == L)
        if x1 <= xs.mean() < x2 and y1 <= ys.mean() < y2: keep |= sub == L
    arr = np.array(SRC.crop((x1, y1, x2, y2))); arr[~keep] = 0
    im = Image.fromarray(arr); return im.crop(im.getbbox())

def shrink(im, k):
    w, h = max(1, round(im.width * k)), max(1, round(im.height * k))
    arr = np.array(im).astype(np.float32); al = arr[:, :, 3:4] / 255
    pm = np.concatenate([arr[:, :, :3] * al, arr[:, :, 3:4]], 2)
    r = np.stack([np.array(Image.fromarray(pm[:, :, c].astype(np.uint8)).resize((w, h), Image.BOX)) for c in range(4)], 2).astype(np.float32)
    al2 = r[:, :, 3:4] / 255
    rgb = np.where(al2 > 0, r[:, :, :3] / np.maximum(al2, 1e-3), 0)
    out = np.concatenate([np.clip(rgb, 0, 255), np.where(al2 > 0.45, 255, 0)], 2).astype(np.uint8)
    out[out[:, :, 3] == 0] = 0
    return Image.fromarray(out)

def frame(box):
    """низ лягушонка на y=31, центр тела по x=16; широкие позы (Zzz, сердечко) ужимаются до 32"""
    im = cut(*box)
    k = min(K, (W - 1) / im.width, (H - 1) / im.height)
    s = shrink(im, k)
    c = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    al = np.array(s)[:, :, 3] > 0; cols = np.nonzero(al[s.height * 2 // 3:].any(0))[0]   # центр по ногам/телу, не по значкам
    bx = (cols.min() + cols.max() + 1) // 2 if len(cols) else s.width // 2
    c.alpha_composite(s, (max(0, min(W - s.width, 16 - bx)), H - 1 - s.height))
    return c

def reg(name, frames, speed=None):
    old = f'{P}/sprites/{name}/{name}.yy'
    if speed is None:
        speed = 30.0
        if os.path.exists(old):
            import re; m = re.search(r'"playbackSpeed":([\d.]+)', open(old).read()); speed = float(m.group(1)) if m else 30.0
    data = [[[f.load()[x, y] for x in range(W)] for y in range(H)] for f in frames]
    folder = FOLDER
    if os.path.exists(old):
        import json, re
        pr = json.loads(re.sub(r',(\s*[}\]])', r'\1', open(old).read()))['parent']; folder = (pr['name'], pr['path'])
    gm_anim.sprite(P, name, data, (0, 0), (0, 0, W - 1, H - 1), speed, folder=folder)
    if PREV:
        strip = Image.new('RGBA', (W * len(frames), H), (60, 70, 60, 255))
        for i, f in enumerate(frames): strip.alpha_composite(f, (i * W, 0))
        strip.resize((strip.width * 6, H * 6), Image.NEAREST).save(os.path.join(PREV, name + '.png'))

# рамки из атласа (x1, y1, x2, y2)
R1 = [(120, 0, 300, 215), (300, 0, 530, 215), (540, 0, 720, 215), (745, 0, 925, 215), (960, 0, 1140, 215)]
ROW = lambda y1, y2, xs: [(x - 20, y1, x + 170, y2) for x in xs]
DOWN  = ROW(215, 418, [190, 415, 640, 862])
UP    = ROW(418, 612, [190, 412, 638, 862])
LEFT  = ROW(612, 795, [170, 400, 630, 864])
RIGHT = ROW(795, 990, [192, 422, 650, 885])
R6 = [(140, 995, 340, 1220), (360, 995, 580, 1220), (585, 995, 830, 1220), (845, 995, 1090, 1220)]

FOLDER = ('Froggy', 'folders/Sprites/characters/Froggy.yy')
f = lambda boxes: [frame(b) for b in boxes]
reg('spr_frog_idle_down', [frame(R1[0])] * 4)
reg('spr_frog_idle_up', [frame(R1[2])] * 4)
reg('spr_frog_walk_up', f(UP))
reg('spr_frog_walk_side_left', f(LEFT))
reg('spr_frog_walk_side_right', f(RIGHT))
reg('spr_frog_walk_down', f(DOWN), 8)
reg('spr_frog_idle_left', [frame(R1[3])], 0)
reg('spr_frog_idle_right', [frame(R1[4])], 0)
reg('spr_frog_happy', [frame(R1[1])], 0)
reg('spr_frog_sit', [frame(R6[0])], 0)
reg('spr_frog_wave', [frame(R6[1])], 0)
reg('spr_frog_love', [frame(R6[2])], 0)
reg('spr_frog_sleep', [frame(R6[3])], 0)
print('ok')
