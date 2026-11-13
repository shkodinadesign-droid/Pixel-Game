# Партия 18 (2): расстановка предметов сарая в room_barn (пол x 0..608, y 64..540; стена y<64).
# Сундук-хранилище obj_chest (E — открыть) получает картинку сундука с семенами прямо в spr_chest
# (начало 0,0 как было — подсказка и открытие не меняются), стоит на прежнем месте.
# Свободен проход от выхода (x 90..230) к сундуку и зоне сдачи урожая. Остальное — по зонам:
# у задней стены — полки/шкаф/инструменты, справа — сено и бочки, в центре — коврик со скамьёй,
# слева у стены — мешки, внизу справа — ящики с урожаем.
# Запуск: python3 tools/village/b18_barn_layout.py max_farm_demo PREVIEW_DIR (PNG из b18_barn_props.py)
import sys,os,re,uuid
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
P,SRC=sys.argv[1:3]

# сундук
w,h,img=png.read(f'{SRC}/chest_seeds.png'); d=f'{P}/sprites/spr_chest'; yf=f'{d}/spr_chest.yy'; t=open(yf).read()
bb=(1,round(h*0.55),w-2,h-1)
for k,v in [('bboxMode',2),('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',w),('height',h)]:
    t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t); open(yf,'w').write(t)
for root,_,fs in os.walk(d):
    for f in fs:
        if f.endswith('.png'): png.write(os.path.join(root,f),w,h,img)

# (объект, x, y): у предметов на полу x,y — низ по центру; у настенных и коврика — левый верхний угол
PLACE=[
 # на задней стене
 ('tool_rack',220,8),('wall_shelf',470,2),('rope',584,14),
 # у задней стены, на полу (низ y=118)
 ('shelf_jars',300,118),('cabinet',390,118),('lantern',446,112),('potting_shelf',520,118),('ladder',584,118),
 # справа: бочки, сено, колесо
 ('barrel',500,200),('barrel_small',540,196),('milk_can',578,200),
 ('hay_bale',520,270),('hay_roll',576,274),('crate_hay',528,326),('wagon_wheel',584,372),
 # центр: коврик, за ним скамья, табурет, корзина
 ('rug',250,250),('bench',306,254),('stool',382,262),('basket',400,380),
 # слева у стены: мешки
 ('sack_pile',48,232),('sack_grain',30,300),('sack_corn',32,352),('sack_small',30,400),
 # внизу справа: ящики с урожаем
 ('crate_veggies',470,470),('crate_potatoes',530,474),('crate',410,500),('crates_stack',568,512),
]
rf=f'{P}/rooms/room_barn/room_barn.yy'; r=open(rf).read()
m=re.search(r'\n(\s*)\{"\$GMRInstance":"v4","%Name":"(inst_\w+)"[^\n]*"objectId":\{"name":"obj_chest"[^\n]*\n',r); line=m.group(0)
add='';order=''
for name,x,y in PLACE:
    obj='obj_barn_'+name; assert os.path.isdir(f'{P}/objects/{obj}'),obj
    if f'"name":"{obj}"' in r: continue
    nm='inst_'+uuid.uuid4().hex[:8].upper()
    l=line.replace(m.group(2),nm).replace('"name":"obj_chest","path":"objects/obj_chest/obj_chest.yy"',f'"name":"{obj}","path":"objects/{obj}/{obj}.yy"')
    l=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+,"x":[-\d.]+,"y":[-\d.]+',f'"scaleX":1.0,"scaleY":1.0,"x":{x}.0,"y":{y}.0',l)
    add+=l.lstrip('\n'); order+=f'\n    {{"name":"{nm}","path":"rooms/room_barn/room_barn.yy",}},'
r=r.replace(line,line+add,1)
r=r.replace('"instanceCreationOrder":[','"instanceCreationOrder":['+order,1)
open(rf,'w').write(r); print('поставлено',len(PLACE))
