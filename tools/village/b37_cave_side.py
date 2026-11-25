# Партия 37: пещера в виде сбоку — проход (фонарь, хранитель) и арена первого испытания (глиняный страж).
# Код объектов — tools/village/b37_gml/*.gml, общий скрипт — scripts/scr_cave_side.
#  - obj_side_solid (поверхность-прямоугольник), obj_max_side (Макс с прыжком);
#  - obj_cave_controller пересоздаётся (раньше — темнота в комнате вида сверху), obj_cave_exit удаляется;
#  - rm_cave — проход 1920x540 без тайлов, только контроллер; rm_cave_arena — арена 960x540.
# Запуск (GameMaker закрыт): python3 tools/village/b37_cave_side.py
import os, sys, re, shutil
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_res
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
G = os.path.join(HERE, 'b37_gml')
def code(n): return open(os.path.join(G, n)).read()
yyp = open(f'{P}/max_farm_demo.yyp').read()
assert '"rm_cave_arena"' not in yyp, 'уже собрано'

# --- скрипт scr_cave_side (gml уже лежит) ---
sd = f'{P}/scripts/scr_cave_side'
assert os.path.exists(f'{sd}/scr_cave_side.gml')
open(f'{sd}/scr_cave_side.yy', 'w').write(open(f'{P}/scripts/draw_hint/draw_hint.yy').read().replace('draw_hint', 'scr_cave_side'))
yyp = yyp.replace('    {"id":{"name":"draw_hint","path":"scripts/draw_hint/draw_hint.yy",},},',
                  '    {"id":{"name":"draw_hint","path":"scripts/draw_hint/draw_hint.yy",},},\n    {"id":{"name":"scr_cave_side","path":"scripts/scr_cave_side/scr_cave_side.yy",},},', 1)
assert '"scr_cave_side"' in yyp

# --- удалить старые объекты пещеры вида сверху ---
for o in ['obj_cave_exit', 'obj_cave_controller']:
    shutil.rmtree(f'{P}/objects/{o}')
yyp = yyp.replace('\n    {"id":{"name":"obj_cave_exit","path":"objects/obj_cave_exit/obj_cave_exit.yy",},},', '')
assert '"obj_cave_exit"' not in yyp
open(f'{P}/max_farm_demo.yyp', 'w').write(yyp)

# --- объекты ---
gm_res.obj(P, 'obj_side_solid', None, None, events={
    (0, 0, 'Create_0.gml'): '// ===== ПОВЕРХНОСТЬ ПЕЩЕРЫ (вид сбоку) — прямоугольник x1..x2 / y1..y2, задаёт side_solid() =====\n'
                            '// Рисует контроллер комнаты (side_draw_solids), столкновения — side_box_hit / side_oneway_land.\n'
                            'x1 = 0; y1 = 0; x2 = 0; y2 = 0;\nkind = "earth";\noneway = false;\nvisible = false;\n'}, solid=False)
gm_res.obj(P, 'obj_max_side', None, None, events={
    (0, 0, 'Create_0.gml'): code('max_side_create.gml'),
    (3, 0, 'Step_0.gml'): code('max_side_step.gml'),
    (8, 0, 'Draw_0.gml'): code('max_side_draw.gml')}, solid=False)
gm_res.obj(P, 'obj_cave_controller', None, None, events={
    (0, 0, 'Create_0.gml'): code('cave_create.gml'),
    (3, 0, 'Step_0.gml'): code('cave_step.gml'),
    (3, 2, 'Step_2.gml'): code('cave_end_step.gml'),
    (8, 0, 'Draw_0.gml'): code('cave_draw.gml'),
    (8, 73, 'Draw_73.gml'): code('cave_draw_end.gml'),
    (8, 64, 'Draw_64.gml'): code('cave_draw_gui.gml'),
    (12, 0, 'CleanUp_0.gml'): code('cave_cleanup.gml')}, solid=False)
gm_res.obj(P, 'obj_clay_arena', None, None, events={
    (0, 0, 'Create_0.gml'): code('arena_create.gml'),
    (3, 0, 'Step_0.gml'): code('arena_step.gml'),
    (3, 2, 'Step_2.gml'): code('arena_end_step.gml'),
    (8, 0, 'Draw_0.gml'): code('arena_draw.gml'),
    (8, 73, 'Draw_73.gml'): code('arena_draw_end.gml'),
    (8, 64, 'Draw_64.gml'): code('arena_draw_gui.gml'),
    (12, 0, 'CleanUp_0.gml'): code('arena_cleanup.gml')}, solid=False)
gm_res.add_to_yyp(P, ['obj_side_solid', 'obj_max_side', 'obj_cave_controller', 'obj_clay_arena'])
for o in ['obj_side_solid', 'obj_max_side', 'obj_cave_controller', 'obj_clay_arena']:   # шаблон — с родителем obj_village_prop: убрать
    f = f'{P}/objects/{o}/{o}.yy'; t = open(f).read()
    assert '"parentObjectId":null' in t, o
    t = t.replace('"visible":false', '"visible":true') if o != 'obj_side_solid' else t
    open(f, 'w').write(t)

# --- комнаты ---
rf = f'{P}/rooms/rm_cave/rm_cave.yy'; r = open(rf).read()
out = []
for line in r.split('\n'):
    m = re.search(r'"(?:%Name|name)":"(inst_CV_\w+)"', line)
    if m and m.group(1) != 'inst_CV_CTRL': continue
    out.append(line)
r = '\n'.join(out)
r = re.sub(r'"TileCompressedData":\[\n.*?\n', '"TileCompressedData":[\n          -510,0,\n', r, count=1, flags=re.S)
r = re.sub(r'("roomSettings":\{\s*"Height":)\d+', r'\g<1>540', r)
r = re.sub(r'("inheritRoomSettings":false,\s*"persistent":false,\s*"Width":)\d+', r'\g<1>1920', r)
assert r.count('inst_CV_') == 3 and '"Width":1920' in r, r.count('inst_CV_')
open(rf, 'w').write(r)
cc = ('// rm_cave — Creation Code\n// Старая пещера, проход (вид сбоку). Всё строит obj_cave_controller (scr_cave_side).\n'
      'room_speed = 60;\nwith (obj_soil) visible = false;\nwith (obj_crop) visible = false;\n')
open(f'{P}/rooms/rm_cave/RoomCreationCode.gml', 'w').write(cc)

a = r.replace('rm_cave', 'rm_cave_arena').replace('inst_CV_CTRL', 'inst_CA_CTRL')
a = a.replace('"name":"obj_cave_controller","path":"objects/obj_cave_controller/obj_cave_controller.yy"', '"name":"obj_clay_arena","path":"objects/obj_clay_arena/obj_clay_arena.yy"')
a = re.sub(r'("inheritRoomSettings":false,\s*"persistent":false,\s*"Width":)\d+', r'\g<1>960', a)
assert 'obj_clay_arena' in a and '"Width":960' in a
os.makedirs(f'{P}/rooms/rm_cave_arena')
open(f'{P}/rooms/rm_cave_arena/rm_cave_arena.yy', 'w').write(a)
open(f'{P}/rooms/rm_cave_arena/RoomCreationCode.gml', 'w').write(cc.replace('rm_cave — Creation Code\n// Старая пещера, проход', 'rm_cave_arena — Creation Code\n// Первое испытание: глиняный страж').replace('obj_cave_controller', 'obj_clay_arena'))
y = open(f'{P}/max_farm_demo.yyp').read()
y = y.replace('    {"id":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},',
              '    {"id":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},\n    {"id":{"name":"rm_cave_arena","path":"rooms/rm_cave_arena/rm_cave_arena.yy",},},', 1)
y = y.replace('    {"roomId":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},',
              '    {"roomId":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},\n    {"roomId":{"name":"rm_cave_arena","path":"rooms/rm_cave_arena/rm_cave_arena.yy",},},', 1)
assert y.count('"rm_cave_arena"') == 2
open(f'{P}/max_farm_demo.yyp', 'w').write(y)
print('ok')
