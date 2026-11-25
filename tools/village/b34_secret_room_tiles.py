# Тайлсет тайной комнаты бабушки Сони: копия tl_room_hall (пол тот же), но стены — таинственные
# фиолетовые обои со звёздочками и месяцами, нижний ряд стены — обои + тёмный деревянный плинтус.
# Тайлы (3 колонки по 32): 1 — обои, 2 — обои с плинтусом, 3 — пол (как везде).
import os, sys, re, glob
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE); import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')

src = glob.glob(f'{P}/sprites/tl_room_hall/*.png')[0]
im = Image.open(src).convert('RGBA')

BASE  = (70, 40, 100, 255)   # глубокий фиолетовый
BAND  = (80, 48, 114, 255)   # полоса чуть светлее
LINE  = (56, 30, 82, 255)    # тёмная линия между полосами
GOLD  = (196, 164, 92, 255)  # тусклое золото узора
GOLD2 = (150, 122, 80, 255)

def wallpaper():
    t = Image.new('RGBA', (32, 32), BASE); d = ImageDraw.Draw(t)
    d.rectangle((8, 0, 23, 31), fill=BAND)                    # широкая полоса
    d.line((7, 0, 7, 31), fill=LINE); d.line((24, 0, 24, 31), fill=LINE)
    # звёздочка в полосе (вверху) и месяц (внизу) — узор повторяется без швов
    cx, cy = 15, 8
    for x, y in [(cx, cy - 2), (cx, cy - 1), (cx, cy + 1), (cx, cy + 2), (cx - 2, cy), (cx - 1, cy), (cx + 1, cy), (cx + 2, cy)]:
        d.point((x, y), fill=GOLD2)
    d.point((cx, cy), fill=GOLD)
    mx, my = 16, 23                                            # месяц
    for x, y in [(mx - 1, my - 2), (mx - 2, my - 1), (mx - 2, my), (mx - 2, my + 1), (mx - 1, my + 2), (mx, my + 2), (mx, my - 2)]:
        d.point((x, y), fill=GOLD2)
    # крошечные точки-звёзды по краям полос
    d.point((3, 16), fill=GOLD2); d.point((28, 4), fill=GOLD2); d.point((28, 28), fill=(110, 80, 120, 255))
    return t

def wall_bottom():
    t = wallpaper(); d = ImageDraw.Draw(t)
    d.rectangle((0, 19, 31, 19), fill=(40, 22, 30, 255))      # тень над плинтусом
    d.rectangle((0, 20, 31, 31), fill=(78, 48, 44, 255))      # плинтус тёмного дерева
    d.line((0, 21, 31, 21), fill=(112, 74, 60, 255))          # блик
    d.line((0, 31, 31, 31), fill=(46, 26, 24, 255))
    for x in (0, 16): d.line((x, 22, x, 30), fill=(60, 36, 34, 255))
    return t

im.paste(wallpaper(), (32, 0))
im.paste(wall_bottom(), (64, 0))
px = im.load(); W, H = im.size
gm_anim.sprite(P, 'tl_secret_room', [[[px[x, y] for x in range(W)] for y in range(H)]], (0, 0), (0, 0, W - 1, H - 1), 0,
               folder=('Tile Sets', 'folders/Tile Sets.yy'))
# тайлсет
ts = open(f'{P}/tilesets/tl_room_hall1/tl_room_hall1.yy').read()
ts = ts.replace('tl_room_hall1', 'tl_secret_room_ts').replace('"name":"tl_room_hall"', '"name":"tl_secret_room"').replace('sprites/tl_room_hall/tl_room_hall.yy', 'sprites/tl_secret_room/tl_secret_room.yy')
os.makedirs(f'{P}/tilesets/tl_secret_room_ts', exist_ok=True)
open(f'{P}/tilesets/tl_secret_room_ts/tl_secret_room_ts.yy', 'w').write(ts)
y = open(f'{P}/max_farm_demo.yyp').read()
if '"tl_secret_room_ts"' not in y:
    a = '    {"id":{"name":"tl_room_hall1"'
    y = y.replace(a, '    {"id":{"name":"tl_secret_room_ts","path":"tilesets/tl_secret_room_ts/tl_secret_room_ts.yy",},},\n' + a, 1)
    open(f'{P}/max_farm_demo.yyp', 'w').write(y)
if len(sys.argv) > 1:
    prev = Image.new('RGBA', (32 * 6, 32 * 5))
    for gx in range(6):
        for gy in range(4): prev.paste(im.crop((32, 0, 64, 32)), (gx * 32, gy * 32))
        prev.paste(im.crop((64, 0, 96, 32)), (gx * 32, 3 * 32)); prev.paste(im.crop((0, 32, 32, 64)), (gx * 32, 4 * 32))
    prev.resize((prev.width * 3, prev.height * 3), Image.NEAREST).save(sys.argv[1])
print('ok')
