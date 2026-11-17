# Фермер Джо: позы разговора spr_farmer_joe_talk (кадры 2-4 листа joe_sheet_v1: руки в стороны, смеётся, улыбается)
# в масштабе сидящего Джо (spr_farmer_joe_smoke, рост 50), низ по центру; портрет spr_joe_portrait_anim 56x56
# (голова из кадров 4 — улыбка и 3 — смех, верхние 58% рисунка).
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_anim
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]
w,h,p=png.read(SRC)
def body(qx,qy):
    q=[[c[:3]+(255,) if c[3]>=200 and not (c[0]>190 and c[1]<70 and c[2]<70) else (0,0,0,0) for c in r[qx*w//2:(qx+1)*w//2]] for r in p[qy*h//2:(qy+1)*h//2]]
    W,H=len(q[0]),len(q); seen=bytearray(W*H); best=[]
    for y in range(H):
        for x in range(W):
            if q[y][x][3] and not seen[y*W+x]:
                st=[(x,y)]; seen[y*W+x]=1; pts=[]
                while st:
                    a,b=st.pop(); pts.append((a,b))
                    for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                        if 0<=c<W and 0<=d<H and not seen[d*W+c] and q[d][c][3]: seen[d*W+c]=1; st.append((c,d))
                if len(pts)>len(best): best=pts
    xs=[a for a,b in best]; ys=[b for a,b in best]; X0,Y0=min(xs),min(ys)
    im=[[(0,0,0,0)]*(max(xs)-X0+1) for _ in range(max(ys)-Y0+1)]
    for a,b in best: im[b-Y0][a-X0]=q[b][a]
    return im
def shrink(im,f,cent=None):
    s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in down(im,len(im[0]),len(im),f)])
    return s
ref=body(0,0); F=50/len(ref)                                   # масштаб как у spr_farmer_joe_smoke
talk=[shrink(body(1,0),F),shrink(body(0,1),F),shrink(body(1,1),F)]
cent=kmeans([c[:3] for s in talk for r in s for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
CW=max(len(s[0]) for s in talk); CH=max(len(s) for s in talk); frames=[]
for s in talk:
    f=[[(0,0,0,0)]*CW for _ in range(CH)]; ox=(CW-len(s[0]))//2; oy=CH-len(s)
    for y,r in enumerate(s):
        for x,c in enumerate(r):
            if c[3]: f[oy+y][ox+x]=near(c)+(255,)
    frames.append(f)
gm_anim.sprite(P,'spr_farmer_joe_talk',frames,(CW//2,CH-1),(CW//2-12,CH-10,CW//2+11,CH-1),0); print('spr_farmer_joe_talk',CW,'x',CH)
heads=[]
for qx,qy in ((1,1),(0,1)):                                     # улыбается, смеётся
    b=body(qx,qy); hd=crop([r for r in b[:int(len(b)*0.58)]]); heads.append(shrink(hd,54/max(len(hd),len(hd[0]))))
cent=kmeans([c[:3] for s in heads for r in s for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
pf=[]
for s in heads:
    f=[[(0,0,0,0)]*56 for _ in range(56)]; ox=(56-len(s[0]))//2; oy=56-len(s)
    for y,r in enumerate(s):
        for x,c in enumerate(r):
            if c[3]: f[oy+y][ox+x]=near(c)+(255,)
    pf.append(f)
gm_anim.sprite(P,'spr_joe_portrait_anim',pf,(0,0),(0,0,55,55),0,folder=('Ui','folders/Sprites/Ui.yy')); print('spr_joe_portrait_anim',2)
