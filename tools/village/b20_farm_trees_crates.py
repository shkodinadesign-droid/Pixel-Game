# Партия 20: на ферме фруктовые деревья крупнее (Макс была почти с дерево), ящики и корзины с плодами меньше.
# - obj_tree_apple / obj_tree_pear в rm_farm: масштаб экземпляра TREE_K (от основания ствола);
#   плоды obj_apple_on_tree / obj_pear_on_tree сдвигаются вместе с кроной ближайшего дерева (сами плоды — масштаб 1).
# - spr_farm_crate_* / spr_farm_basket_*: перерезаны из листа fruits_v1 меньшей ширины (на месте, низ-центр тот же).
# Запуск: python3 tools/village/b20_farm_trees_crates.py max_farm_demo PREVIEW_DIR
import sys,os,re
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
P,OUT=sys.argv[1:3]; os.makedirs(OUT,exist_ok=True)
TREE_K=1.3
SIZES={'crate_apples':40,'crate_pears':40,'crate_mixed':40,'basket_apples':28,'basket_pears':28}
SHEET=os.path.join(os.path.dirname(os.path.abspath(__file__)),'../../art_incoming/farm/fruits_v1/fruits_v1.png')
BG=np.array([253,209,184]); TOL=12; COLORS=64
a=np.asarray(Image.open(SHEET).convert('RGB')).astype(float); d=np.abs(a-BG).sum(2)
bl,_=ndimage.label(d<=TOL); sz=np.bincount(bl.ravel()); fg=~((sz[bl]>=150)&(bl>0))
lum=lambda c:c@np.array([.299,.587,.114]); dark=lum(a)<lum(BG)-2
for _ in range(3): fg&=~(ndimage.binary_dilation(~fg)&(((d<90)&dark)|(d<45)))
BOX={'basket_apples':(696,75,969,332),'basket_pears':(688,392,972,672),
     'crate_apples':(1026,52,1375,330),'crate_pears':(1026,389,1381,674),'crate_mixed':(259,715,632,1006)}
def cut(name,fit_w):
    x0,y0,x1,y1=BOX[name]; sub=fg[y0:y1,x0:x1]
    lab,n=ndimage.label(sub); s=np.bincount(lab.ravel()); keep=np.zeros_like(sub)
    for i in range(1,n+1):
        if s[i]>=300: keep|=lab==i
    ys,xs=np.nonzero(keep); x0,x1,y0,y1=x0+xs.min(),x0+xs.max()+1,y0+ys.min(),y0+ys.max()+1
    keep=keep[ys.min():ys.max()+1,xs.min():xs.max()+1]; w,h=x1-x0,y1-y0
    sc=fit_w/w; tw,th=max(1,round(w*sc)),max(1,round(h*sc))
    rgba=np.dstack([a[y0:y1,x0:x1],keep*255]).astype(np.float32); A_=rgba[...,3]/255
    box_=lambda ch:np.asarray(Image.fromarray(np.ascontiguousarray(ch,dtype=np.float32),'F').resize((tw,th),Image.BOX))
    al=box_(A_)*255; rgb=np.dstack([box_(rgba[...,c]*A_) for c in range(3)])/np.maximum(box_(A_),1e-6)[...,None]
    op=al>=100
    q=Image.fromarray(np.clip(rgb,0,255).astype(np.uint8)).quantize(COLORS,method=Image.MEDIANCUT).convert('RGB')
    out=np.dstack([np.asarray(q),op*255]).astype(np.uint8)
    ys,xs=np.nonzero(op); out=out[ys.min():ys.max()+1,xs.min():xs.max()+1]
    Image.fromarray(out).save(f'{OUT}/{name}.png'); return out
for name,wd in SIZES.items():
    img=cut(name,wd); h,w=img.shape[:2]; spr='spr_farm_'+name; dd=f'{P}/sprites/{spr}'; yf=f'{dd}/{spr}.yy'; t=open(yf).read()
    bb=(1,h-max(5,round(h*0.45)),w-2,h-1)
    for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',w),('height',h),('xorigin',w//2),('yorigin',h)]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(spr,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    t=re.sub(r'("xorigin"|"yorigin")',r'\1',t); open(yf,'w').write(t)
    rows=[[tuple(int(c) for c in px) for px in r] for r in img]
    for root,_,fs in os.walk(dd):
        for f in fs:
            if f.endswith('.png'): png.write(os.path.join(root,f),w,h,rows)
    print(name,w,'x',h)

rf=f'{P}/rooms/rm_farm/rm_farm.yy'; r=open(rf).read()
pat=re.compile(r'("objectId":\{"name":"(\w+)"[^}]*\},"properties":\[\],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":[-\d.]+,"scaleX":)([-\d.]+)(,"scaleY":)([-\d.]+)(,"x":)([-\d.]+)(,"y":)([-\d.]+)')
trees={'apple':[],'pear':[]}
for mo in pat.finditer(r):
    for k in trees:
        if mo.group(2)==f'obj_tree_{k}': trees[k].append((float(mo.group(7)),float(mo.group(9)),float(mo.group(3))))
def fix(mo):
    o=mo.group(2); x,y=float(mo.group(7)),float(mo.group(9))
    for k in trees:
        if o==f'obj_tree_{k}':
            return mo.group(1)+f'{TREE_K}'+mo.group(4)+f'{TREE_K}'+mo.group(6)+mo.group(7)+mo.group(8)+mo.group(9)
        if o==f'obj_{k}_on_tree':
            tx,ty,s0=min(trees[k],key=lambda t:(t[0]-x)**2+(t[1]-y)**2); f=TREE_K/s0
            return mo.group(1)+mo.group(3)+mo.group(4)+mo.group(5)+mo.group(6)+f'{round(tx+(x-tx)*f)}.0'+mo.group(8)+f'{round(ty+(y-ty)*f)}.0'
    return mo.group(0)
r=pat.sub(fix,r); open(rf,'w').write(r); print('деревья',trees)
