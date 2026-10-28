# Чистка спрайта лавки Ивана: альфа 0/255, остатки бочки, серые обрывки, ровный контур крыши.
import sys,os;sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)));import png
w,h,p=png.read(sys.argv[1]); OUT=sys.argv[2]
q=[[tuple(c[:3])+(255,) if c[3]>=128 else (0,0,0,0) for c in row] for row in p]
K=w/192   # координаты зон заданы для версии 192 px, для 224 — масштабируются
S=lambda v:int(round(v*K))
def clr(x0,x1,y0,y1,cond=lambda c:True):
    for y in range(y0,y1):
        for x in range(x0,x1):
            if q[y][x][3] and cond(q[y][x]): q[y][x]=(0,0,0,0)
green=lambda c:c[1]>c[0]+10 and c[1]>c[2]
gray=lambda c:max(c[:3])-min(c[:3])<40 and sum(c[:3])>300
# остатки бочки слева от ящика с цветами
clr(0,S(16),S(128),h)
clr(S(16),S(21),S(134),S(162),lambda c:not green(c))
# серые блики-обрывки на коньке и у трубы
clr(S(70),S(84),0,S(8),gray); clr(S(116),S(126),S(10),S(20),gray)
# светло-серый остаток фона внутри кронштейна вывески
clr(S(150),w,S(70),S(112),lambda c:max(c[:3])-min(c[:3])<50 and sum(c[:3])>260)
# мелкие оторванные кусочки
seen=set()
for y in range(h):
    for x in range(w):
        if q[y][x][3] and (x,y) not in seen:
            comp=[(x,y)];seen.add((x,y));i=0
            while i<len(comp):
                cx,cy=comp[i];i+=1
                for dx,dy in((1,0),(-1,0),(0,1),(0,-1)):
                    nx,ny=cx+dx,cy+dy
                    if 0<=nx<w and 0<=ny<h and q[ny][nx][3] and (nx,ny) not in seen: seen.add((nx,ny));comp.append((nx,ny))
            if len(comp)<12:
                for cx,cy in comp: q[cy][cx]=(0,0,0,0)
# ровный контур крыши: краевые пиксели черепицы (выше стен) — тёмно-коричневые из палитры крыши
roof=[q[y][x] for y in range(0,S(60)) for x in range(w) if q[y][x][3] and q[y][x][0]>q[y][x][2]+30]
dark=sorted(roof,key=lambda c:sum(c[:3]))[len(roof)//40]
print('контур',dark)
edge=[]
for y in range(0,S(62)):
    for x in range(w):
        c=q[y][x]
        if not c[3] or not c[0]>c[2]+15: continue
        if any(not(0<=x+dx<w and 0<=y+dy<h) or not q[y+dy][x+dx][3] for dx,dy in((1,0),(-1,0),(0,-1))): edge.append((x,y))
for x,y in edge: q[y][x]=dark
png.write(OUT,w,h,q)
