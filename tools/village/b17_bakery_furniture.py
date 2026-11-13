# Партия 17: мебель пекарни (rm_bakery) из art_incoming/bakery/bakery_furniture_v1.png.
# Лист повторяет нынешнюю раскладку пекарни, поэтому каждый предмет заменяет картинку своего спрайта:
#   холодильник->spr_fridge, полка+шкафчики+сковородки->spr_shelf, кухонный стол с мойкой->spr_cooking_table,
#   плита->spr_oven, прилавок (кофемашина, витрина, клош)->spr_order_vitrina,
#   стол/левый стул/правый стул из набора->spr_coffee_table/spr_cafe_chair_Left/spr_cafe_chair.
# Фон листа с виньеткой: оценивается гладкой поверхностью (полином по x,y); прозрачны гладкие области недалеко от неё,
# связанные с краем листа или крупные (>=1500 px — между ножками), плюс кайма вокруг.
# Все предметы — ОДНИМ масштабом SCALE (прилавок ~ как прежний по ширине). Начало спрайтов остаётся (0,0),
# экземпляры в комнате получают масштаб 1 и ставятся так, чтобы низ-центр совпал с прежним (у полки — верх-центр),
# маски — те же доли спрайта, что были. Объекты, их код и взаимодействия не меняются.
# Запуск: python3 tools/village/b17_bakery_furniture.py max_farm_demo SHEET PREVIEW_DIR
import sys,os,re
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
P,SHEET,OUT=sys.argv[1:4]
SCALE=0.315; COLORS=28; TOL=16
a=np.asarray(Image.open(SHEET).convert('RGB')).astype(float); H,W,_=a.shape

# --- фон ---
yy,xx=np.mgrid[0:H,0:W]; X=xx/W-.5; Y=yy/H-.5
A=np.stack([np.ones_like(X),X,Y,X*X,Y*Y,X*Y,X**4,Y**4,X*X*Y*Y],-1).reshape(-1,9)
g=ndimage.generic_gradient_magnitude(a.mean(2),ndimage.sobel)
m=(np.abs(a-[160,115,90]).sum(2)<70)&(g<40)
for _ in range(3):
    idx=np.flatnonzero(m.ravel())[::7]
    coef=np.linalg.lstsq(A[idx],a.reshape(-1,3)[idx],rcond=None)[0]
    bg=(A@coef).reshape(H,W,3); d=np.abs(a-bg).sum(2); m=(d<14)&(g<40)
d=np.abs(a-bg).sum(2)
# фон = гладкие области (соседние пиксели почти равны, до виньетки недалеко), связанные с краем листа или крупные
nb=np.max([np.abs(a-np.roll(a,s,ax)).sum(2) for s in (1,-1) for ax in (0,1)],axis=0)
smooth=(nb<9)&(d<45)
bl,_=ndimage.label(smooth|(d<=TOL)); sz=np.bincount(bl.ravel())
edge=np.unique(np.concatenate([bl[0],bl[-1],bl[:,0],bl[:,-1]]))
isbg=np.isin(bl,edge[edge>0])|(sz[bl]>=1500)
fg=~(isbg&(bl>0))
lum=lambda c:c@np.array([.299,.587,.114]); dark=lum(a)<lum(bg)-2
for _ in range(3):                                          # кайма: смесь с фоном по краю
    fg&=~(ndimage.binary_dilation(~fg)&(((d<80)&dark)|(d<36)))

def comp_box(x0,y0,x1,y1):   # маска предметов в прямоугольнике (крупные связные куски)
    sub=fg[y0:y1,x0:x1]; lab,n=ndimage.label(sub); s=np.bincount(lab.ravel()); keep=np.zeros_like(sub)
    for i in range(1,n+1):
        if s[i]>=300: keep|=lab==i
    return keep

def to_sprite(x0,y0,x1,y1,mask):
    rgba=np.dstack([a[y0:y1,x0:x1],mask*255]).astype(np.float32); A_=rgba[...,3]/255
    w,h=x1-x0,y1-y0; tw,th=max(1,round(w*SCALE)),max(1,round(h*SCALE))
    box=lambda ch:np.asarray(Image.fromarray(np.ascontiguousarray(ch,dtype=np.float32),'F').resize((tw,th),Image.BOX))
    al=box(A_)*255; rgb=np.dstack([box(rgba[...,c]*A_) for c in range(3)])/np.maximum(box(A_),1e-6)[...,None]
    op=al>=90
    q=Image.fromarray(np.clip(rgb,0,255).astype(np.uint8)).quantize(COLORS,method=Image.MEDIANCUT).convert('RGB')
    out=np.dstack([np.asarray(q),op*255]).astype(np.uint8)
    ys,xs=np.nonzero(op); return out[ys.min():ys.max()+1,xs.min():xs.max()+1]

def cut(x0,y0,x1,y1): return to_sprite(x0,y0,x1,y1,comp_box(x0,y0,x1,y1))

items={}
items['spr_fridge']=cut(212,28,406,432)
items['spr_shelf']=cut(440,28,1050,242)
items['spr_cooking_table']=cut(452,236,968,466)
items['spr_oven']=cut(1013,236,1219,470)
items['spr_order_vitrina']=cut(240,466,1046,712)
# набор «стул-стол-стул» (первый, x 238..622): режем по самым узким столбцам между стулом и столом
x0,y0,x1,y1=232,720,628,874; sub=comp_box(x0,y0,x1,y1); col=sub.sum(0); w=x1-x0
c1=int(np.argmin(col[int(w*.18):int(w*.30)]))+int(w*.18); c2=int(np.argmin(col[int(w*.70):int(w*.82)]))+int(w*.70)
def part(c_a,c_b):
    msk=np.zeros_like(sub); msk[:,c_a:c_b]=sub[:,c_a:c_b]; return to_sprite(x0,y0,x1,y1,msk)
items['spr_cafe_chair_Left']=part(0,c1); items['spr_coffee_table']=part(c1,c2); items['spr_cafe_chair']=part(c2,w)
# раскладка набора на листе (в игровых px): левый край каждой части относительно левого края стола
set_off={'L':-round((c1-0)*SCALE),'R':round((c2-c1)*SCALE)}

os.makedirs(OUT,exist_ok=True)
for k,v in items.items(): Image.fromarray(v).save(f'{OUT}/{k}.png'); print(k,v.shape[1],'x',v.shape[0])

# --- спрайты ---
old={}
for spr,img in items.items():
    dd=f'{P}/sprites/{spr}'; yf=f'{dd}/{spr}.yy'; t=open(yf).read()
    gv=lambda k:int(re.search(r'"'+k+r'":(-?\d+)',t).group(1))
    ow,oh=gv('width'),gv('height'); obb=(gv('bbox_left'),gv('bbox_top'),gv('bbox_right'),gv('bbox_bottom'))
    if gv('bboxMode')!=2:                                   # автоматическая маска -> по непрозрачному
        obb=(obb[0],obb[1],obb[2],obb[3])
    old[spr]=(ow,oh)
    h,w=img.shape[:2]
    bb=(round(obb[0]/ow*w),round(obb[1]/oh*h),min(w-1,round((obb[2]+1)/ow*w)-1),h-1)
    for k,v in [('bboxMode',2),('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),
                ('width',w),('height',h),('origin',0),('xorigin',0),('yorigin',0)]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(spr,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    open(yf,'w').write(t)
    rows=[[tuple(int(c) for c in px) for px in r] for r in img]
    for root,_,fs in os.walk(dd):
        for f in fs:
            if f.endswith('.png'): png.write(os.path.join(root,f),w,h,rows)

# --- комната: масштаб 1, тот же низ-центр (у полки на стене — верх-центр) ---
SPR={'obj_fridge':'spr_fridge','obj_shelf':'spr_shelf','obj_cooking_table':'spr_cooking_table','obj_oven1':'spr_oven',
     'obj_order_vitrina':'spr_order_vitrina','obj_coffee_table':'spr_coffee_table','obj_cafe_chair':'spr_cafe_chair',
     'obj_cafe_chair_Left':'spr_cafe_chair_Left'}
rf=f'{P}/rooms/rm_bakery/rm_bakery.yy'; r=open(rf).read()
pat=re.compile(r'("objectId":\{"name":"(\w+)"[^}]*\},"properties":\[\],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":[-\d.]+,"scaleX":)([-\d.]+)(,"scaleY":)([-\d.]+)(,"x":)([-\d.]+)(,"y":)([-\d.]+)')
tables=[]
def place(mo):
    o=mo.group(2)
    if o not in SPR: return mo.group(0)
    spr=SPR[o]; ow,oh=old[spr]; nh,nw=items[spr].shape[:2]
    sx,sy,x,y=float(mo.group(3)),float(mo.group(5)),float(mo.group(7)),float(mo.group(9))
    cx=x+ow*sx/2
    if o=='obj_shelf': ny=y
    else: ny=y+oh*sy-nh
    nx=round(cx-nw/2)
    if o=='obj_coffee_table': tables.append((nx,round(ny+nh)))
    return mo.group(1)+'1.0'+mo.group(4)+'1.0'+mo.group(6)+f'{nx}.0'+mo.group(8)+f'{round(ny)}.0'
r=pat.sub(place,r)
# стулья: к ближайшему столу, как в наборе на листе (низ стула = низ стола)
th=items['spr_coffee_table'].shape[0]
def chair(mo):
    o=mo.group(2)
    if o not in ('obj_cafe_chair','obj_cafe_chair_Left'): return mo.group(0)
    x,y=float(mo.group(7)),float(mo.group(9))
    tx,tb=min(tables,key=lambda t:abs(t[0]-x)+abs(t[1]-(y+items[SPR[o]].shape[0]))*2)
    ch=items[SPR[o]].shape[0]
    nx=tx+(set_off['L'] if o=='obj_cafe_chair_Left' else set_off['R'])
    return mo.group(1)+'1.0'+mo.group(4)+'1.0'+mo.group(6)+f'{nx}.0'+mo.group(8)+f'{tb-ch}.0'
r=pat.sub(chair,r)
open(rf,'w').write(r); print('столы (левый край, низ):',tables,'смещения стульев',set_off)
