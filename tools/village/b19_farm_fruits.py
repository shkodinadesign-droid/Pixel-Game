# Партия 19: яблоки и груши фермы из art_incoming/farm/fruits_v1/fruits_v1.png.
# - Плоды на деревьях: новые spr_apple_on_tree (12 px в высоту) и spr_pear_on_tree (14 px) вместо иконок 24x24,
#   растянутых в комнате/коде (яблоки были 12 px, груши — 27 px из-за image_xscale в коде). Экземпляры: масштаб 1,
#   тот же левый верхний угол; из obj_pear_on_tree убрано растяжение 27/24.
# - Иконки предметов spr_apple_icon / spr_pear_icon (инвентарь, дневник) — новые яблоко и груша в 24x24.
# - Ящики и корзины: spr/obj_farm_crate_apples, _crate_pears, _crate_mixed, _basket_apples, _basket_pears
#   (на полу: начало низ-центр, маска — нижняя полоса, depth = -bbox_bottom). Рядом с яблонями — ящик и корзина яблок,
#   рядом с грушами — ящик и корзина груш. Смешанный ящик создан, но не поставлен.
# Запуск: python3 tools/village/b19_farm_fruits.py max_farm_demo PREVIEW_DIR
import sys,os,re,uuid
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P,OUT=sys.argv[1:3]
SHEET=os.path.join(os.path.dirname(os.path.abspath(__file__)),'../../art_incoming/farm/fruits_v1/fruits_v1.png')
BG=np.array([253,209,184]); TOL=12; COLORS=64          # много цветов: иначе зелёные листики сливаются с жёлтым
a=np.asarray(Image.open(SHEET).convert('RGB')).astype(float)
d=np.abs(a-BG).sum(2)
bl,_=ndimage.label(d<=TOL); sz=np.bincount(bl.ravel()); fg=~((sz[bl]>=150)&(bl>0))
lum=lambda c:c@np.array([.299,.587,.114]); dark=lum(a)<lum(BG)-2
for _ in range(3): fg&=~(ndimage.binary_dilation(~fg)&(((d<90)&dark)|(d<45)))

BOX={'apple':(90,124,260,314),'pear':(86,436,264,661),'basket_apples':(696,75,969,332),'basket_pears':(688,392,972,672),
     'crate_apples':(1026,52,1375,330),'crate_pears':(1026,389,1381,674),'crate_mixed':(259,715,632,1006)}
def cut(name,fit_h=None,fit_w=None,colors=COLORS):
    x0,y0,x1,y1=BOX[name]; sub=fg[y0:y1,x0:x1]
    lab,n=ndimage.label(sub); s=np.bincount(lab.ravel()); keep=np.zeros_like(sub)
    for i in range(1,n+1):
        if s[i]>=300: keep|=lab==i
    ys,xs=np.nonzero(keep); x0,x1,y0,y1=x0+xs.min(),x0+xs.max()+1,y0+ys.min(),y0+ys.max()+1
    keep=keep[ys.min():ys.max()+1,xs.min():xs.max()+1]; w,h=x1-x0,y1-y0
    sc=(fit_h/h) if fit_h else (fit_w/w); tw,th=max(1,round(w*sc)),max(1,round(h*sc))
    rgba=np.dstack([a[y0:y1,x0:x1],keep*255]).astype(np.float32); A_=rgba[...,3]/255
    box_=lambda ch:np.asarray(Image.fromarray(np.ascontiguousarray(ch,dtype=np.float32),'F').resize((tw,th),Image.BOX))
    al=box_(A_)*255; rgb=np.dstack([box_(rgba[...,c]*A_) for c in range(3)])/np.maximum(box_(A_),1e-6)[...,None]
    op=al>=100
    q=Image.fromarray(np.clip(rgb,0,255).astype(np.uint8)).quantize(colors,method=Image.MEDIANCUT).convert('RGB')
    out=np.dstack([np.asarray(q),op*255]).astype(np.uint8)
    ys,xs=np.nonzero(op); out=out[ys.min():ys.max()+1,xs.min():xs.max()+1]
    Image.fromarray(out).save(f'{OUT}/{name}_{out.shape[1]}x{out.shape[0]}.png'); return out
rows=lambda img:[[tuple(int(c) for c in px) for px in r] for r in img]
os.makedirs(OUT,exist_ok=True)

def write_sprite(spr,img,org=(0,0)):
    h,w=img.shape[:2]; dd=f'{P}/sprites/{spr}'; yf=f'{dd}/{spr}.yy'; t=open(yf).read()
    for k,v in [('bboxMode',0),('bbox_left',0),('bbox_right',w-1),('bbox_top',0),('bbox_bottom',h-1),('width',w),('height',h),
                ('origin',0 if org==(0,0) else 9),('xorigin',org[0]),('yorigin',org[1])]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(spr,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t); open(yf,'w').write(t)
    for root,_,fs in os.walk(dd):
        for f in fs:
            if f.endswith('.png'): png.write(os.path.join(root,f),w,h,rows(img))

FARM_SPR=('Room farm','folders/Sprites/Room farm.yy'); FARM_OBJ=('farm_main_room','folders/Objects/farm_main_room.yy')
new=[]
# --- плоды на деревьях ---
for kind,hgt in [('apple',12),('pear',14)]:
    img=cut(kind,fit_h=hgt,colors=40); spr=f'spr_{kind}_on_tree'
    gm_res.sprite(P,spr,rows(img),(0,0),gm_res.opaque(rows(img)),folder=FARM_SPR); new.append(spr)
    of=f'{P}/objects/obj_{kind}_on_tree/obj_{kind}_on_tree.yy'; t=open(of).read()
    t,n=re.subn(r'"spriteId":\{\s*"name":"spr_'+kind+r'_icon",\s*"path":"sprites/spr_'+kind+r'_icon/spr_'+kind+r'_icon.yy",\s*\}',
                f'"spriteId":{{\n    "name":"{spr}",\n    "path":"sprites/{spr}/{spr}.yy",\n  }}',t); assert n==1,kind
    open(of,'w').write(t)
st=f'{P}/objects/obj_pear_on_tree/Step_0.gml'; t=open(st).read()
t2=t.replace('    image_xscale = 27/24;\n    image_yscale = 27/24;\n',''); assert t2!=t; open(st,'w').write(t2)
rf=f'{P}/rooms/rm_farm/rm_farm.yy'; r=open(rf).read()
r,n=re.subn(r'("objectId":\{"name":"obj_(?:apple|pear)_on_tree"[^}]*\}[^\n]*?"scaleX":)[-\d.]+(,"scaleY":)[-\d.]+',r'\g<1>1.0\g<2>1.0',r)
print('плодов на деревьях:',n)

# --- иконки 24x24 ---
for kind in ('apple','pear'):
    img=cut(kind,fit_h=22,colors=48); h,w=img.shape[:2]; c=np.zeros((24,24,4),np.uint8)
    ox,oy=(24-w)//2,24-h-1; c[oy:oy+h,ox:ox+w]=img; write_sprite(f'spr_{kind}_icon',c)

# --- ящики и корзины ---
SIZES={'crate_apples':52,'crate_pears':52,'crate_mixed':52,'basket_apples':36,'basket_pears':36}
for name,wd in SIZES.items():
    img=cut(name,fit_w=wd); h,w=img.shape[:2]; spr,obj='spr_farm_'+name,'obj_farm_'+name
    gm_res.sprite(P,spr,rows(img),(w//2,h),(1,h-max(6,round(h*0.45)),w-2,h-1),folder=FARM_SPR)
    gm_res.obj(P,obj,spr,'obj_solid',events={(0,0,'Create_0.gml'):'// глубина по низу маски, как у Макса\ndepth = -bbox_bottom;\n'},solid=True)
    of=f'{P}/objects/{obj}/{obj}.yy'; t=open(of).read()
    t=re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"[^"]*",\s*\}',f'"parent":{{\n    "name":"{FARM_OBJ[0]}",\n    "path":"{FARM_OBJ[1]}",\n  }}',t,count=1)
    open(of,'w').write(t); new+=[spr,obj]; print(name,w,'x',h)
gm_res.add_to_yyp(P,new)

# расстановка: между яблонями (640,544)/(844,534) и между грушами (1023,546)/(1183,546) — низ по центру
PLACE=[('crate_apples',730,566),('basket_apples',774,570),('crate_pears',1094,574),('basket_pears',1136,578)]
m=re.search(r'\n(\s*)\{"\$GMRInstance":"v4","%Name":"(inst_\w+)"[^\n]*"objectId":\{"name":"obj_tree_apple"[^\n]*\n',r); line=m.group(0)
add=''; order=''
for name,x,y in PLACE:
    obj='obj_farm_'+name; nm='inst_'+uuid.uuid4().hex[:8].upper()
    l=line.replace(m.group(2),nm).replace('"name":"obj_tree_apple","path":"objects/obj_tree_apple/obj_tree_apple.yy"',f'"name":"{obj}","path":"objects/{obj}/{obj}.yy"')
    l=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+,"x":[-\d.]+,"y":[-\d.]+',f'"scaleX":1.0,"scaleY":1.0,"x":{x}.0,"y":{y}.0',l)
    add+=l.lstrip('\n'); order+=f'\n    {{"name":"{nm}","path":"rooms/rm_farm/rm_farm.yy",}},'
r=r.replace(line,line+add,1); r=r.replace('"instanceCreationOrder":[','"instanceCreationOrder":['+order,1)
open(rf,'w').write(r); print('ящики поставлены')
