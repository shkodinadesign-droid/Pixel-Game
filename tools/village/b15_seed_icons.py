# Иконки мешочков с семенами (art_incoming/ui/seed_bags_v1.png): картофель, клубника, морковь, кофейные зёрна.
# Фон — светлая «шахматка» без прозрачности, убирается заливкой от краёв. Лист режется на 4 рисунка по пустым колонкам,
# каждый уменьшается до высоты 32 и ставится в холст 32x32 (по центру, низ к низу), 16 цветов. Заменяются на месте.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]
NAMES=['spr_potato_seed_icon','spr_strawberry_seed_icon','spr_seed_carrot_icon','spr_cofee_icon']
w,h,p=png.read(SRC); bg=lambda c:min(c[:3])>=215 and max(c[:3])-min(c[:3])<=14
seen=[[False]*w for _ in range(h)]; st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
for x,y in st: seen[y][x]=True
while st:
    x,y=st.pop()
    for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=nx<w and 0<=ny<h and not seen[ny][nx] and bg(p[ny][nx]): seen[ny][nx]=True; st.append((nx,ny))
img=[[(0,0,0,0) if seen[y][x] else p[y][x][:3]+(255,) for x in range(w)] for y in range(h)]
cols=[any(img[y][x][3] for y in range(h)) for x in range(w)]; parts=[];x=0
while x<w:
    if cols[x]:
        x0=x
        while x<w and cols[x]: x+=1
        if x-x0>50: parts.append((x0,x))
    x+=1
assert len(parts)==4,parts
for name,(x0,x1) in zip(NAMES,parts):
    part=crop([r[x0:x1] for r in img]); pw,ph=len(part[0]),len(part)
    s=down(part,pw,ph,32/max(pw,ph)); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],16); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    sw,sh=len(s[0]),len(s); ox=(32-sw)//2; oy=32-sh
    out=[[(0,0,0,0)]*32 for _ in range(32)]
    for y in range(sh):
        for x in range(sw):
            if s[y][x][3]: out[oy+y][ox+x]=near(s[y][x])+(255,)
    d=f'{P}/sprites/{name}'; yf=f'{d}/{name}.yy'; old=yy.load(yf); t=open(yf).read()
    for k,v in [('bbox_left',ox),('bbox_right',ox+sw-1),('bbox_top',oy),('bbox_bottom',31)]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
    open(yf,'w').write(t)
    for fr in old['frames']:
        png.write(f'{d}/{fr["name"]}.png',32,32,out)
        for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',32,32,out)
    print(name,'рисунок',sw,'x',sh)
