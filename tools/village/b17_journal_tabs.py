# Дневник v2: вкладки = фон вкладок из архива (active/inactive 50x48) + иконки с утверждённой картинки
# (REFERENCE_APPROVED_ORIGINAL_1672x941.png). Иконка вырезается из вкладки референса (всё, что отличается от заливки
# вкладки), уменьшается до ~26 px (чтобы влезала и в низкую неактивную вкладку), 8 цветов, и ставится на место иконки архива (по центру её рамки).
import sys,os
from collections import Counter
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
from b06_nature_convert import down,kmeans,crop
R,OUT=sys.argv[1],sys.argv[2]
TABS=['quests','inventory','recipes','plants','adventures','friendship','money']
CX=[177,290,405,520,635,750,862]          # центры вкладок на референсе (полный масштаб)
w,h,ref=png.read(f'{R}/REFERENCE_APPROVED_ORIGINAL_1672x941.png')
dist=lambda a,b:sum((a[i]-b[i])**2 for i in range(3))
os.makedirs(OUT,exist_ok=True)
for t,cx in zip(TABS,CX):
    box=[r[cx-34:cx+34] for r in ref[26:92]]
    fill=Counter(c[:3] for r in box for c in r).most_common(1)[0][0]
    ic=[[c[:3]+(255,) if dist(c,fill)>900 else (0,0,0,0) for c in r] for r in box]
    ic=crop(ic); iw,ih=len(ic[0]),len(ic)
    sm=down(ic,iw,ih,0.42); sm=crop([[c[:3]+(255,) if c[3]>=110 else (0,0,0,0) for c in r] for r in sm])
    cent=kmeans([c[:3] for r in sm for c in r if c[3]],8); near=lambda px:min(cent,key=lambda c:dist(c,px))
    sm=[[near(c)+(255,) if c[3] else c for c in r] for r in sm]; sw,sh=len(sm[0]),len(sm)
    for st in ('active','inactive'):
        tw,th,tp=png.read(f'{R}/sprites/tabs/ui_tab_{t}_{st}.png'); tp=[list(r) for r in tp]
        tf=Counter(c[:3] for r in tp for c in r if c[3]).most_common(1)[0][0]
        # рамка иконки архива: не-заливка внутри 8..41
        pts=[(x,y) for y in range(8,42) for x in range(8,42) if tp[y][x][3] and dist(tp[y][x],tf)>300]
        x0=min(p[0] for p in pts);x1=max(p[0] for p in pts);y0=min(p[1] for p in pts);y1=max(p[1] for p in pts)
        for x,y in pts: tp[y][x]=tf+(255,)
        ox=(x0+x1+1)//2-sw//2; oy=(y0+y1+1)//2-sh//2
        for y in range(sh):
            for x in range(sw):
                if sm[y][x][3]: tp[oy+y][ox+x]=sm[y][x]
        png.write(f'{OUT}/ui_tab_{t}_{st}.png',tw,th,tp)
    print(t,'иконка',sw,'x',sh)
