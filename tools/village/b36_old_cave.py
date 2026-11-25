# Партия 36: старая пещера (после разговора с Джо).
#  - тайлсет tl_cave_ts (1 — скала, 2 — низ скалы с тенью, 3 — каменный пол), процедурный, временный;
#  - комната rm_cave (608x544, клон rm_secret_room без мебели): темнота со светом вокруг Макс (obj_cave_controller),
#    выход вниз — обратно в лес (obj_cave_exit);
#  - в rm_forest_entrance в тупике верхней ветки: скалы с низким тёмным входом (obj_cave_rocks),
#    расколотый камень (obj_cave_split_stone), невидимые стенки, заслон прохода до разговора с Джо (obj_cave_gate)
#    и переход шагом вверх (obj_cave_entrance_door).
# Запуск (GameMaker закрыт): python3 tools/village/b36_old_cave.py
import os, sys, re, glob, uuid, random
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_anim, gm_res
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
yyp = open(f'{P}/max_farm_demo.yyp').read()
assert '"rm_cave"' not in yyp, 'пещера уже добавлена'
random.seed(36)

# ---------- тайлсет ----------
im = Image.open(glob.glob(f'{P}/sprites/tl_room_hall/*.png')[0]).convert('RGBA')
def rock_wall():
    t = Image.new('RGBA', (32, 32), (62, 54, 52, 255)); d = ImageDraw.Draw(t)
    for _ in range(9):                                         # каменные «плиты»
        x, y = random.randrange(0, 28), random.randrange(0, 28); w, h = random.randrange(6, 14), random.randrange(4, 9)
        c = random.choice([(70, 61, 58, 255), (56, 49, 47, 255), (76, 66, 62, 255)])
        d.rectangle((x, y, min(31, x + w), min(31, y + h)), fill=c)
    for _ in range(4):                                         # трещины
        x, y = random.randrange(2, 30), random.randrange(2, 26)
        d.line((x, y, x + random.choice([-3, 3]), y + 5), fill=(36, 30, 30, 255))
    for _ in range(10): d.point((random.randrange(32), random.randrange(32)), fill=(90, 80, 74, 255))
    return t
def rock_wall_bottom():
    t = rock_wall(); d = ImageDraw.Draw(t)
    d.rectangle((0, 24, 31, 31), fill=(44, 38, 37, 255))      # подножие скалы в тени
    d.line((0, 23, 31, 23), fill=(84, 74, 68, 255))
    for x in range(0, 32, 5): d.point((x + 2, 27), fill=(58, 50, 48, 255))
    return t
def cave_floor():
    t = Image.new('RGBA', (32, 32), (80, 70, 62, 255)); d = ImageDraw.Draw(t)
    for _ in range(14): d.point((random.randrange(32), random.randrange(32)), fill=(68, 59, 53, 255))
    for _ in range(8):  d.point((random.randrange(32), random.randrange(32)), fill=(94, 84, 74, 255))
    for _ in range(3):                                         # камешки
        x, y = random.randrange(2, 29), random.randrange(2, 29)
        d.rectangle((x, y, x + 2, y + 1), fill=(104, 94, 86, 255)); d.line((x, y + 2, x + 2, y + 2), fill=(58, 50, 46, 255))
    return t
im.paste(rock_wall(), (32, 0)); im.paste(rock_wall_bottom(), (64, 0)); im.paste(cave_floor(), (0, 32))
px = im.load(); W, H = im.size
gm_anim.sprite(P, 'tl_cave', [[[px[x, y] for x in range(W)] for y in range(H)]], (0, 0), (0, 0, W - 1, H - 1), 0,
               folder=('Tile Sets', 'folders/Tile Sets.yy'))
ts = open(f'{P}/tilesets/tl_room_hall1/tl_room_hall1.yy').read()
ts = ts.replace('tl_room_hall1', 'tl_cave_ts').replace('"name":"tl_room_hall"', '"name":"tl_cave"').replace('sprites/tl_room_hall/tl_room_hall.yy', 'sprites/tl_cave/tl_cave.yy')
os.makedirs(f'{P}/tilesets/tl_cave_ts'); open(f'{P}/tilesets/tl_cave_ts/tl_cave_ts.yy', 'w').write(ts)
y = open(f'{P}/max_farm_demo.yyp').read()
a = '    {"id":{"name":"tl_room_hall1"'
y = y.replace(a, '    {"id":{"name":"tl_cave_ts","path":"tilesets/tl_cave_ts/tl_cave_ts.yy",},},\n' + a, 1)
open(f'{P}/max_farm_demo.yyp', 'w').write(y)

# ---------- объекты ----------
SRC = os.path.join(HERE, 'b36_gml')
def code(n): return open(os.path.join(SRC, n)).read()
gm_res.obj(P, 'obj_cave_controller', None, None, events={
    (0, 0, 'Create_0.gml'): code('cave_controller_create.gml'),
    (3, 0, 'Step_0.gml'): code('cave_controller_step.gml'),
    (8, 73, 'Draw_73.gml'): code('cave_controller_draw_end.gml'),
    (12, 0, 'CleanUp_0.gml'): 'if (surface_exists(light_surf)) surface_free(light_surf);\n'}, solid=False)
gm_res.obj(P, 'obj_cave_exit', None, None, events={
    (0, 0, 'Create_0.gml'): '// ===== ВЫХОД ИЗ ПЕЩЕРЫ — шагом вниз, обратно в лес к скалам =====\ndoor_init(236, 482, 372, 540, "down", rm_forest_entrance, 876, 196);\n',
    (3, 0, 'Step_0.gml'): 'door_step();\n'}, solid=False)
gm_res.obj(P, 'obj_cave_entrance_door', None, None, events={
    (0, 0, 'Create_0.gml'): '// ===== ВХОД В СТАРУЮ ПЕЩЕРУ (лес) — шагом вверх в тёмный проход между скалами =====\n// Открыт после разговора с Джо; до этого проход закрыт obj_cave_gate.\ndoor_init(879, 150, 905, 182, "up", rm_cave, 288, 430, function() { return global.jack_cave_talk_done; });\n',
    (3, 0, 'Step_0.gml'): 'door_step();\n'}, solid=False)
gm_res.obj(P, 'obj_cave_rocks', None, None, events={
    (0, 0, 'Create_0.gml'): '// ===== СКАЛЫ С НИЗКИМ ВХОДОМ В ПЕЩЕРУ (лес, тупик верхней ветки) — временная графика =====\ndepth = -196;\n',
    (8, 0, 'Draw_0.gml'): code('cave_rocks_draw.gml')}, solid=False)
gm_res.obj(P, 'obj_cave_split_stone', None, None, events={
    (0, 0, 'Create_0.gml'): '// ===== РАСКОЛОТЫЙ КАМЕНЬ у поворота к пещере — временная графика (spr_forest_big_stone, две половинки) =====\ndepth = -236;\n',
    (8, 0, 'Draw_0.gml'): code('cave_split_stone_draw.gml')}, solid=False)
gm_res.obj(P, 'obj_cave_gate', 'spr_forest_block', 'obj_forest_blocker', events={
    (3, 0, 'Step_0.gml'): '// ===== ЗАСЛОН ПРОХОДА В ПЕЩЕРУ: исчезает после разговора с Джо =====\nforest_episode_init();\nif (global.jack_cave_talk_done) instance_destroy();\n'}, solid=True)
gm_res.add_to_yyp(P, ['obj_cave_controller', 'obj_cave_exit', 'obj_cave_entrance_door', 'obj_cave_rocks', 'obj_cave_split_stone', 'obj_cave_gate'])
# у объектов без событий Create в шаблоне — проверим, что Draw_73 правильно названо
assert os.path.exists(f'{P}/objects/obj_cave_controller/Draw_73.gml')

# ---------- комната rm_cave (клон тайной комнаты) ----------
r = open(f'{P}/rooms/rm_secret_room/rm_secret_room.yy').read()
keep = ['inst_SR_WALLTOP', 'inst_SR_WALLL', 'inst_SR_WALLR', 'inst_SR_SPAWN', 'inst_SR_EXIT']
out = []
for line in r.split('\n'):
    m = re.search(r'"(?:%Name|name)":"(inst_SR_\w+)"', line)
    if m and m.group(1) not in keep: continue
    out.append(line)
r = '\n'.join(out)
r = r.replace('rm_secret_room', 'rm_cave').replace('inst_SR_', 'inst_CV_')
r = r.replace('"name":"obj_secret_room_exit","path":"objects/obj_secret_room_exit/obj_secret_room_exit.yy"', '"name":"obj_cave_exit","path":"objects/obj_cave_exit/obj_cave_exit.yy"')
r = r.replace('"name":"tl_secret_room_ts","path":"tilesets/tl_secret_room_ts/tl_secret_room_ts.yy"', '"name":"tl_cave_ts","path":"tilesets/tl_cave_ts/tl_cave_ts.yy"')
r, n = re.subn(r'("%Name":"inst_CV_WALLTOP".*?"scaleY":)[\d.]+', r'\g<1>4.0000', r); assert n == 1
r = re.sub(r'"TileCompressedData":\[\n.*?\n', '"TileCompressedData":[\n          ' + ('-19,1,-11,0,' * 3) + '-19,2,-11,0,' + ('-19,3,-11,0,' * 13) + '\n', r, count=1, flags=re.S)
line = re.search(r'\n\s*\{"\$GMRInstance":"v4","%Name":"inst_CV_SPAWN"[^\n]*\n', r).group(0)
l = line.replace('inst_CV_SPAWN', 'inst_CV_CTRL').replace('"name":"obj_spawn_controller","path":"objects/obj_spawn_controller/obj_spawn_controller.yy"', '"name":"obj_cave_controller","path":"objects/obj_cave_controller/obj_cave_controller.yy"')
l = re.sub(r'"x":[-\d.]+,"y":[-\d.]+', '"x":32.0,"y":32.0', l)
r = r.replace(line, line + l.lstrip('\n'), 1)
r = r.replace('{"name":"inst_CV_EXIT","path":"rooms/rm_cave/rm_cave.yy",},', '{"name":"inst_CV_EXIT","path":"rooms/rm_cave/rm_cave.yy",},\n    {"name":"inst_CV_CTRL","path":"rooms/rm_cave/rm_cave.yy",},')
assert 'obj_secret' not in r and r.count('inst_CV_CTRL') == 3, r.count('inst_CV_CTRL')
os.makedirs(f'{P}/rooms/rm_cave')
open(f'{P}/rooms/rm_cave/rm_cave.yy', 'w').write(r)
cc = open(f'{P}/rooms/rm_secret_room/RoomCreationCode.gml').read()
cc = cc.replace('// rm_secret_room — Creation Code', '// rm_cave — Creation Code').replace(
    '// Тайная комната бабушки Сони: полулаборатория, полуоранжерея, полуварка зелий. Размер — как у сарая,\n// стены — фиолетовые обои (тайлсет tl_secret_room_ts, стена 6 тайлов как у Макс), пол как везде. Мебель автор дорисует.',
    '// Старая пещера за расколотым камнем (лес). Временный тайлсет tl_cave_ts, темнота — obj_cave_controller.\n// Дальше по сюжету: фонарь у входа -> хранитель -> три испытания.')
open(f'{P}/rooms/rm_cave/RoomCreationCode.gml', 'w').write(cc)
y = open(f'{P}/max_farm_demo.yyp').read()
y = y.replace('    {"id":{"name":"rm_secret_room","path":"rooms/rm_secret_room/rm_secret_room.yy",},},',
              '    {"id":{"name":"rm_secret_room","path":"rooms/rm_secret_room/rm_secret_room.yy",},},\n    {"id":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},', 1)
a = '{"roomId":{"name":"rm_secret_room","path":"rooms/rm_secret_room/rm_secret_room.yy",},},'
assert a in y and '"rm_cave"' in y
y = y.replace(a, a + '\n    {"roomId":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},', 1)
open(f'{P}/max_farm_demo.yyp', 'w').write(y)

# ---------- лес: скалы, камень, стенки, заслон, дверь ----------
ff = f'{P}/rooms/rm_forest_entrance/rm_forest_entrance.yy'; f = open(ff).read()
tpl = re.search(r'\n\s*\{"\$GMRInstance":"v4","%Name":"(inst_\w+)"[^\n]*"objectId":\{"name":"obj_forest_blocker"[^\n]*\n', f)
line, tname = tpl.group(0), tpl.group(1)
ADD = [('inst_CAVE_ROCKS', 'obj_cave_rocks', 0, 0, 1, 1),
       ('inst_CAVE_STONE', 'obj_cave_split_stone', 0, 0, 1, 1),
       ('inst_CAVE_DOOR', 'obj_cave_entrance_door', 0, 0, 1, 1),
       ('inst_CAVE_GATE', 'obj_cave_gate', 879, 140, 0.8125, 1.75),
       ('inst_CAVE_WALLL', 'obj_forest_blocker', 812, 166, 2.09375, 0.9375),
       ('inst_CAVE_WALLR', 'obj_forest_blocker', 906, 166, 2.15625, 0.9375),
       ('inst_CAVE_STONEB', 'obj_forest_blocker', 800, 222, 1.375, 0.4375)]
for nm, obj, x, y_, sx, sy in ADD:
    l = line.replace(tname, nm).replace('"name":"obj_forest_blocker","path":"objects/obj_forest_blocker/obj_forest_blocker.yy"', f'"name":"{obj}","path":"objects/{obj}/{obj}.yy"')
    l = re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+,"x":[-\d.]+,"y":[-\d.]+', f'"scaleX":{sx},"scaleY":{sy},"x":{x}.0,"y":{y_}.0', l)
    f = f.replace(line, line + l.lstrip('\n'), 1)
    f = f.replace('"instanceCreationOrder":[\n', f'"instanceCreationOrder":[\n    {{"name":"{nm}","path":"rooms/rm_forest_entrance/rm_forest_entrance.yy",}},\n', 1)
open(ff, 'w').write(f)
print('ok')
