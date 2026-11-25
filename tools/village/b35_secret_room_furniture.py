# Партия 35: мебель тайной комнаты бабушки Сони из атласа автора (tools/art_src/secret_room_furniture_atlas.png, 1:1).
# Режет атлас на предметы, создаёт spr_secret_* + obj_secret_* и расставляет rm_secret_room.
# Мебель на полу: начало — низ по центру, маска — нижняя полоса, depth = -bbox_bottom (как у Макса).
# Окно и ковёр: начало в левом верхнем углу, без столкновений.
# Круглый стол = obj_secret_notebook (зелёная тетрадь на нём) — ему меняется только спрайт.
# Запуск (GameMaker закрыт): python3 tools/village/b35_secret_room_furniture.py
import os, re, sys, uuid
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_res
from PIL import Image
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
ATLAS = os.path.join(HERE, '..', 'art_src', 'secret_room_furniture_atlas.png')
SPR_FOLDER = ('Room_hall_furniture', 'folders/Sprites/Room_hall_furniture.yy')
OBJ_FOLDER = ('Bakery_obj_room', 'folders/Objects/Bakery_obj_room.yy')
DEPTH = '// глубина по низу маски, как у Макса — он заходит за верх мебели\ndepth = -bbox_bottom;\n'

# имя: (рамка в атласе x0,y0,x1,y1 включительно, на полу?, доля высоты под маску)
PIECES = {
    'wardrobe':      ((219, 10, 273, 90),   True, 0.30),
    'round_table':   ((16, 35, 57, 69),     True, 0.35),
    'chair_l':       ((91, 37, 110, 70),    True, 0.35),
    'chair_r':       ((130, 37, 149, 70),   True, 0.35),
    'plant_table':   ((9, 145, 114, 206),   True, 0.35),
    'potion_table':  ((123, 140, 226, 207), True, 0.35),
    'rocking_chair': ((276, 151, 320, 208), True, 0.40),
    'bookshelf':     ((8, 254, 118, 356),   True, 0.25),
    'window':        ((240, 253, 313, 353), False, 0),
    'rug':           ((139, 278, 224, 315), False, 0),
}
# расстановка: floor — (x,y) низ-центр; стена/ковёр — левый верх
LAYOUT = {
    'bookshelf': (72, 226), 'plant_table': (196, 232), 'window': (263, 52),
    'potion_table': (468, 236), 'wardrobe': (576, 228),
    'rug': (257, 304), 'chair_l': (261, 328), 'chair_r': (339, 328),
    'rocking_chair': (532, 430),
}
NOTEBOOK_XY = (300, 332)   # круглый стол с тетрадью — по центру ковра

atlas = Image.open(ATLAS).convert('RGBA')
assert atlas.size == (342, 365), atlas.size
yyp = open(f'{P}/max_farm_demo.yyp').read()
assert '"spr_secret_wardrobe"' not in yyp, 'мебель уже добавлена'

def crop(b):
    im = atlas.crop((b[0], b[1], b[2] + 1, b[3] + 1)); w, h = im.size; px = im.load()
    return [[px[x, y] for x in range(w)] for y in range(h)], w, h

made = {}
for name, (box, floor, part) in PIECES.items():
    img, w, h = crop(box); spr = 'spr_secret_' + name
    if floor: org, bb = (w // 2, h), (1, h - max(6, round(h * part)), w - 2, h - 1)
    else:     org, bb = (0, 0), gm_res.opaque(img)
    gm_res.sprite(P, spr, img, org, bb, folder=SPR_FOLDER)
    names = [spr]
    if name != 'round_table':
        obj = 'obj_secret_' + name
        gm_res.obj(P, obj, spr, 'obj_solid' if floor else None,
                   events={(0, 0, 'Create_0.gml'): DEPTH} if floor else None, solid=floor)
        t = open(f'{P}/objects/{obj}/{obj}.yy').read()
        t = re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"[^"]*",\s*\}',
                   f'"parent":{{\n    "name":"{OBJ_FOLDER[0]}",\n    "path":"{OBJ_FOLDER[1]}",\n  }}', t, count=1)
        open(f'{P}/objects/{obj}/{obj}.yy', 'w').write(t)
        names.append(obj); made[name] = obj
    gm_res.add_to_yyp(P, names)
    print('ok', spr, w, 'x', h)

# стол с тетрадью: новый спрайт вместо spr_coffee_table
nf = f'{P}/objects/obj_secret_notebook/obj_secret_notebook.yy'; t = open(nf).read()
t, n = re.subn(r'"spriteId":\{\s*"name":"spr_coffee_table",\s*"path":"sprites/spr_coffee_table/spr_coffee_table.yy",\s*\}',
               '"spriteId":{\n    "name":"spr_secret_round_table",\n    "path":"sprites/spr_secret_round_table/spr_secret_round_table.yy",\n  }', t)
assert n == 1; open(nf, 'w').write(t)

# комната
rf = f'{P}/rooms/rm_secret_room/rm_secret_room.yy'; r = open(rf).read()
r, n = re.subn(r'("%Name":"inst_SR_NOTEBOOK".*?"x":)[-\d.]+(,"y":)[-\d.]+', lambda m: f'{m.group(1)}{NOTEBOOK_XY[0]}.0{m.group(2)}{NOTEBOOK_XY[1]}.0', r)
assert n == 1
line = re.search(r'\n\s*\{"\$GMRInstance":"v4","%Name":"inst_SR_NOTEBOOK"[^\n]*\n', r).group(0)
for name, (x, y) in LAYOUT.items():
    nm = 'inst_SR_' + name.upper().replace('_', '')[:10] + uuid.uuid4().hex[:4].upper()
    l = line.replace('inst_SR_NOTEBOOK', nm).replace('obj_secret_notebook', made[name])
    l = re.sub(r'"x":[-\d.]+,"y":[-\d.]+', f'"x":{x}.0,"y":{y}.0', l)
    r = r.replace(line, line + l.lstrip('\n'), 1)
    r = r.replace('"instanceCreationOrder":[\n', f'"instanceCreationOrder":[\n    {{"name":"{nm}","path":"rooms/rm_secret_room/rm_secret_room.yy",}},\n', 1)
open(rf, 'w').write(r)
print('комната обновлена')
