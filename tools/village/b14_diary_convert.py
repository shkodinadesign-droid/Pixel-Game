# Дневник v1: картинка книги (art_incoming/ui/diary_v1/diary_list_v1.png) -> пиксельный спрайт шириной 824 (как прежний spr_diary_bg).
# Белый фон убирается заливкой от краёв, 32 цвета. Пишет PNG в OUT (установка — отдельным шагом).
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
from b06_nature_convert import down,kmeans,crop
SRC,OUT=sys.argv[1],sys.argv[2]
w,h,p=png.read(SRC); bg=lambda c:min(c[:3])>=232
seen=[[False]*w for _ in range(h)]; st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
for x,y in st: seen[y][x]=True
while st:
    x,y=st.pop()
    for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=nx<w and 0<=ny<h and not seen[ny][nx] and bg(p[ny][nx]): seen[ny][nx]=True; st.append((nx,ny))
part=crop([[(0,0,0,0) if seen[y][x] else p[y][x][:3]+(255,) for x in range(w)] for y in range(h)]); pw,ph=len(part[0]),len(part)
img=down(part,pw,ph,824/pw); img=[[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in img]
cent=kmeans([c[:3] for r in img for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]
png.write(OUT,len(img[0]),len(img),img); print('исходник',pw,'x',ph,'->',len(img[0]),'x',len(img))
