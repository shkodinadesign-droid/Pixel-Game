# Партия 13: новый колодец фермы (spr_well) из art_incoming/farm/houses_v1/well_v1.png.
# Фон картинки — светлая «шахматка» без прозрачности: убирается заливкой от краёв (светлые серые пиксели), тёмный контур её останавливает.
# Ширина как у прежнего (78 px), 32 цвета. Низ по центру на прежнем месте; начало спрайта сдвинуто так, что x,y экземпляра
# не меняются (подсказка и набор воды работают как раньше), маска столкновений — та же область, что у прежнего колодца.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]
w,h,p=png.read(SRC); bg=lambda c:min(c[:3])>=215 and max(c[:3])-min(c[:3])<=12
seen=[[False]*w for _ in range(h)]; st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
for x,y in st: seen[y][x]=True
while st:
    x,y=st.pop()
    for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=nx<w and 0<=ny<h and not seen[ny][nx] and bg(p[ny][nx]): seen[ny][nx]=True; st.append((nx,ny))
part=crop([[(0,0,0,0) if seen[y][x] else p[y][x][:3]+(255,) for x in range(w)] for y in range(h)]); pw,ph=len(part[0]),len(part)
d=f'{P}/sprites/spr_well'; yf=f'{d}/spr_well.yy'; old=yy.load(yf); ow,oh=old['width'],old['height']
img=crop(down(part,pw,ph,ow/pw)); img=[[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in img]
cent=kmeans([c[:3] for r in img for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]; W,H=len(img[0]),len(img)
ox=(ow-W)//2; oy=H-oh                                   # спрайт выше прежнего на oy: начало опускаем на столько же
bb=(old['bbox_left']+ox,old['bbox_top']+oy,min(W-1,old['bbox_right']+ox),H-1)
t=open(yf).read()
for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',W),('height',H),('xorigin',ox),('yorigin',oy)]:
    t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{H}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{W}.0',t); open(yf,'w').write(t)
for fr in old['frames']:
    png.write(f'{d}/{fr["name"]}.png',W,H,img)
    for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',W,H,img)
print('spr_well',ow,'x',oh,'->',W,'x',H,'начало',(ox,oy),'маска',bb)
