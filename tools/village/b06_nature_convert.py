# Партия 06: природа деревни (деревья, ели, кусты, трава, цветы) из art_incoming/village/06_nature/v2.
# Исходники нарисованы крупно (~4 px на «пиксель»), поэтому все PNG переводятся в игровой пиксель-арт
# ОДНИМ общим масштабом (пропорции между деревьями, кустами и травой как в листе), без новой стилизации:
# усреднение по площади, альфа 0/255, своя палитра k-means у каждого спрайта, обрезка обрывков соседей.
import sys,os,random
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
SRC,OUT=sys.argv[1],sys.argv[2]
SCALE=96/342          # самое крупное лиственное дерево -> 96 px (2 роста Макс, как в мастер-сцене)
K={'trees':20,'bushes':14,'grass':6,'flowers':8}
def down(p,w,h,f):
    TW,TH=max(1,round(w*f)),max(1,round(h*f)); fx,fy=w/TW,h/TH
    out=[[(0,0,0,0)]*TW for _ in range(TH)]
    for ty in range(TH):
        for tx in range(TW):
            ax,bx=tx*fx,(tx+1)*fx; ay,by=ty*fy,(ty+1)*fy
            R=G=B=A=0.0; tot=0.0
            for yy in range(int(ay),min(h,int(by)+1)):
                wy=min(by,yy+1)-max(ay,yy)
                if wy<=0: continue
                for xx in range(int(ax),min(w,int(bx)+1)):
                    wx=min(bx,xx+1)-max(ax,xx)
                    if wx<=0: continue
                    r,g,b,a=p[yy][xx]; wgt=wx*wy; tot+=wgt; A+=a*wgt; R+=r*a*wgt; G+=g*a*wgt; B+=b*a*wgt
            if tot and A/tot>=110: out[ty][tx]=(R/A,G/A,B/A,255)
    return out
def kmeans(pts,K):
    random.seed(1); cent=[pts[i] for i in sorted(random.sample(range(len(pts)),min(K,len(pts))))]
    for it in range(20):
        groups=[[] for _ in cent]
        for q in pts: groups[min(range(len(cent)),key=lambda j:sum((q[i]-cent[j][i])**2 for i in range(3)))].append(q)
        cent=[tuple(sum(v[i] for v in g)/len(g) for i in range(3)) if g else cent[j] for j,g in enumerate(groups)]
    return [tuple(int(round(v)) for v in c) for c in cent]
def components(img):
    h,w=len(img),len(img[0]); seen=set(); comps=[]
    for y in range(h):
        for x in range(w):
            if img[y][x][3] and (x,y) not in seen:
                st=[(x,y)]; seen.add((x,y)); c=[]
                while st:
                    a,b=st.pop(); c.append((a,b))
                    for dx in (-1,0,1):
                        for dy in (-1,0,1):
                            n=(a+dx,b+dy)
                            if 0<=n[0]<w and 0<=n[1]<h and n not in seen and img[n[1]][n[0]][3]: seen.add(n); st.append(n)
                comps.append(c)
    return comps
def clean(img,cat):
    # у деревьев и кустов убираем оторванные кусочки (обрывки соседних рисунков при нарезке листа)
    if cat not in ('trees','bushes'): return img
    comps=components(img); big=max(len(c) for c in comps)
    for c in comps:
        if len(c)<big*0.04:
            for x,y in c: img[y][x]=(0,0,0,0)
    return img
def crop(img):
    ys=[y for y,r in enumerate(img) if any(c[3] for c in r)]; xs=[x for x in range(len(img[0])) if any(r[x][3] for r in img)]
    return [r[min(xs):max(xs)+1] for r in img[min(ys):max(ys)+1]]
for cat in ('trees','bushes','grass','flowers'):
    os.makedirs(f'{OUT}/{cat}',exist_ok=True)
    for fn in sorted(os.listdir(f'{SRC}/{cat}')):
        w,h,p=png.read(f'{SRC}/{cat}/{fn}')
        img=crop(clean(down(p,w,h,SCALE),cat))
        pts=[c[:3] for r in img for c in r if c[3]]; cent=kmeans(pts,K[cat])
        near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
        img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]
        png.write(f'{OUT}/{cat}/{fn}',len(img[0]),len(img),img)
        print(cat,fn,len(img[0]),'x',len(img))
