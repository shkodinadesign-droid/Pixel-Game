# Лес: растения и животные (art_incoming/forest_v1/forest_plants_v1.png, forest_animals_v1.png, прозрачный фон).
# Растения (3x3): пень с опятами, белый гриб, шампиньон / лисичка, мох, ягодный куст / земляника, сундук закрыт, открыт.
# Животные: лиса (5 шагов + 4 бега), ёж (клубок + 4 шага), сова (сидит + 4 полёта). Все — низ по центру, 24 цвета.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_anim
from b06_nature_convert import down,kmeans,crop
A,P=sys.argv[1],sys.argv[2]
def comps(fn,rowh):
    w,h,p=png.read(f'{A}/{fn}')
    img=[[c[:3]+(255,) if c[3]>=200 and not (c[0]>190 and c[1]<70 and c[2]<70) else (0,0,0,0) for c in r] for r in p]
    seen=bytearray(w*h); out=[]
    for y in range(h):
        for x in range(w):
            if img[y][x][3] and not seen[y*w+x]:
                st=[(x,y)]; seen[y*w+x]=1; pts=[]
                while st:
                    a,b=st.pop(); pts.append((a,b))
                    for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                        if 0<=c<w and 0<=d<h and not seen[d*w+c] and img[d][c][3]: seen[d*w+c]=1; st.append((c,d))
                if len(pts)>800:
                    xs=[q[0] for q in pts]; ys=[q[1] for q in pts]; x0,y0=min(xs),min(ys)
                    im=[[(0,0,0,0)]*(max(xs)-x0+1) for _ in range(max(ys)-y0+1)]
                    for a,b in pts: im[b-y0][a-x0]=img[b][a]
                    out.append(((y0+max(ys))//2//rowh,x0,im))
    out.sort(key=lambda t:(t[0],t[1])); return [t[2] for t in out]
def make(name,ims,f,folder,speed=0,solid_rows=None):
    sm=[crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in down(i,len(i[0]),len(i),f)]) for i in ims]
    cent=kmeans([c[:3] for s in sm for r in s for c in r if c[3]],24); near=lambda px:min(cent,key=lambda c:sum((c[k]-px[k])**2 for k in range(3)))
    W=max(len(s[0]) for s in sm)+2; H=max(len(s) for s in sm)
    frames=[]
    for s in sm:
        fr=[[(0,0,0,0)]*W for _ in range(H)]; ox=(W-len(s[0]))//2; oy=H-len(s)
        for y,r in enumerate(s):
            for x,c in enumerate(r):
                if c[3]: fr[oy+y][ox+x]=near(c)+(255,)
        frames.append(fr)
    rows=solid_rows or 6
    gm_anim.sprite(P,name,frames,(W//2,H-1),(2,H-rows,W-3,H-1),speed,folder=folder); print(name,len(frames),W,'x',H)
F=('forest','folders/Sprites/forest.yy')
pl=comps('forest_plants_v1.png',418)
for i,n in enumerate(['stump_mushrooms','mushroom_brown','mushroom_white','chanterelle','moss','berry_bush','strawberry','chest_closed','chest_open']):
    make(f'spr_forest_{n}',[pl[i]],0.13,F)
an=comps('forest_animals_v1.png',241)
fox,hog,owl=an[0:9],an[9:14],an[14:19]
make('spr_fox_walk',fox[0:5],0.15,F,8)
make('spr_fox_run',fox[5:9],0.15,F,12)
make('spr_hedgehog',hog,0.12,F,0)
make('spr_owl',owl,0.15,F,8)
