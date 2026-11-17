# Входы и выходы «шагом вперёд» (как в Stardew): переход срабатывает, когда ноги Макс в зоне двери и игрок
# идёт в сторону двери (стрелка вверх — в дом, вниз — к выходу, влево/вправо — на краю карты). Кнопка E больше
# не нужна. У каждой двери своя точка появления «перед парной дверью» — Макс выходит там, где вошла.
# Зоны и точки замерены по рендерам комнат (с учётом стен-препятствий у дома, магазина Джошуа и мясной лавки).
import sys,os
P=sys.argv[1]
SCRIPT='''// ===== ДВЕРИ: ВХОД И ВЫХОД ШАГОМ ВПЕРЁД =====
// У объекта-двери в Create: door_init(...). В Step: door_step().
// Зона — прямоугольник в координатах комнаты, в который должны попасть ноги Макс (середина низа маски);
// направление — куда игрок жмёт стрелку; spawn — левый верх Макс в новой комнате (перед парной дверью).

/// @func door_init(_x1, _y1, _x2, _y2, _dir, _room, _spawn_x, _spawn_y, _check)
/// @param _dir    "up" | "down" | "left" | "right"
/// @param _check  функция-условие (true — можно пройти) или undefined
function door_init(_x1, _y1, _x2, _y2, _dir, _room, _spawn_x, _spawn_y, _check = undefined) {
    door_x1 = _x1; door_y1 = _y1; door_x2 = _x2; door_y2 = _y2;
    door_dir = _dir; door_room = _room;
    door_spawn_x = _spawn_x; door_spawn_y = _spawn_y;
    door_check = _check;
    door_armed = false;          // сработает только после того, как Макс зашла в зону (не при появлении в ней)
    visible = false;
}

/// @func door_step()
/// @desc Проверка перехода; true — переход начат
function door_step() {
    if (!instance_exists(obj_max)) return false;
    if (variable_global_exists("control_locked") && global.control_locked) return false;
    var _p  = instance_find(obj_max, 0);
    var _fx = (_p.bbox_left + _p.bbox_right) * 0.5;
    var _fy = _p.bbox_bottom;
    var _in = (_fx >= door_x1 && _fx <= door_x2 && _fy >= door_y1 && _fy <= door_y2);
    if (!_in) { door_armed = true; return false; }
    if (!door_armed) return false;
    var _held = false;
    switch (door_dir) {
        case "up":    _held = keyboard_check(vk_up);    break;
        case "down":  _held = keyboard_check(vk_down);  break;
        case "left":  _held = keyboard_check(vk_left);  break;
        case "right": _held = keyboard_check(vk_right); break;
    }
    if (!_held) return false;
    door_armed = false;                                  // повторно — только после выхода из зоны
    if (!is_undefined(door_check) && !door_check()) return false;
    global.next_spawn_tag = undefined;
    global.next_spawn_x   = door_spawn_x;
    global.next_spawn_y   = door_spawn_y;
    global.spawn_facing   = door_dir;                    // Макс смотрит туда, куда шла
    global.control_locked = true;                        // снимет obj_spawn_controller в новой комнате
    room_goto(door_room);
    return true;
}
'''
os.makedirs(f'{P}/scripts/scr_doors',exist_ok=True)
open(f'{P}/scripts/scr_doors/scr_doors.gml','w').write(SCRIPT)
open(f'{P}/scripts/scr_doors/scr_doors.yy','w').write('{\n  "$GMScript":"v1",\n  "%Name":"scr_doors",\n  "isCompatibility":false,\n  "isDnD":false,\n  "name":"scr_doors",\n  "parent":{\n    "name":"Scripts",\n    "path":"folders/Scripts.yy",\n  },\n  "resourceType":"GMScript",\n  "resourceVersion":"2.0",\n}')
yp=f'{P}/max_farm_demo.yyp'; s=open(yp).read()
if '"scr_doors"' not in s:
    s=s.replace('    {"id":{"name":"scr_sit","path":"scripts/scr_sit/scr_sit.yy",},},','    {"id":{"name":"scr_doors","path":"scripts/scr_doors/scr_doors.yy",},},\n    {"id":{"name":"scr_sit","path":"scripts/scr_sit/scr_sit.yy",},},'); open(yp,'w').write(s)
assert '"scr_doors"' in open(yp).read()
FOREST_CHECK='''function() {
    if (global.magic_map_taken) return true;
    dialog_seq_start([forest_page("max", ["Не хочу заблудиться.", "Сначала нужно узнать дорогу."])], "");
    return false;
}'''
DOORS={ # объект: (x1,y1,x2,y2, направление, комната, spawn x,y, условие, описание)
 'obj_door':                 (452,232,490,262,'up','rm_house_inside',200,423,None,'дверь дома Макс (ферма)'),
 'obj_bakery_entrance':      (930,252,978,282,'up','rm_bakery',290,653,None,'дверь пекарни (ферма)'),
 'obj_door_barn':            (128,212,166,238,'up','room_barn',146,423,None,'дверь сарая (ферма)'),
 'obj_village_entrance':     (1250,280,1280,354,'right','rm_village',40,366,None,'дорога в деревню — правый край фермы'),
 'obj_exit_house':           (150,482,300,540,'down','rm_farm',454,227,None,'выход из дома'),
 'obj_bakery_exit':          (236,712,384,768,'down','rm_farm',938,243,None,'выход из пекарни'),
 'obj_barn_exit':            (96,482,236,540,'down','rm_farm',131,201,None,'выход из сарая'),
 'obj_village_exit':         (0,382,30,442,'left','rm_farm',1214,273,None,'дорога на ферму — левый край деревни'),
 'obj_joshua_shop_entrance': (930,330,978,366,'up','rm_joshua_shop',128,643,None,'дверь магазина Джошуа'),
 'obj_butcher_entrance':     (1360,270,1402,306,'up','rm_butcher_shop',128,643,None,'дверь мясной лавки'),
 'obj_village_forest_gate':  (1570,390,1600,442,'right','rm_forest_entrance','FOREST_SPAWN_X','FOREST_SPAWN_Y',FOREST_CHECK,'лесная тропа — правый край деревни'),
 'obj_joshua_shop_exit':     (32,702,224,768,'down','rm_village',938,331,None,'выход из магазина Джошуа'),
 'obj_butcher_exit':         (32,702,224,768,'down','rm_village',1365,271,None,'выход из мясной лавки'),
 'obj_forest_exit':          (0,788,30,874,'left','rm_village','VILLAGE_FOREST_SPAWN_X','VILLAGE_FOREST_SPAWN_Y',None,'дорога из леса в деревню'),
}
for o,(x1,y1,x2,y2,d,rm,sx,sy,chk,desc) in DOORS.items():
    od=f'{P}/objects/{o}'
    c=f'// ===== {desc.upper()} — переход шагом вперёд ({d}) =====\n// Зона ног Макс и точка появления — см. scr_doors / tools/village/b33_doors.py\n'
    c+=f'door_init({x1}, {y1}, {x2}, {y2}, "{d}", {rm}, {sx}, {sy}'+(f', {chk}' if chk else '')+');\n'
    open(f'{od}/Create_0.gml','w').write(c)
    open(f'{od}/Step_0.gml','w').write(f'// ===== {desc.upper()} (STEP) =====\ndoor_step();\n')
    for f in os.listdir(od):
        if f.startswith('Draw'): open(f'{od}/{f}','w').write('// Подсказок «[E] Войти» больше нет — вход шагом в сторону двери (scr_doors)\n')
    print(o)
# Макс после перехода смотрит туда, куда шла
p=f'{P}/objects/obj_spawn_controller/Other_4.gml'; t=open(p).read()
o='''// После использования спавн-параметры очищаем (чтобы не «тащились» дальше)'''
assert o in t
if 'spawn_facing' not in t:
    t=t.replace(o,'''// Направление взгляда после перехода через дверь (scr_doors)
if (p != noone && variable_global_exists("spawn_facing") && global.spawn_facing != "") {
    with (p) {
        direction_facing = global.spawn_facing;
        switch (global.spawn_facing) {
            case "up":    sprite_index = spr_max_idle_up;    break;
            case "down":  sprite_index = spr_max_idle_down;  break;
            case "left":  sprite_index = spr_max_idle_left;  break;
            case "right": sprite_index = spr_max_idle_right; break;
        }
        image_speed = 0; image_index = 0;
    }
    global.spawn_facing = "";
}

'''+o,1)
    open(p,'w').write(t)
