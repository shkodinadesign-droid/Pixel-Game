# Партия 16: стол и два стула дома Макса (art_incoming/house/furniture_v1/table_chairs_v2.png) + сидячие позы Макс.
# 1) нарезка: b15_house_furniture_cut.py table_chairs_v2.png CUT 0.13 "280,412:chair;534,315:table;970,412:chair_r"
# 2) этот скрипт: spr_table <- table, spr_chair <- chair (вид спереди, на нём сидит Макс),
#    прежняя табуретка (CUT_OLD/stool.png из партии 15) -> новый obj_house_stool,
#    spr_max_sit_down / spr_max_sit_down2 (~/Downloads/max_new_32x48/sit_down, sit2_down — дыхание),
#    комната: стол на месте, стулья слева и справа от него, табуретка — где была.
# Запуск: python3 tools/village/b16_house_table_chairs.py max_farm_demo CUT CUT_OLD SIT_DIR
import sys,os,re,uuid
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P,CUT,OLD,SIT=sys.argv[1:5]
DEPTH='// глубина по низу маски, как у Макса — он заходит за верх мебели\ndepth = -bbox_bottom;\n'

def replace(spr,src,part):
    w,h,img=png.read(src); d=f'{P}/sprites/{spr}'; yf=f'{d}/{spr}.yy'; t=open(yf).read()
    bb=(1,h-max(6,round(h*part)),w-2,h-1)
    for k,v in [('bboxMode',2),('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),
                ('width',w),('height',h),('origin',9),('xorigin',w//2),('yorigin',h)]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(spr,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    open(yf,'w').write(t)
    for root,_,fs in os.walk(d):
        for f in fs:
            if f.endswith('.png'): png.write(os.path.join(root,f),w,h,img)
    print('замена',spr,w,'x',h)

replace('spr_table',f'{CUT}/table.png',0.4)
replace('spr_chair',f'{CUT}/chair.png',0.35)

# табуретка — отдельный объект
w,h,img=png.read(f'{OLD}/stool.png')
gm_res.sprite(P,'spr_house_stool',img,(w//2,h),(1,h-max(6,round(h*0.4)),w-2,h-1),folder=('Room_hall_furniture','folders/Sprites/Room_hall_furniture.yy'))
gm_res.obj(P,'obj_house_stool','spr_house_stool','obj_solid',events={(0,0,'Create_0.gml'):DEPTH},solid=True)
of=f'{P}/objects/obj_house_stool/obj_house_stool.yy'; t=open(of).read()
t=re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"[^"]*",\s*\}','"parent":{\n    "name":"room_house_max",\n    "path":"folders/Objects/room_house_max.yy",\n  }',t,count=1); open(of,'w').write(t)

# сидячие позы Макс (32x48, начало 0,0 и маска ног как у spr_max_idle_down)
for name,f in [('spr_max_sit_down','sit_down.png'),('spr_max_sit_down2','sit2_down.png')]:
    w,h,img=png.read(f'{SIT}/{f}'); assert (w,h)==(32,48),f
    img=[[c if c[3]>=128 else (0,0,0,0) for c in r] for r in img]
    img=[[c[:3]+(255,) if c[3] else c for c in r] for r in img]
    gm_res.sprite(P,name,img,(0,0),(9,43,22,47),folder=('idle','folders/Sprites/characters/Max/idle.yy'))
gm_res.add_to_yyp(P,['spr_house_stool','obj_house_stool','spr_max_sit_down','spr_max_sit_down2'])

# комната
rf=f'{P}/rooms/rm_house_inside/rm_house_inside.yy'; r=open(rf).read()
m=re.search(r'\n(\s*)\{"\$GMRInstance":"v4","%Name":"(inst_\w+)"[^\n]*"objectId":\{"name":"obj_chair"[^\n]*\n',r); line=m.group(0)
TX,TY,GAP=192,224,2
tw=png.read(f'{CUT}/table.png')[0]; cw=png.read(f'{CUT}/chair.png')[0]
off=tw//2+GAP+cw//2
def inst(obj,x,y,mirror=False):
    nm='inst_'+uuid.uuid4().hex[:8].upper()
    l=line.replace(m.group(2),nm).replace('"name":"obj_chair","path":"objects/obj_chair/obj_chair.yy"',f'"name":"{obj}","path":"objects/{obj}/{obj}.yy"')
    l=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+,"x":[-\d.]+,"y":[-\d.]+',f'"scaleX":1.0,"scaleY":1.0,"x":{x}.0,"y":{y}.0',l)
    return nm,l
new=[inst('obj_chair',TX-off,TY),inst('obj_chair',TX+off,TY),inst('obj_house_stool',262,224)]
r=r.replace(line,''.join(l if i==0 else l.lstrip('\n') for i,(_,l) in enumerate(new)),1)   # старый стул заменён тремя
order=f'{{"name":"{m.group(2)}","path":"rooms/rm_house_inside/rm_house_inside.yy",}},'
assert order in r
r=r.replace(order,'\n    '.join(f'{{"name":"{nm}","path":"rooms/rm_house_inside/rm_house_inside.yy",}},' for nm,_ in new),1)
open(rf,'w').write(r); print('стулья x =',TX-off,TX+off,'табуретка 262')
