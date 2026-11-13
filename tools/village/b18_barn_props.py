# Партия 18: предметы сарая из art_incoming/barn/barn_props_v1.png -> спрайты spr_barn_* и объекты obj_barn_*.
# В комнату не ставятся (расстановка отдельно). Фон листа ровный (250,204,176): прозрачны крупные области цвета фона
# (снаружи и между ножками) и кайма вокруг них. Все предметы — ОДНИМ масштабом SCALE=0.25 (бочка ~ рост Макс без головы,
# табурет и скамья как стулья в пекарне). Слипшиеся на листе мешки и сено режутся по самым узким столбцам.
# Предметы на полу: начало низ-центр, маска — нижняя полоса, obj_solid, depth = -bbox_bottom.
# Настенные (полки, крючки, верёвка) и коврик: начало слева сверху, без столкновений.
# Запуск: python3 tools/village/b18_barn_props.py max_farm_demo PREVIEW_DIR
import sys,os,re
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P,OUT=sys.argv[1:3]
SHEET=os.path.join(os.path.dirname(os.path.abspath(__file__)),'../../art_incoming/barn/barn_props_v1.png')
SCALE=0.25; COLORS=28; TOL=12; BG=np.array([250,204,176])
SPR_FOLDER=('Room_barn_inside','folders/Sprites/Room_barn_inside.yy')
OBJ_FOLDER=('room_barn_inside','folders/Objects/room_barn_inside.yy')
DEPTH='// глубина по низу маски, как у Макса — он заходит за верх предмета\ndepth = -bbox_bottom;\n'

# имя: (x0,y0,x1,y1 на листе, вид, доля маски)   вид: floor — на полу, wall — на стене/плоский
ITEMS={
 'chest_seeds':((60,40,350,305),'floor',0.4),   'shelf_jars':((378,25,698,305),'floor',0.3),
 'wall_shelf':((738,36,1068,292),'wall',0),     'cabinet':((1110,20,1400,305),'floor',0.3),
 'sack_grain':((38,305,225,507),'floor',0.4),   'sack_corn':((225,305,392,507),'floor',0.4),
 'sack_small':((392,305,535,507),'floor',0.4),  'crate_veggies':((550,312,786,495),'floor',0.45),
 'crate_potatoes':((788,332,986,496),'floor',0.45),'hay_bale':((1004,320,1217,502),'floor',0.45),
 'hay_roll':((1217,320,1410,502),'floor',0.45), 'barrel':((55,504,215,679),'floor',0.35),
 'barrel_small':((231,551,352,677),'floor',0.4),'milk_can':((382,511,520,680),'floor',0.35),
 'bench':((534,541,838,673),'floor',0.4),       'stool':((852,551,976,670),'floor',0.4),
 'crate_hay':((994,522,1198,671),'floor',0.45), 'wagon_wheel':((1213,507,1391,679),'floor',0.3),
 'tool_rack':((70,686,320,895),'wall',0),       'potting_shelf':((355,675,650,884),'floor',0.3),
 'crate':((701,704,911,868),'floor',0.45),      'rope':((945,696,1045,864),'wall',0),
 'lantern':((1078,697,1184,854),'floor',0.3),   'basket':((1211,697,1384,864),'floor',0.4),
 'rug':((54,890,521,1076),'wall',0),            'ladder':((539,880,722,1074),'floor',0.25),
 'crates_stack':((762,890,1025,1058),'floor',0.45),'sack_pile':((1062,876,1388,1060),'floor',0.4),
}
a=np.asarray(Image.open(SHEET).convert('RGB')).astype(float)
d=np.abs(a-BG).sum(2)
bl,_=ndimage.label(d<=TOL); sz=np.bincount(bl.ravel()); fg=~((sz[bl]>=150)&(bl>0))
lum=lambda c:c@np.array([.299,.587,.114]); dark=lum(a)<lum(BG)-2
for _ in range(3): fg&=~(ndimage.binary_dilation(~fg)&(((d<90)&dark)|(d<45)))

def sprite_from(box):
    x0,y0,x1,y1=box; sub=fg[y0:y1,x0:x1].copy()
    lab,n=ndimage.label(sub); s=np.bincount(lab.ravel())
    keep=np.zeros_like(sub)
    for i in range(1,n+1):
        if s[i]>=40: keep|=lab==i                       # мелкие крошки (зёрна кукурузы) оставляем, шум — нет
    rgba=np.dstack([a[y0:y1,x0:x1],keep*255]).astype(np.float32); A_=rgba[...,3]/255
    w,h=x1-x0,y1-y0; tw,th=max(1,round(w*SCALE)),max(1,round(h*SCALE))
    box_=lambda ch:np.asarray(Image.fromarray(np.ascontiguousarray(ch,dtype=np.float32),'F').resize((tw,th),Image.BOX))
    al=box_(A_)*255; rgb=np.dstack([box_(rgba[...,c]*A_) for c in range(3)])/np.maximum(box_(A_),1e-6)[...,None]
    op=al>=90
    q=Image.fromarray(np.clip(rgb,0,255).astype(np.uint8)).quantize(COLORS,method=Image.MEDIANCUT).convert('RGB')
    out=np.dstack([np.asarray(q),op*255]).astype(np.uint8)
    ys,xs=np.nonzero(op); return out[ys.min():ys.max()+1,xs.min():xs.max()+1]

os.makedirs(OUT,exist_ok=True)
yyp=f'{P}/max_farm_demo.yyp'; s=open(yyp).read()
if f'"{SPR_FOLDER[1]}"' not in s:
    a_='    {"$GMFolder":"","%Name":"Room_hall_furniture","folderPath":"folders/Sprites/Room_hall_furniture.yy","name":"Room_hall_furniture","resourceType":"GMFolder","resourceVersion":"2.0",},'
    assert a_ in s
    s=s.replace(a_,a_+'\n'+a_.replace('Room_hall_furniture',SPR_FOLDER[0])); open(yyp,'w').write(s)
names=[]
for name,(box,kind,part) in ITEMS.items():
    img=sprite_from(box); Image.fromarray(img).save(f'{OUT}/{name}.png')
    h,w=img.shape[:2]; rows=[[tuple(int(c) for c in px) for px in r] for r in img]
    spr,obj='spr_barn_'+name,'obj_barn_'+name
    if kind=='floor': org,bb=(w//2,h),(1,h-max(5,round(h*part)),w-2,h-1)
    else: org,bb=(0,0),gm_res.opaque(rows)
    gm_res.sprite(P,spr,rows,org,bb,folder=SPR_FOLDER)
    gm_res.obj(P,obj,spr,'obj_solid' if kind=='floor' else None,
               events={(0,0,'Create_0.gml'):DEPTH} if kind=='floor' else None,solid=kind=='floor')
    of=f'{P}/objects/{obj}/{obj}.yy'; t=open(of).read()
    t=re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"[^"]*",\s*\}',f'"parent":{{\n    "name":"{OBJ_FOLDER[0]}",\n    "path":"{OBJ_FOLDER[1]}",\n  }}',t,count=1)
    open(of,'w').write(t); names+=[spr,obj]
    print(f'{name:15} {w:3} x {h:3}  {kind}')
gm_res.add_to_yyp(P,names)
