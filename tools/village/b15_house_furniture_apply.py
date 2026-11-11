# Партия 15 (2): мебель дома Макса в проект. Вход — папка с PNG из b15_house_furniture_cut.py.
# Заменяет спрайты существующих объектов (имена ресурсов и кадров те же, меняются размер/начало/маска),
# создаёт новые спрайты+объекты и расставляет комнату rm_house_inside.
# Мебель на полу: начало — низ по центру, маска — нижняя полоса (за верх можно зайти), depth = -bbox_bottom (как у Макса).
# Настенное (окно, полки) и ковёр: начало в левом верхнем углу, без столкновений, глубина слоя.
# Запуск: python3 tools/village/b15_house_furniture_apply.py max_farm_demo OUT
import sys,os,re,glob,uuid
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P,SRC=sys.argv[1],sys.argv[2]
SPR_FOLDER=('Room_hall_furniture','folders/Sprites/Room_hall_furniture.yy')
OBJ_FOLDER=('room_house_max','folders/Objects/room_house_max.yy')
DEPTH='// глубина по низу маски, как у Макса — он заходит за верх мебели\ndepth = -bbox_bottom;\n'

def load(n): w,h,img=png.read(f'{SRC}/{n}.png'); return img,w,h
def floor_geom(w,h,part):   # начало низ-центр, маска — нижняя доля высоты
    return (w//2,h),(1,h-max(6,round(h*part)),w-2,h-1)

def replace(spr,src,floor,part=0.35):
    img,w,h=load(src); d=f'{P}/sprites/{spr}'; yf=f'{d}/{spr}.yy'; t=open(yf).read()
    if floor: org,bb=floor_geom(w,h,part); mode=2; okind=9
    else: org=(0,0); bb=gm_res.opaque(img); mode=0; okind=0
    for k,v in [('bboxMode',mode),('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),
                ('width',w),('height',h),('origin',okind),('xorigin',org[0]),('yorigin',org[1])]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(spr,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    open(yf,'w').write(t)
    pngs=[f for f in glob.glob(f'{d}/*.png')]+glob.glob(f'{d}/layers/*/*.png'); assert len(pngs)==2,spr
    for f in pngs: png.write(f,w,h,img)
    print('замена',spr,'<-',src,w,'x',h)

def new(name,src,floor,part=0.35):
    img,w,h=load(src); spr='spr_house_'+name; obj='obj_house_'+name
    if floor: org,bb=floor_geom(w,h,part)
    else: org,bb=(0,0),gm_res.opaque(img)
    gm_res.sprite(P,spr,img,org,bb,folder=SPR_FOLDER)
    gm_res.obj(P,obj,spr,'obj_solid' if floor else None,events={(0,0,'Create_0.gml'):DEPTH} if floor else None,solid=floor)
    t=open(f'{P}/objects/{obj}/{obj}.yy').read()
    t=re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"[^"]*",\s*\}',f'"parent":{{\n    "name":"{OBJ_FOLDER[0]}",\n    "path":"{OBJ_FOLDER[1]}",\n  }}',t,count=1)
    open(f'{P}/objects/{obj}/{obj}.yy','w').write(t)
    gm_res.add_to_yyp(P,[spr,obj]); print('новый',obj,w,'x',h)
    return obj

def add_depth(obj):          # Create с глубиной у прежних объектов мебели
    od=f'{P}/objects/{obj}'; cf=f'{od}/Create_0.gml'
    if os.path.exists(cf):
        c=open(cf).read()
        if 'depth = -bbox_bottom' not in c: open(cf,'w').write(c.rstrip('\n')+'\n\n'+DEPTH)
        return
    open(cf,'w').write(DEPTH); y=open(f'{od}/{obj}.yy').read()
    ev=gm_res.EV.format(num=0,typ=0)
    y=y.replace('"eventList":[]','"eventList":[\n    '+ev+'\n  ]') if '"eventList":[]' in y else y.replace('"eventList":[','"eventList":[\n    '+ev,1)
    open(f'{od}/{obj}.yy','w').write(y)

# --- замены (объекты и их взаимодействия остаются) ---
replace('Spr_room_hall_bed','bed',True,0.7)
replace('spr_table','table_set',True,0.4)
replace('spr_chair','stool',True,0.4)
replace('spr_closet','bookshelf',True,0.3)     # «сервант — книги бабушки» (E) теперь книжный шкаф
replace('spr_comode','nightstand',True,0.35)
replace('spr_window','window',False)
replace('spr_carpet','rug',False)
for o in ['obj_bed','obj_table','obj_chair','obj_closet','obj_comode']: add_depth(o)

# --- новые ---
NEW={'sofa':new('sofa','sofa',True,0.4),'wardrobe':new('wardrobe','wardrobe',True,0.3),
     'chest':new('chest','chest',True,0.45),'flower_pot':new('flower_pot','flower_pot',True,0.4),
     'shelf_cat':new('shelf_cat','shelf_cat',False),'shelf_books':new('shelf_books','shelf_books',False)}

# --- комната ---
rf=f'{P}/rooms/rm_house_inside/rm_house_inside.yy'; r=open(rf).read()
def move(obj,x,y):
    global r
    r,n=re.subn(r'("objectId":\{"name":"'+obj+r'",[^}]*\},"properties":\[\],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":[\d.]+,"scaleX":)[-\d.]+(,"scaleY":)[-\d.]+(,"x":)[-\d.]+(,"y":)[-\d.]+',
               lambda m:m.group(1)+('-1.0' if obj=='obj_bed' else '1.0')+m.group(2)+'1.0'+m.group(3)+f'{x}.0'+m.group(4)+f'{y}.0',r)
    assert n==1,obj
move('obj_chair',262,224); move('obj_carpet',150,300); move('obj_window',150,96)
tpl=re.search(r'\n(\s*)\{"\$GMRInstance":"v4","%Name":"(inst_\w+)"[^\n]*"objectId":\{"name":"obj_closet"[^\n]*\n',r)
line=tpl.group(0)
for obj,x,y in [(NEW['wardrobe'],418,224),(NEW['flower_pot'],300,224),(NEW['sofa'],204,300),(NEW['chest'],36,340),
                (NEW['shelf_cat'],8,126),(NEW['shelf_books'],240,100)]:
    nm='inst_'+uuid.uuid4().hex[:8].upper()
    l=line.replace(tpl.group(2),nm).replace('obj_closet',obj)
    l=re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{x}.0,"y":{y}.0',l)
    r=r.replace(line,line+l.lstrip('\n'),1); line_end=l
    r=r.replace('"instanceCreationOrder":[\n',f'"instanceCreationOrder":[\n    {{"name":"{nm}","path":"rooms/rm_house_inside/rm_house_inside.yy",}},\n',1)
open(rf,'w').write(r); print('комната обновлена')
