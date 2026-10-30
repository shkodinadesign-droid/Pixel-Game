# Этап 2 + 3А: плитка площади, каменные бордюры, круглый центр — из присланного листа (Unknown-19.png).
# Масштаб по MASTER: блок 2x2 камня листа (152px) = тайл 32x32; бордюр листа (48-50px) = 10px; круг = 128px.
#  - заливка: 4 варианта; каждый камень блока уменьшен до 15x15, швы 1px цвета шва листа (бесшовно);
#  - бордюр: профиль поперёк полосы листа (горизонтальной и вертикальной), 10px, швы сегментов каждые 16px;
#    набор «blob-47»: края, внешние скругленные углы, внутренние углы, узкие перемычки, торцы, островки,
#    Т- и крестовые стыки; у внешнего угла снаружи дуги — цвет травы или песка (два варианта);
#  - круг: кольцо (без центра) 4x4 тайла + клумба в центре отдельным спрайтом.
import sys,os,json,math,collections
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
SRC,OUT=sys.argv[1],sys.argv[2]; os.makedirs(OUT,exist_ok=True)
w,h,A=png.read(SRC)
def ok(c):
    r,g,b,a=c
    if a<200: return False
    if r>200 and g>200 and b<90: return False      # жёлтый ореол листа
    if r>180 and g<60 and b<60: return False        # красный ореол
    return True
def avg(x0,y0,x1,y1,tw,th,mask=False):
    """усреднение по площади области [x0,x1)x[y0,y1) в tw x th; mask=True — альфа по доле «хороших» пикселей"""
    fx,fy=(x1-x0)/tw,(y1-y0)/th; out=[]
    for ty in range(th):
        row=[]
        for tx in range(tw):
            ax,bx=x0+tx*fx,x0+(tx+1)*fx; ay,by=y0+ty*fy,y0+(ty+1)*fy
            R=G=B=0.0; tot=0.0; good=0.0
            for yy in range(int(ay),int(math.ceil(by))):
                wy=min(by,yy+1)-max(ay,yy)
                if wy<=0: continue
                for xx in range(int(ax),int(math.ceil(bx))):
                    wx=min(bx,xx+1)-max(ax,xx)
                    if wx<=0: continue
                    c=A[yy][xx]; wgt=wx*wy; tot+=wgt
                    if not ok(c): continue
                    good+=wgt; R+=c[0]*wgt; G+=c[1]*wgt; B+=c[2]*wgt
            if good==0 or (mask and good/tot<0.5): row.append((0,0,0,0))
            else: row.append((round(R/good),round(G/good),round(B/good),255))
        out.append(row)
    return out
def kmeans(pts,K,seed=1):
    import random; random.seed(seed)
    pts=list(pts); cent=[pts[i] for i in sorted(random.sample(range(len(pts)),min(K,len(pts))))]
    for _ in range(20):
        gr=[[] for _ in cent]
        for q in pts: gr[min(range(len(cent)),key=lambda j:sum((q[i]-cent[j][i])**2 for i in range(3)))].append(q)
        cent=[tuple(sum(v[i] for v in g)/len(g) for i in range(3)) if g else cent[j] for j,g in enumerate(gr)]
    return [tuple(int(round(v)) for v in c) for c in cent]
def quant(img,K):
    pts=[p[:3] for r in img for p in r if p[3]]; pal=kmeans(pts,K)
    near=lambda q:min(pal,key=lambda c:sum((c[i]-q[i])**2 for i in range(3)))
    return [[(near(p[:3])+(255,)) if p[3] else p for p in r] for r in img]
# ---------- 1. заливка площади ----------
BLOCKS=[(64,84),(253,84),(440,84),(625,84)]          # левый-верхний угол блока (по контуру)
JOINT=None
def stone(x0,y0,x1,y1): return avg(x0,y0,x1,y1,15,15)
fills=[]
for bx,by in BLOCKS:
    # камни между швами: контур 3px, шов посередине (~76px от края)
    st=[stone(bx+3,by+3,bx+75,by+75),stone(bx+79,by+3,bx+150,by+75),
        stone(bx+3,by+79,bx+75,by+146),stone(bx+79,by+79,bx+150,by+146)]
    fills.append(st)
# цвет шва — центр внутреннего креста блока 0
jx=[A[y][140] for y in range(100,150)]; JOINT=tuple(sum(c[i] for c in jx)//len(jx) for i in range(3))+(255,)
FILL=[]
for st in fills:
    t=[[JOINT]*32 for _ in range(32)]
    for k,(ox,oy) in enumerate([(1,1),(17,1),(1,17),(17,17)]):
        for y in range(15):
            for x in range(15): t[oy+y][ox+x]=st[k][y][x]
    FILL.append(t)
allfill=quant([r for t in FILL for r in t],10); FILL=[allfill[i*32:(i+1)*32] for i in range(4)]
# ---------- 2. профиль бордюра ----------
CW=10
hp=avg(110,291,150,341,1,CW); HPROF=[r[0] for r in hp]          # сверху вниз (горизонтальная полоса)
vp=avg(838,150,888,190,CW,1); VPROF=vp[0]                       # слева направо (вертикальная полоса)
segj=[A[y][x] for y in range(296,326) for x in (161,162,163)]  # шов между сегментами полосы
SEGJ=None
# шов сегмента: найдём самую тёмную колонку в полосе 11 между 140 и 200
best=min(range(140,200),key=lambda x:sum(sum(A[y][x][:3]) for y in range(296,326)))
cs=[A[y][best] for y in range(296,326)]; SEGJ=tuple(sum(c[i] for c in cs)//len(cs) for i in range(3))+(255,)
GRASS=(0x8f,0x9c,0x4b,255); SAND=(0xde,0xa5,0x5e,255)
def curb_tile(m,low):
    """m: dict side->bool (N,E,S,W ниже), diag NE,SE,SW,NW; low: цвет снаружи внешнего угла"""
    N,E,S,W=m['N'],m['E'],m['S'],m['W']
    t=[[(0,0,0,0)]*32 for _ in range(32)]
    def put(x,y,kind,idx,joint=False):
        idx=max(0,min(CW-1,idx)); c=(HPROF if kind=='h' else VPROF)[idx]
        t[y][x]=SEGJ if joint and 1<=idx<=CW-2 else c
    for y in range(32):
        for x in range(32):
            px,py=x+.5,y+.5; done=False
            # внешние углы (обе стороны ниже)
            for cv,ch,cx,cy in (('N','W',CW,CW),('N','E',32-CW,CW),('S','W',CW,32-CW),('S','E',32-CW,32-CW)):
                if m[cv] and m[ch] and ((px<CW) if ch=='W' else (px>32-CW)) and ((py<CW) if cv=='N' else (py>32-CW)):
                    r=math.hypot(px-cx,py-cy); done=True
                    if r>CW: t[y][x]=low; break
                    d=int(CW-r)  # 0 у внешнего края
                    dx,dy=abs(px-cx),abs(py-cy)
                    if dy>=dx: put(x,y,'h',d if cv=='N' else CW-1-d)
                    else:      put(x,y,'v',d if ch=='W' else CW-1-d)
                    break
            if done: continue
            # прямые полосы
            if N and py<CW: put(x,y,'h',y,joint=(x%16==0)); continue
            if S and py>32-CW: put(x,y,'h',y-(32-CW),joint=(x%16==0)); continue
            if W and px<CW: put(x,y,'v',x,joint=(y%16==0)); continue
            if E and px>32-CW: put(x,y,'v',x-(32-CW),joint=(y%16==0)); continue
            # внутренние углы (стороны не ниже, диагональ ниже)
            for dg,cx,cy,vside,hside in (('NW',0,0,'N','W'),('NE',32,0,'N','E'),('SW',0,32,'S','W'),('SE',32,32,'S','E')):
                if m[dg] and not m[vside] and not m[hside]:
                    r=math.hypot(px-cx,py-cy)
                    if r<CW:
                        d=int(r); dx,dy=abs(px-cx),abs(py-cy)
                        if dx<dy: put(x,y,'h',d if vside=='N' else CW-1-d)   # у боковой кромки — продолжение горизонтальной полосы соседа
                        else:     put(x,y,'v',d if hside=='W' else CW-1-d)
                        break
    return t
# канонические 47 конфигураций, по группам
def canon(bits):
    m=dict(bits)
    for dg,a,b in (('NE','N','E'),('SE','S','E'),('SW','S','W'),('NW','N','W')):
        if m[a] or m[b]: m[dg]=False
    return tuple(sorted(m.items()))
confs=set()
import itertools
for v in itertools.product([0,1],repeat=8):
    bits=list(zip(['N','E','S','W','NE','SE','SW','NW'],map(bool,v))); confs.add(canon(bits))
def group(c):
    m=dict(c); s=sum(m[k] for k in 'NESW'); dg=sum(m[k] for k in ('NE','SE','SW','NW'))
    if s==0: return (1 if dg==1 else 5 if dg==2 else 6,)        # внутренний угол / Т-стык / крест
    if s==1: return (2,)                                          # край
    if s==2 and ((m['N'] and m['S']) or (m['E'] and m['W'])): return (7,)  # узкая перемычка
    if s==2: return (3,)                                          # внешний угол
    if s==3: return (8,)                                          # торец
    return (9,)                                                   # островок
GNAMES={1:'inner_corner',2:'edge',3:'outer_corner',5:'t_junction',6:'cross_junction',7:'narrow',8:'end_cap',9:'island'}
order=sorted(confs,key=lambda c:(group(c),str(c)))
TILES=[None]; NAMES=['empty']; LUT={}
def addt(t,name):
    TILES.append(t); NAMES.append(name); return len(TILES)-1
for i,f in enumerate(FILL): addt(f,f'fill_{i+1}')
while len(TILES)%8: addt([[(0,0,0,0)]*32 for _ in range(32)],'empty')
for lowname,low in (('grass',GRASS),('sand',SAND)):
    for c in order:
        m=dict(c); hasconvex=any(m[a] and m[b] for a,b in (('N','W'),('N','E'),('S','W'),('S','E')))
        if lowname=='sand' and not hasconvex: LUT[(c,'sand')]=LUT[(c,'grass')]; continue
        LUT[(c,lowname)]=addt(curb_tile(m,low),f"curb_{GNAMES[group(c)[0]]}_{lowname}_"+'-'.join(k for k,v in c if v))
    while len(TILES)%8: addt([[(0,0,0,0)]*32 for _ in range(32)],'empty')
# ---------- 3. круг ----------
ring=avg(413,674,731,988,128,128,mask=True)
cx=cy=64
ring=[[p if p[3] and 30<=math.hypot(x+.5-cx,y+.5-cy)<=64 else (0,0,0,0) for x,p in enumerate(r)] for y,r in enumerate(ring)]
ring=quant(ring,10)
# кольцо — блоком 4x4 в левых колонках атласа (справа пусто), чтобы в редакторе его было удобно брать целиком
E32=lambda:[[(0,0,0,0)]*32 for _ in range(32)]
RING0=len(TILES)
for ty in range(4):
    for tx in range(4): addt([r[tx*32:tx*32+32] for r in ring[ty*32:ty*32+32]],f'ring_r{ty}c{tx}')
    for _ in range(4): addt(E32(),'empty')
# клумба: центр первого круга (с цветами), тот же масштаб, что и у кольца (круг 340px -> 128px)
k=128/340; bcx,bcy=47+170,664+167; R=int(round(88))
bed=avg(bcx-R,bcy-R,bcx+R,bcy+R,int(2*R*k),int(2*R*k),mask=True)
bs=len(bed); bed=[[p if p[3] and math.hypot(x+.5-bs/2,y+.5-bs/2)<=bs/2-0.5 else (0,0,0,0) for x,p in enumerate(r)] for y,r in enumerate(bed)]
bed=quant(bed,16)
png.write(f'{OUT}/spr_village_plaza_flowerbed.png',bs,bs,bed)
# ---------- запись атласа ----------
COLS=8; rows=(len(TILES)+COLS-1)//COLS
img=[[(0,0,0,0)]*(COLS*32) for _ in range(rows*32)]
for n,t in enumerate(TILES):
    if t is None: continue
    ox,oy=(n%COLS)*32,(n//COLS)*32
    for y in range(32):
        for x in range(32): img[oy+y][ox+x]=t[y][x]
png.write(f'{OUT}/spr_village_plaza_32.png',COLS*32,rows*32,img)
json.dump({'lut':{f'{lo}|'+','.join(k for k,v in c if v):i for (c,lo),i in LUT.items()},'fill':[1,2,3,4],'ring0':RING0,
           'names':NAMES,'cols':COLS,'tile_count':rows*COLS,'bed_size':bs},open(f'{OUT}/b02.json','w'),ensure_ascii=False,indent=0)
with open(f'{OUT}/TILE_INDEX_PLAZA.csv','w') as f:
    f.write('gm_index,col,row,name\n')
    for i,n in enumerate(NAMES): f.write(f'{i},{i%COLS},{i//COLS},{n}\n')
# превью атласа x3 с сеткой
k3=3; W3=COLS*32*k3; H3=rows*32*k3
pv=[[(60,60,60,255)]*W3 for _ in range(H3)]
for y in range(H3):
    for x in range(W3):
        c=img[y//k3][x//k3]
        if c[3]: pv[y][x]=c
        if (x//k3)%32==0 and x%k3==0 or (y//k3)%32==0 and y%k3==0: pv[y][x]=(255,0,255,255)
png.write(f'{OUT}/PREVIEW_PLAZA_ATLAS_3X.png',W3,H3,pv)
print('тайлов',len(TILES),'атлас',COLS*32,'x',rows*32,'клумба',bs,'шов',JOINT,'шов сегм',SEGJ)
print('H',HPROF); print('V',VPROF)
