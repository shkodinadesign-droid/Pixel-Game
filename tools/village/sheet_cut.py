# Нарезка листа со сплошным фоном: заливка фона от краёв (с допуском), компоненты, рамки предметов.
import sys,os,json;sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)));import png
SRC,OUT=sys.argv[1],sys.argv[2]; TOL=int(sys.argv[3]) if len(sys.argv)>3 else 40
w,h,p=png.read(SRC)
BG=(225,220,210)
def isbg(c):
    if sum(abs(c[i]-BG[i]) for i in range(3))<TOL and max(c[:3])-min(c[:3])<30: return True
    # мягкие тени под предметами на листе: тёплый серый 176..228, низкая насыщенность (камни темнее, белые цветы светлее)
    a=sum(c[:3])/3
    return 176<=a<=228 and max(c[:3])-min(c[:3])<26 and c[0]>=c[1]>=c[2]
bg=[[False]*w for _ in range(h)]
ALPHA=any(p[y][x][3]<128 for y in range(0,h,16) for x in range(0,w,16))
st=[(x,0) for x in range(w)]+[(x,h-1) for x in range(w)]+[(0,y) for y in range(h)]+[(w-1,y) for y in range(h)]
while st:
    x,y=st.pop()
    if bg[y][x] or not (p[y][x][3]<128 if ALPHA else isbg(p[y][x])): continue
    bg[y][x]=True
    for dx,dy in((1,0),(-1,0),(0,1),(0,-1)):
        nx,ny=x+dx,y+dy
        if 0<=nx<w and 0<=ny<h and not bg[ny][nx]: st.append((nx,ny))
# компоненты на сетке 4px с расширением на 1 клетку
S=4; gw,gh=(w+S-1)//S,(h+S-1)//S
occ=[[any(not bg[y][x] for y in range(gy*S,min(h,gy*S+S)) for x in range(gx*S,min(w,gx*S+S))) for gx in range(gw)] for gy in range(gh)]
lab=[[-1]*gw for _ in range(gh)]; boxes=[]
for gy in range(gh):
    for gx in range(gw):
        if occ[gy][gx] and lab[gy][gx]<0:
            n=len(boxes); st=[(gx,gy)]; lab[gy][gx]=n; b=[gx,gy,gx,gy]; cnt=0
            while st:
                cx,cy=st.pop(); cnt+=1
                b=[min(b[0],cx),min(b[1],cy),max(b[2],cx),max(b[3],cy)]
                for dx in(-2,-1,0,1,2):
                    for dy in(-2,-1,0,1,2):
                        nx,ny=cx+dx,cy+dy
                        if 0<=nx<gw and 0<=ny<gh and occ[ny][nx] and lab[ny][nx]<0: lab[ny][nx]=n; st.append((nx,ny))
            boxes.append((b[0]*S,b[1]*S,min(w,(b[2]+1)*S),min(h,(b[3]+1)*S),cnt))
boxes=[b for b in boxes if b[4]>40]
boxes.sort(key=lambda b:(b[1]//150,b[0]))
for i,b in enumerate(boxes): print(i,b)
# маска фона — в альфу
out=[[(0,0,0,0) if bg[y][x] else tuple(p[y][x][:3])+(255,) for x in range(w)] for y in range(h)]
png.write(OUT+'/cut_rgba.png',w,h,out)
json.dump(boxes,open(OUT+'/boxes.json','w'))
