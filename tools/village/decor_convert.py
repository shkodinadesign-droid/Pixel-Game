# Перевод декора из крупного листа в игровой пиксель-арт: обрезка по непрозрачному, усреднение по площади
# до целевой высоты, альфа 0/255, палитра k-means (ограниченное число цветов), без сглаживания в результате.
import sys,os,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
SRC,OUT=sys.argv[1],sys.argv[2]
JOBS=json.loads(sys.argv[3])     # {"01_street_lamp":[84,14], ...}  высота, число цветов
def conv(name,TH,K):
    w,h,p=png.read(f'{SRC}/{name}.png')
    xs=[x for y in range(h) for x in range(w) if p[y][x][3]>40]; ys=[y for y in range(h) for x in range(w) if p[y][x][3]>40]
    x0,x1,y0,y1=min(xs),max(xs)+1,min(ys),max(ys)+1
    sw,sh=x1-x0,y1-y0; TW=max(1,round(sw*TH/sh))
    fx,fy=sw/TW,sh/TH
    out=[[(0,0,0,0)]*TW for _ in range(TH)]
    for ty in range(TH):
        for tx in range(TW):
            ax,bx=x0+tx*fx,x0+(tx+1)*fx; ay,by=y0+ty*fy,y0+(ty+1)*fy
            R=G=B=A=0.0; tot=0.0
            for yy in range(int(ay),min(h,int(by)+1)):
                wy=min(by,yy+1)-max(ay,yy)
                if wy<=0: continue
                for xx in range(int(ax),min(w,int(bx)+1)):
                    wx=min(bx,xx+1)-max(ax,xx)
                    if wx<=0: continue
                    r,g,b,a=p[yy][xx]; wgt=wx*wy; tot+=wgt; A+=a*wgt
                    R+=r*a*wgt; G+=g*a*wgt; B+=b*a*wgt
            if tot and A/tot>=128: out[ty][tx]=(R/A,G/A,B/A,255)
    pts=[c[:3] for row in out for c in row if c[3]]
    import random; random.seed(1)
    def kmeans(pts,K):
        if not pts or K<=0: return []
        cent=[pts[i] for i in sorted(random.sample(range(len(pts)),min(K,len(pts))))]
        for it in range(25):
            groups=[[] for _ in cent]
            for q in pts:
                j=min(range(len(cent)),key=lambda j:sum((q[i]-cent[j][i])**2 for i in range(3))); groups[j].append(q)
            cent=[tuple(sum(v[i] for v in g)/len(g) for i in range(3)) if g else cent[j] for j,g in enumerate(groups)]
        return [tuple(int(round(v)) for v in c) for c in cent]
    # фиолетовые пиксели (виноград, люпины) — отдельная маленькая палитра, чтобы не слились с серым
    purple=lambda q:q[2]>q[1]+18 and q[0]>q[1]-5
    pp=[q for q in pts if purple(q)]; KP=4 if len(pp)>=8 else 0
    cent=kmeans([q for q in pts if not purple(q)],K-KP); cp=kmeans(pp,KP)
    near=lambda px,cs:min(cs,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    res=[[ (near(px,cp if (cp and purple(px)) else cent)+(255,)) if px[3] else (0,0,0,0) for px in row] for row in out]
    cent=cent+cp
    png.write(f'{OUT}/{name}.png',TW,TH,res)
    print(name,TW,'x',TH,'цветов',len(set(cent)))
for n,(th,k) in JOBS.items(): conv(n,th,k)
