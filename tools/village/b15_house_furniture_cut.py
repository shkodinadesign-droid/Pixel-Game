# Партия 15: мебель дома Макса из art_incoming/house/furniture_v1/furniture_sheet_v1.png.
# Фон листа — ровный персиковый (247,198,168): прозрачны крупные (>=150 px) области ближе 12 к нему (шум фона <=5, середина ковра ~25) —
# снаружи и между ножками — и кайма вокруг них.
# Предметы находятся как связные области; все переводятся ОДНИМ масштабом SCALE (кровать ~ как прежняя, 46x83),
# усреднением по площади (premultiplied), альфа 0/255, затем своя палитра на каждый спрайт (median cut).
# Выход: OUT/<имя>.png (игровой размер). Запуск: python3 tools/village/b15_house_furniture_cut.py SHEET OUT
import sys,os
import numpy as np
from PIL import Image
from scipy import ndimage
SHEET,OUT=sys.argv[1],sys.argv[2]
SCALE=0.26
BG=np.array([247,198,168]); TOL=12; COLORS=28
# порядок — по положению предмета в листе (x,y верхнего левого угла найденной области)
NAMES={(1079,39):'bed',(168,47):'table_set',(630,80):'sofa',(147,344):'bookshelf',(450,348):'wardrobe',
       (1081,406):'nightstand',(742,456):'chest',(520,692):'window',(145,709):'shelf_cat',(902,744):'rug',
       (125,876):'shelf_books',(683,926):'flower_pot',(535,944):'stool'}
a=np.asarray(Image.open(SHEET).convert('RGB')).astype(int)
if len(sys.argv)>3:                                 # другой лист: SCALE и предметы "x,y:имя;..." из аргументов, фон — самый частый цвет
    SCALE=float(sys.argv[3])
    NAMES={tuple(int(v) for v in k.split(',')):nm for k,nm in (e.split(':') for e in sys.argv[4].split(';'))}
    from collections import Counter
    BG=np.array(Counter(map(tuple,a[::4,::4].reshape(-1,3))).most_common(1)[0][0])
d=np.abs(a-BG).sum(2)
bl,_=ndimage.label(d<=TOL); sz=np.bincount(bl.ravel())   # фон = крупные области цвета фона (снаружи, между ножками);
fg=~((sz[bl]>=150)&(bl>0))                               # мелкие светлые пятна внутри штор/букета остаются
lum=a@np.array([.299,.587,.114]); dark=lum<BG@np.array([.299,.587,.114])-2
for _ in range(3):                                  # кайма: смесь фона с тёмным контуром (темнее фона), до 3 px внутрь;
    fg&=~(ndimage.binary_dilation(~fg)&(((d<90)&dark)|(d<45))) # + светлый ореол (d<45); кремовые (d>60) не трогаются
lab,n=ndimage.label(ndimage.binary_dilation(fg,iterations=4))
os.makedirs(OUT,exist_ok=True)
for i,s in enumerate(ndimage.find_objects(lab)):
    key=(s[1].start,s[0].start)
    name=next((v for k,v in NAMES.items() if abs(k[0]-key[0])<8 and abs(k[1]-key[1])<8),None)
    if name is None: continue
    m=(lab[s]==i+1)&fg[s]
    rgba=np.dstack([a[s],m*255]).astype(np.uint8)
    im=Image.fromarray(rgba,'RGBA')
    W,H=im.size; tw,th=max(1,round(W*SCALE)),max(1,round(H*SCALE))
    pm=np.asarray(im).astype(np.float32); A=pm[...,3]/255
    box=lambda ch:np.asarray(Image.fromarray(np.ascontiguousarray(ch,dtype=np.float32),'F').resize((tw,th),Image.BOX))
    al=box(A)*255; rgb=np.dstack([box(pm[...,c]*A) for c in range(3)])/np.maximum(box(A),1e-6)[...,None]
    op=al>=90                                        # ниже порог — тёмный контур не теряется
    q=Image.fromarray(np.clip(rgb,0,255).astype(np.uint8),'RGB').quantize(COLORS,method=Image.MEDIANCUT).convert('RGB')
    out=np.dstack([np.asarray(q),op*255]).astype(np.uint8)
    ys,xs=np.nonzero(op); out=out[ys.min():ys.max()+1,xs.min():xs.max()+1]
    Image.fromarray(out,'RGBA').save(f'{OUT}/{name}.png'); print(name,out.shape[1],'x',out.shape[0])
