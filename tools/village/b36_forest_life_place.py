# Лес: объекты растений (декор, сквозь мелкие можно ходить; пень и ягодный куст — препятствия у основания),
# ёжик под кустом (сворачивается в клубок, когда Макс подходит) и лисичка (иногда пробегает мимо Макс через экран).
# Растения раскиданы по открытым полянам (наверху и внизу слева) — потом правятся вручную в GameMaker.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import gm_res
P=sys.argv[1]
SOFT=['mushroom_brown','mushroom_white','chanterelle','moss','strawberry']
HARD=['stump_mushrooms','berry_bush']
new=[]
for n in SOFT+HARD:
    o=f'obj_forest_{n}'
    if not os.path.exists(f'{P}/objects/{o}'):
        gm_res.obj(P,o,f'spr_forest_{n}','obj_village_prop_soft' if n in SOFT else 'obj_village_prop',solid=False); new.append(o)
HOG_CREATE='''// ===== ЁЖИК (CREATE) =====
// Сидит под кустиком и принюхивается; когда Макс подходит близко — сворачивается в клубок (кадр 0),
// когда отходит и немного постоит в стороне — разворачивается обратно.
sprite_index = spr_hedgehog;
image_speed  = 0;
image_index  = 2;
state        = "sit";
calm_timer   = 0;
'''
HOG_STEP='''// ===== ЁЖИК (STEP) =====
depth = -y;
var _d = 9999;
if (instance_exists(obj_max)) _d = point_distance(x, y, obj_max.x + 16, obj_max.y + 47);   // до ног Макс
if (state == "sit") {
    image_index = ((current_time div 500) mod 5 == 0) ? 3 : 2;      // изредка шевелит носом
    if (_d < 56) { state = "ball"; image_index = 0; calm_timer = 0; }
} else {
    image_index = 0;
    calm_timer = (_d > 96) ? calm_timer + 1 : 0;
    if (calm_timer > 120) state = "sit";                            // ~2 с без Макс рядом
}
'''
FOX_CREATE='''// ===== ЛИСИЧКА (CREATE) =====
// Невидимый «режиссёр»: время от времени лиса пробегает мимо Макс поперёк экрана и исчезает за краем.
active   = false;
timer    = irandom_range(600, 1200);        // первый раз — через 10-20 с
run_dir  = 1;
visible  = true;
'''
FOX_STEP='''// ===== ЛИСИЧКА (STEP) =====
if (!active) {
    if (!instance_exists(obj_max)) exit;
    if (--timer > 0) exit;
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vw = camera_get_view_width(_cam);
    run_dir = choose(1, -1);
    x = (run_dir > 0) ? _vx - 40 : _vx + _vw + 40;
    y = clamp(obj_max.y + 47 + choose(-90, -70, 70, 90), 40, room_height - 8);   // мимо, не под ногами
    active = true;
    exit;
}
x += run_dir * 5;
depth = -y;
var _cam2 = view_camera[0];
var _vx2 = camera_get_view_x(_cam2), _vw2 = camera_get_view_width(_cam2);
if ((run_dir > 0 && x > _vx2 + _vw2 + 60) || (run_dir < 0 && x < _vx2 - 60)) {
    active = false;
    timer  = irandom_range(1500, 3000);                             // следующий раз через 25-50 с
}
'''
FOX_DRAW='''// ===== ЛИСИЧКА (DRAW) — бег, отражение по направлению =====
if (active) draw_sprite_ext(spr_fox_run, (current_time div 80) mod 4, x, y, run_dir, 1, 0, c_white, 1);
'''
if not os.path.exists(f'{P}/objects/obj_forest_hedgehog'):
    gm_res.obj(P,'obj_forest_hedgehog','spr_hedgehog',None,events={(0,0,'Create_0.gml'):HOG_CREATE,(3,0,'Step_0.gml'):HOG_STEP},solid=False); new.append('obj_forest_hedgehog')
if not os.path.exists(f'{P}/objects/obj_forest_fox'):
    gm_res.obj(P,'obj_forest_fox',None,None,events={(0,0,'Create_0.gml'):FOX_CREATE,(3,0,'Step_0.gml'):FOX_STEP,(8,0,'Draw_0.gml'):FOX_DRAW},solid=False); new.append('obj_forest_fox')
gm_res.add_to_yyp(P,new)
# расстановка (низ по центру): поляна наверху (в конце тупика) — земляника, грибы, пень, мох;
# поляна внизу слева — лисички, шампиньоны, ягодный куст, мох, пень. Ёжик — под кустом у начала дороги.
PLACE=[('strawberry',840,170),('strawberry',880,192),('strawberry',924,166),('strawberry',860,218),('strawberry',906,228),
       ('mushroom_brown',962,122),('mushroom_white',988,150),('stump_mushrooms',952,236),('moss',818,142),('moss',930,108),
       ('chanterelle',360,980),('chanterelle',396,1010),('chanterelle',432,976),('mushroom_white',330,1030),('mushroom_brown',448,1018),
       ('berry_bush',474,1050),('moss',300,1000),('moss',420,1052),('stump_mushrooms',352,1066)]
rp=f'{P}/rooms/rm_forest_entrance/rm_forest_entrance.yy'; t=open(rp).read()
TPL='{"$GMRInstance":"v4","%Name":"NAME","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnD":false,"name":"NAME","objectId":{"name":"OBJ","path":"objects/OBJ/OBJ.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":@X@,"y":@Y@,},'
TPL=TPL.replace('"isDnD":false,"name":"NAME"','"isDnd":false,"name":"NAME"')
def add(layer,name,obj,x,y):
    global t
    if f'"{name}"' in t: return
    line=TPL.replace('NAME',name).replace('OBJ',obj).replace('@X@',f'{float(x)}').replace('@Y@',f'{float(y)}')
    m=re.search(r'\{"\$GMRInstanceLayer":"","%Name":"'+layer+r'",[^\n]*"instances":\[',t); assert m,layer
    t=t[:m.end()]+'\n        '+line+t[m.end():]
    t=t.replace('"instanceCreationOrder":[','"instanceCreationOrder":[\n    {"name":"'+name+'","path":"rooms/rm_forest_entrance/rm_forest_entrance.yy",},',1)
for i,(n,x,y) in enumerate(PLACE): add('Decor',f'inst_FOREST_PLANT_{i:02d}',f'obj_forest_{n}',x,y)
add('Instances','inst_FOREST_HEDGEHOG','obj_forest_hedgehog',304,612)
add('Logic','inst_FOREST_FOX','obj_forest_fox',0,0)
open(rp,'w').write(t); print('новых объектов',len(new),'растений',len(PLACE))
