# Партия 38 (сборка): тайный лес между поляной лягушонка и старой пещерой.
#  - rm_forest_entrance: убран старый вход в пещеру из тупика (inst_CAVE_*); у правого края поляны — тропа
#    в тайный лес (obj_forest_to_mystic) за зарослями (obj_cave_gate, расступаются после разговора с Джо);
#  - rm_mystic_forest: копия опушки с перекрашенным тайлсетом (tls_mystic), только сосны, больше кустов,
#    без камня/лягушонка/контроллера опушки; лягушонок с сиропом (obj_mystic_frog) у развилки;
#    в конце — скалы со входом в пещеру (obj_cave_rocks, obj_cave_entrance_door, obj_cave_split_stone);
#  - объекты obj_cave_rocks / obj_cave_split_stone / obj_cave_entrance_door теперь рисуются от x,y.
# Код — tools/village/b38_gml. Запуск (GameMaker закрыт): python3 tools/village/b38_mystic_build.py
import os, sys, re, random, shutil
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_res
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
G = os.path.join(HERE, 'b38_gml')
def code(n): return open(os.path.join(G, n)).read()
yyp = open(f'{P}/max_farm_demo.yyp').read()
assert '"rm_mystic_forest"' not in yyp, 'уже собрано'
random.seed(38)

INST_RE = r'(?m)^[ \t]*\{"\$GMRInstance":"v4","%Name":"(inst_\w+)"[^\n]*$'   # строка без перевода строки
def inst_lines(r):
    return [(m.group(1), m.group(0)) for m in re.finditer(INST_RE, r)]
def inst_info(line):
    o = re.search(r'"objectId":\{"name":"(\w+)"', line).group(1)
    sx, sy, x, y = map(float, re.search(r'"scaleX":([-\d.]+),"scaleY":([-\d.]+),"x":([-\d.]+),"y":([-\d.]+)', line).groups())
    return o, sx, sy, x, y
def remove_inst(r, name, line):
    assert line + '\n' in r, name
    r = r.replace(line + '\n', '', 1)
    r = re.sub(r'\n\s*\{"name":"' + name + r'","path":"rooms/\w+/\w+\.yy",\},', '', r, count=1)
    return r
def add_inst(r, room, tpl_line, tpl_name, name, obj, x, y, sx=1.0, sy=1.0):
    l = tpl_line.replace(tpl_name, name)
    l = re.sub(r'"objectId":\{"name":"\w+","path":"objects/\w+/\w+\.yy",\}', f'"objectId":{{"name":"{obj}","path":"objects/{obj}/{obj}.yy",}}', l)
    l = re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+,"x":[-\d.]+,"y":[-\d.]+', f'"scaleX":{sx},"scaleY":{sy},"x":{float(x)},"y":{float(y)}', l)
    r = r.replace(tpl_line + '\n', tpl_line + '\n' + l + '\n', 1)
    r = r.replace('"instanceCreationOrder":[\n', f'"instanceCreationOrder":[\n    {{"name":"{name}","path":"rooms/{room}/{room}.yy",}},\n', 1)
    return r
def tpl_of(r, obj):
    for n, l in inst_lines(r):
        if f'"objectId":{{"name":"{obj}"' in l: return n, l
    raise KeyError(obj)
def sub_rect(a, b):          # a минус b -> список прямоугольников (x1,y1,x2,y2)
    ax1, ay1, ax2, ay2 = a; bx1, by1, bx2, by2 = b
    if bx1 >= ax2 or bx2 <= ax1 or by1 >= ay2 or by2 <= ay1: return [a]
    out = []
    if by1 > ay1: out.append((ax1, ay1, ax2, by1))
    if by2 < ay2: out.append((ax1, by2, ax2, ay2))
    my1, my2 = max(ay1, by1), min(ay2, by2)
    if bx1 > ax1: out.append((ax1, my1, bx1, my2))
    if bx2 < ax2: out.append((bx2, my1, ax2, my2))
    return out

# ---------- объекты ----------
for o, ev in [('obj_cave_rocks', {(0, 0, 'Create_0.gml'): code('rocks_create.gml'), (8, 0, 'Draw_0.gml'): code('rocks_draw.gml')}),
              ('obj_cave_split_stone', {(0, 0, 'Create_0.gml'): code('split_create.gml'), (8, 0, 'Draw_0.gml'): code('split_draw.gml')}),
              ('obj_cave_entrance_door', {(0, 0, 'Create_0.gml'): code('cave_door_create.gml'), (3, 0, 'Step_0.gml'): 'door_step();\n'})]:
    for (t, n, f), c in ev.items(): open(f'{P}/objects/{o}/{f}', 'w').write(c)
# заросли: Create + Draw к существующему Step
gd = f'{P}/objects/obj_cave_gate'
open(f'{gd}/Create_0.gml', 'w').write(code('gate_create.gml')); open(f'{gd}/Draw_0.gml', 'w').write(code('gate_draw.gml'))
y = open(f'{gd}/obj_cave_gate.yy').read()
if '"eventType":0' not in y:
    y = y.replace('"eventList":[\n', '"eventList":[\n    ' + gm_res.EV.format(num=0, typ=0) + '\n    ' + gm_res.EV.format(num=0, typ=8) + '\n', 1)
    open(f'{gd}/obj_cave_gate.yy', 'w').write(y)
gm_res.obj(P, 'obj_forest_to_mystic', None, None, events={(0, 0, 'Create_0.gml'): code('to_mystic_create.gml'), (3, 0, 'Step_0.gml'): 'door_step();\n'}, solid=False)
gm_res.obj(P, 'obj_mystic_exit', None, None, events={(0, 0, 'Create_0.gml'): code('mystic_exit_create.gml'), (3, 0, 'Step_0.gml'): 'door_step();\n'}, solid=False)
gm_res.obj(P, 'obj_mystic_forest', None, None, events={
    (0, 0, 'Create_0.gml'): code('mystic_create.gml'), (3, 0, 'Step_0.gml'): code('mystic_step.gml'),
    (8, 73, 'Draw_73.gml'): code('mystic_draw_end.gml'), (8, 64, 'Draw_64.gml'): code('mystic_draw_gui.gml')}, solid=False)
gm_res.obj(P, 'obj_mystic_frog', 'spr_frog_idle_down', None, events={
    (0, 0, 'Create_0.gml'): code('frog_create.gml'), (3, 0, 'Step_0.gml'): code('frog_step.gml'), (8, 0, 'Draw_0.gml'): code('frog_draw.gml')}, solid=False)
gm_res.add_to_yyp(P, ['obj_forest_to_mystic', 'obj_mystic_exit', 'obj_mystic_forest', 'obj_mystic_frog'])

# ---------- опушка: убрать старый вход в тупике, открыть тропу с поляны ----------
FF = f'{P}/rooms/rm_forest_entrance/rm_forest_entrance.yy'
orig = open(FF).read()
r = orig
for n, l in inst_lines(r):
    if n.startswith('inst_CAVE_'): r = remove_inst(r, n, l)
assert 'inst_CAVE_' not in r
CORR = (1696, 256, 1792, 352)
btn, bline = tpl_of(r, 'obj_forest_blocker')
new_blocks = []
for n, l in inst_lines(r):
    o, sx, sy, x, yy = inst_info(l)
    if o == 'obj_forest_blocker':
        rect = (x, yy, x + 32 * sx, yy + 32 * sy)
        parts = sub_rect(rect, CORR)
        if parts != [rect]:
            r = remove_inst(r, n, l); new_blocks += parts
    elif o in ('obj_tree_pine', 'obj_tree_maple', 'obj_tree_oak'):
        if 1650 <= x <= 1800 and 250 <= yy <= 420: r = remove_inst(r, n, l)
    elif o == 'obj_forest_bush':
        if x < 1792 and x + 64 > 1680 and yy < 352 + 10 and yy + 54 > 256 - 10: r = remove_inst(r, n, l)
btn, bline = tpl_of(r, 'obj_forest_blocker')
new_blocks += [(1696, 224, 1792, 256), (1696, 352, 1792, 384)]
for i, (x1, y1, x2, y2) in enumerate(new_blocks):
    r = add_inst(r, 'rm_forest_entrance', bline, btn, f'inst_MYS_B{i}', 'obj_forest_blocker', x1, y1, (x2 - x1) / 32, (y2 - y1) / 32)
r = add_inst(r, 'rm_forest_entrance', bline, btn, 'inst_MYS_GATE', 'obj_cave_gate', 1728, 256, 1.0, 3.0)
r = add_inst(r, 'rm_forest_entrance', bline, btn, 'inst_MYS_DOOR', 'obj_forest_to_mystic', 0, 0)
open(FF, 'w').write(r)

# ---------- тайный лес ----------
m = orig.replace('rm_forest_entrance', 'rm_mystic_forest').replace('"inst_', '"inst_MF_')
m = m.replace('"tilesetId":{"name":"tls_forest","path":"tilesets/tls_forest/tls_forest.yy",}', '"tilesetId":{"name":"tls_mystic","path":"tilesets/tls_mystic/tls_mystic.yy",}')
assert 'tls_mystic' in m
DROP = ('obj_forest_controller', 'obj_forest_big_stone', 'obj_forest_frog', 'obj_cave_rocks', 'obj_cave_split_stone',
        'obj_cave_entrance_door', 'obj_cave_gate')
blocks = []
for n, l in inst_lines(m):
    o, sx, sy, x, yy = inst_info(l)
    if o in DROP:
        m = remove_inst(m, n, l); continue
    if o == 'obj_forest_blocker' and n.startswith('inst_MF_CAVE_'):
        m = remove_inst(m, n, l); continue
    if o == 'obj_forest_blocker': blocks.append((x, yy, x + 32 * sx, yy + 32 * sy))
    if o in ('obj_tree_pine', 'obj_tree_maple', 'obj_tree_oak', 'obj_forest_bush', 'obj_grass', 'obj_flower', 'obj_flower2', 'obj_flower3') and 1420 <= x <= 1620 and 90 <= yy <= 215:
        m = remove_inst(m, n, l); continue                               # место под скалы со входом
    if o in ('obj_tree_maple', 'obj_tree_oak'):
        m = m.replace(l, l.replace(f'"objectId":{{"name":"{o}","path":"objects/{o}/{o}.yy",}}', '"objectId":{"name":"obj_tree_pine","path":"objects/obj_tree_pine/obj_tree_pine.yy",}'), 1)
    if o == 'obj_forest_exit':
        m = m.replace(l, l.replace('"objectId":{"name":"obj_forest_exit","path":"objects/obj_forest_exit/obj_forest_exit.yy",}', '"objectId":{"name":"obj_mystic_exit","path":"objects/obj_mystic_exit/obj_mystic_exit.yy",}'), 1)
for o in DROP + ('obj_tree_maple', 'obj_tree_oak', 'obj_forest_exit'):
    assert f'"objectId":{{"name":"{o}"' not in m, o
tn, tl = tpl_of(m, 'obj_tree_pine'); bn, bl = tpl_of(m, 'obj_forest_blocker')
# больше кустов — внутри непроходимых зон (густой лес у края тропы)
k = 0
for _ in range(400):
    if k >= 55: break
    b = random.choice(blocks)
    if b[2] - b[0] < 64 or b[3] - b[1] < 40: continue
    x = random.uniform(b[0], b[2] - 64); yy = random.uniform(b[1] - 20, b[3] - 54)
    if 1400 <= x <= 1640 and yy < 230: continue
    m = add_inst(m, 'rm_mystic_forest', tl, tn, f'inst_MF_XB{k}', 'obj_forest_bush', round(x), round(yy)); k += 1
# контроллер, лягушонок, вход в пещеру
CX, CY = 1520, 196
m = add_inst(m, 'rm_mystic_forest', bl, bn, 'inst_MF_CTRL', 'obj_mystic_forest', 0, 0)
m = add_inst(m, 'rm_mystic_forest', tl, tn, 'inst_MF_FROG', 'obj_mystic_frog', 900, 520)
m = add_inst(m, 'rm_mystic_forest', tl, tn, 'inst_MF_ROCKS', 'obj_cave_rocks', CX, CY)
m = add_inst(m, 'rm_mystic_forest', tl, tn, 'inst_MF_STONE', 'obj_cave_split_stone', CX - 124, CY + 9)
m = add_inst(m, 'rm_mystic_forest', bl, bn, 'inst_MF_CDOOR', 'obj_cave_entrance_door', CX, CY)
for nm, x1, y1, x2, y2 in [('inst_MF_RWL', CX - 82, CY - 30, CX - 13, CY), ('inst_MF_RWR', CX + 14, CY - 30, CX + 84, CY),
                           ('inst_MF_RTOP', CX - 82, CY - 100, CX + 84, CY - 46), ('inst_MF_STB', CX - 124, CY + 26, CX - 80, CY + 40)]:
    m = add_inst(m, 'rm_mystic_forest', bl, bn, nm, 'obj_forest_blocker', x1, y1, (x2 - x1) / 32, (y2 - y1) / 32)
os.makedirs(f'{P}/rooms/rm_mystic_forest')
open(f'{P}/rooms/rm_mystic_forest/rm_mystic_forest.yy', 'w').write(m)
cc = open(f'{P}/rooms/rm_forest_entrance/RoomCreationCode.gml').read()
cc = cc.replace('// rm_forest_entrance — Creation Code\n// Опушка Таинственного леса: вход из деревни слева -> тропа -> развилка (тупик вверх, к камню направо) -> поляна.',
                '// rm_mystic_forest — Creation Code\n// Тайный лес: вход слева (с поляны лягушонка) -> тропа -> развилка (лягушонок с сиропом) -> поляна -> скалы со входом в пещеру.')
assert 'rm_mystic_forest' in cc
open(f'{P}/rooms/rm_mystic_forest/RoomCreationCode.gml', 'w').write(cc)
y = open(f'{P}/max_farm_demo.yyp').read()
a = '    {"id":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},'
assert a in y; y = y.replace(a, '    {"id":{"name":"rm_mystic_forest","path":"rooms/rm_mystic_forest/rm_mystic_forest.yy",},},\n' + a, 1)
a = '    {"roomId":{"name":"rm_cave","path":"rooms/rm_cave/rm_cave.yy",},},'
assert a in y; y = y.replace(a, '    {"roomId":{"name":"rm_mystic_forest","path":"rooms/rm_mystic_forest/rm_mystic_forest.yy",},},\n' + a, 1)
open(f'{P}/max_farm_demo.yyp', 'w').write(y)
print('ok, кустов добавлено:', k, 'стенок на опушке пересобрано:', len(new_blocks))
