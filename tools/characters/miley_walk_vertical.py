# Майли: на листе miley_sheet_v1 нет ходьбы вверх/вниз — собираем 4 кадра из стоячих spr_miley_idle_up/down.
# Шаг: кадр 0 — стоит, 1 — левая нога поднята (штанина короче на 2 px, сапог выше), 2 — стоит, 3 — правая.
# Плюс лёгкое покачивание: в кадрах с поднятой ногой корпус выше на 1 px.
# Запуск: python3 tools/characters/miley_walk_vertical.py max_farm_demo [--preview out.png]
import sys, os, re
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'village'))
import gm_anim
from PIL import Image
P = sys.argv[1]
PREVIEW = sys.argv[sys.argv.index('--preview') + 1] if '--preview' in sys.argv else None
N, CX, LIFT = 'miley', 28, 2

def frame0(sp):
    yy = open(f'{P}/sprites/{sp}/{sp}.yy').read()
    fid = re.findall(r'"\$GMSpriteFrame":"[^"]*","%Name":"([0-9a-f-]+)"', yy)[0]
    return Image.open(f'{P}/sprites/{sp}/{fid}.png').convert('RGBA')

def is_jeans(c):
    return c[3] and c[2] > 90 and c[2] > c[0] + 25

def walk(base):
    W, H = base.size
    px = base.load()
    leg_top = min(y for y in range(H) for x in range(W) if is_jeans(px[x, y]) and y > H * 0.7)
    def make(lift_side):
        out = Image.new('RGBA', (W, H), (0, 0, 0, 0)); o = out.load()
        bob = 1 if lift_side else 0
        for y in range(H):
            for x in range(W):
                c = px[x, y]
                if not c[3]: continue
                side = 'L' if x < CX else 'R'
                if y >= leg_top and side == lift_side:
                    # штанина этой ноги короче: строки leg_top+1..leg_top+LIFT выпадают, низ поднимается
                    if leg_top < y <= leg_top + LIFT: continue
                    ny = y - LIFT if y > leg_top + LIFT else y
                    ny -= bob
                else:
                    ny = y - bob if y < leg_top else y
                if 0 <= ny < H: o[x, ny] = c
        # корпус поднят на 1 px — заполняем щель над стоящей ногой копией строки leg_top
        if bob:
            for x in range(W):
                if (x < CX) != (lift_side == 'L') and px[x, leg_top][3] and not o[x, leg_top - 1][3]:
                    o[x, leg_top - 1] = px[x, leg_top]
        return out
    return [base, make('L'), base, make('R')]

sprites = {f'spr_{N}_walk_up': walk(frame0(f'spr_{N}_idle_up')),
           f'spr_{N}_walk_down': walk(frame0(f'spr_{N}_idle_down'))}
if PREVIEW:
    pv = Image.new('RGBA', (4 * 60 + 4, 2 * 60 + 4), (190, 200, 190, 255))
    for i, fr in enumerate(sprites.values()):
        for j, f in enumerate(fr): pv.alpha_composite(f, (4 + j * 60, 4 + i * 60))
    pv.resize((pv.width * 6, pv.height * 6), Image.NEAREST).save(PREVIEW)
else:
    for name, fr in sprites.items():
        fl = [[[f.getpixel((x, y)) for x in range(f.width)] for y in range(f.height)] for f in fr]
        W, H = fr[0].size
        gm_anim.sprite(P, name, fl, (W // 2, H - 1), (W // 2 - 10, H - 8, W // 2 + 9, H - 1), 0)
        print(name, len(fl))
