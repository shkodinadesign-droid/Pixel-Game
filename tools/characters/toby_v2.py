# Тоби v2: лист art_incoming/toby_v2/toby_sheet_v2.png (1254x1254, прозрачный фон, толстый тёмный контур).
# Ряды: 0 — стояние 8 (вперёд, вперёд-улыбка, 2 сбоку, 2 спиной, 2 сбоку), 1 — ходьба сбоку 8,
#       2 — разговор 4 (у 4-го «!»), 3 — портреты 6 (у 5-го «!», у 6-го сердечко), 4 — идёт вниз 4, 5 — идёт вверх 4.
# Значки «!» и сердечко убираются (при 48 px не читаются). Ряды на листе нарисованы в разном масштабе —
# каждый ряд уменьшается так, чтобы фигура стоя была ~53 px (портрет — 54 px); общая палитра на все кадры.
# Запуск: python3 toby_v2.py <лист> <папка проекта max_farm_demo> [--preview out.png]
import sys, os
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'village'))
import gm_anim

SRC, P = sys.argv[1], sys.argv[2]
PREVIEW = sys.argv[sys.argv.index('--preview') + 1] if '--preview' in sys.argv else None

im = np.array(Image.open(SRC).convert('RGBA'))
A = im[:, :, 3] >= 128
lab, n = ndimage.label(A)
blobs = []
for i, sl in enumerate(ndimage.find_objects(lab)):
    if sl is None or (lab[sl] == i + 1).sum() < 3000: continue
    blobs.append((sl[0].start, sl[0].stop, sl[1].start, sl[1].stop, i + 1))
rows = {}
for b in blobs: rows.setdefault(b[0] // 60, []).append(b)
ROWS = [sorted(rows[k], key=lambda b: b[2]) for k in sorted(rows)]
assert [len(r) for r in ROWS] == [8, 8, 4, 6, 4, 4], [len(r) for r in ROWS]

def cut(b, has_mark=None):
    y0, y1, x0, x1, li = b
    rgba = im[y0:y1, x0:x1].copy()
    m = lab[y0:y1, x0:x1] == li
    if has_mark:
        # значок ищем только в своей зоне справа сверху (x >= mx, y <= my в координатах кадра),
        # строгим цветом (чистый жёлтый / красный), плюс его тёмная обводка (расширение на 8 px)
        mx, my = has_mark[:2]
        r, g, bl = [rgba[:, :, k].astype(int) for k in range(3)]
        mark = ((r > 200) & (g > 160) & (bl < 90)) | ((r > 180) & (g < 120) & (bl < 120) & (r - g > 80))
        zone = np.zeros_like(m); zone[:my + 1, mx:] = True
        mark &= zone
        m &= ~(ndimage.binary_dilation(mark, iterations=8) & zone)
        thin = m & ~ndimage.binary_opening(m, iterations=3)          # остатки тонкой обводки значка
        m &= ~(thin & zone)
        if len(has_mark) > 2: m[:has_mark[2] + 1, has_mark[3]:] = False  # прямоугольник целиком (фон значка залит)
        l2, _ = ndimage.label(m)
        sizes = np.bincount(l2.ravel()); sizes[0] = 0
        m = l2 == sizes.argmax()
    rgba[~m] = 0
    ys, xs = np.where(m)
    return rgba[ys.min():ys.max() + 1, xs.min():xs.max() + 1]

def shrink(a, s):
    img = Image.fromarray(a, 'RGBA').convert('RGBa')
    w, h = max(1, round(a.shape[1] * s)), max(1, round(a.shape[0] * s))
    out = np.array(img.resize((w, h), Image.BOX).convert('RGBA'))
    out[:, :, 3] = np.where(out[:, :, 3] >= 128, 255, 0)
    return out

MARKED = {(2, 3): (88, 58), (3, 4): (92, 42, 44, 110), (3, 5): (116, 100)}   # кадры со значками: зона (x от, y до)
cuts = [[cut(b, MARKED.get((ri, ci))) for ci, b in enumerate(r)] for ri, r in enumerate(ROWS)]
H_BODY, H_PORT = 53, 54   # рост 53 — как Майли и Иван (было 46, Тоби выглядел мелким)
small = []
for ri, r in enumerate(cuts):
    hmax = max(c.shape[0] for c in r)
    s = (H_PORT if ri == 3 else H_BODY) / hmax
    small.append([shrink(c, s) for c in r])

# общая палитра
allpx = np.concatenate([f[f[:, :, 3] > 0][:, :3] for r in small for f in r])
pal_img = Image.fromarray(allpx.reshape(1, -1, 3).astype(np.uint8), 'RGB').quantize(32, method=Image.MEDIANCUT)
def quant(f):
    q = np.array(Image.fromarray(f[:, :, :3], 'RGB').quantize(palette=pal_img, dither=Image.Dither.NONE).convert('RGB'))
    out = np.zeros_like(f); out[:, :, :3] = q; out[:, :, 3] = f[:, :, 3]; out[f[:, :, 3] == 0] = 0
    return out
small = [[quant(f) for f in r] for r in small]

def place(f, W, H, bottom, by_head):
    can = np.zeros((H, W, 4), np.uint8)
    h, w = f.shape[:2]
    if by_head:  # центр по голове (верхняя треть) — без дрожи при ходьбе
        ys, xs = np.where(f[: max(1, h // 3), :, 3] > 0); cx = xs.mean()
    else:
        cx = (w - 1) / 2
    x0 = int(round(W / 2 - 0.5 - cx)); y0 = bottom - h + 1
    x0 = max(0, min(W - w, x0))
    can[y0:y0 + h, x0:x0 + w] = f
    return can

body = lambda f: place(f, 56, 56, 55, True)
port = lambda f: place(f, 56, 56, 55, False)
R0, R1, R2, R3, R4, R5 = small
mirror = lambda f: f[:, ::-1].copy()
# направления проверены по превью
SIDE_A_IS_LEFT = False                           # ряд 0: кадры 2–3 смотрят вправо, 6–7 — влево
WALK_IS_RIGHT = True                             # ряд 1 нарисован идущим вправо
sprites = {
    'spr_toby_idle_down': [body(R0[0]), body(R0[1])],
    'spr_toby_idle_up': [body(R0[4]), body(R0[5])],
    'spr_toby_idle_left' if SIDE_A_IS_LEFT else 'spr_toby_idle_right': [body(R0[2]), body(R0[3])],
    'spr_toby_idle_right' if SIDE_A_IS_LEFT else 'spr_toby_idle_left': [body(R0[6]), body(R0[7])],
    'spr_toby_walk_right': [body(f if WALK_IS_RIGHT else mirror(f)) for f in R1],
    'spr_toby_walk_left': [body(mirror(f) if WALK_IS_RIGHT else f) for f in R1],
    'spr_toby_talk': [body(f) for f in R2],
    'spr_toby_portrait_anim': [port(f) for f in R3],
    'spr_toby_walk_down': [body(f) for f in R4],
    'spr_toby_walk_up': [body(f) for f in R5],
}

if PREVIEW:
    order = list(sprites)
    W = max(len(sprites[k]) for k in order) * 60 + 8
    pv = Image.new('RGBA', (W, len(order) * 62 + 4), (190, 200, 190, 255))
    for i, k in enumerate(order):
        for j, f in enumerate(sprites[k]):
            pv.alpha_composite(Image.fromarray(f, 'RGBA'), (4 + j * 60, 4 + i * 62))
    pv.resize((pv.width * 3, pv.height * 3), Image.NEAREST).save(PREVIEW)
    print('preview', order)
else:
    for name, frames in sprites.items():
        is_port = name == 'spr_toby_portrait_anim'
        fl = [[[tuple(int(v) for v in f[y, x]) for x in range(f.shape[1])] for y in range(f.shape[0])] for f in frames]
        allm = np.any(np.stack([f[:, :, 3] > 0 for f in frames]), axis=0)
        ys, xs = np.where(allm)
        origin = (0, 0) if is_port else (28, 55)
        gm_anim.sprite(P, name, fl, origin, (int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())), 0)
        print(name, len(frames))
