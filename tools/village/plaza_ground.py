# Генератор земли rm_village по концепту: карта типов (трава G / песок S / плитка P) на сетке 32x32,
# каждый тайл рисуется из присланного атласа tls_village_square_paving_32.png:
#  - заливки: трава 36/37, песок 38/39, плитка 32..35 (как в атласе);
#  - бордюр: профиль из атласа (2px фон, b0a390, e0d6c6, f3ebdb x2), рисуется внутри «старшего» типа
#    (P поверх S/G, S поверх G); выпуклые углы — пиксели угла из тайла 0 (grass_top_left),
#    вогнутые — дуга того же профиля.
# Выход: атлас (строка 0 пустая, строки 1-6 = исходные 48 тайлов, дальше — нужные новые), карта индексов.
import sys,os,hashlib,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
SRC,OUTDIR=sys.argv[1],sys.argv[2]
W,H=50,23
G,S,P=0,1,2
T=[[G]*W for _ in range(H)]
def rect(t,c0,c1,r0,r1):
    for r in range(r0,r1+1):
        for c in range(c0,c1+1): T[r][c]=t
# --- песчаные дороги ---
rect(S,0,21,12,13)    # западная дорога от выхода на ферму
rect(S,21,21,11,11)   # песчаный «карман» у левого края площади (как на концепте)
rect(S,20,21,14,16)   # поворот вниз
rect(S,20,46,15,16)   # нижняя дорога под площадью
rect(S,38,46,9,10)    # правый отросток от площади
rect(S,45,46,9,16)    # соединение правого отростка и нижней дороги
rect(S,45,49,12,13)   # к выходу в лес (obj_village_forest_gate 1568,400)
# --- площадь ---
rect(P,21,22,8,8)     # верхний левый угол у фонаря
rect(P,21,35,9,10)    # перед магазином и под ним
rect(P,25,36,11,11)
rect(P,22,36,12,14)
rect(P,37,37,9,11)    # узкая полоса справа от вертикальной изгороди
# --- клумбы внутри площади (трава с бордюром) ---
rect(G,22,24,11,12)   # большая клумба слева: верхняя часть (дерево, кусты)
rect(G,23,25,12,13)   # большая клумба: нижняя часть
rect(G,36,36,9,10)    # грядка вертикальной изгороди
w,h,A=png.read(SRC)
def src(i): c,r=i%8,i//8; return [row[c*32:c*32+32] for row in A[r*32:r*32+32]]
TILES=[src(i) for i in range(48)]
hx=lambda c:'%02x%02x%02x'%c[:3]
B,C,D=(0xb0,0xa3,0x90,255),(0xe0,0xd6,0xc6,255),(0xf3,0xeb,0xdb,255)
PROF=[None,None,B,C,D,D]          # глубина 0..5 от края; 0-1 = фон
CORNER=src(0)                       # grass_top_left: угол 14x14
def rnd(c,r,n,salt=''): return int(hashlib.md5(f'{salt}{c},{r}'.encode()).hexdigest(),16)%n
def fill(t,c,r):
    if t==G: return 37 if rnd(c,r,10,'g')<2 else 36
    if t==S: return 39 if rnd(c,r,10,'s')<2 else 38
    return 32+rnd(c,r,4,'p')
def ty(c,r):
    if 0<=c<W and 0<=r<H: return T[r][c]
    return None
CAN=[[None]*(W*32) for _ in range(H*32)]
def lay(lvl):
    # слой уровня lvl покрывает все тайлы с типом >= lvl; бордюр — против тайлов с типом < lvl;
    # полоса фона (глубина 0-1) и фон в углах прозрачны — там виден нижний слой
    for r in range(H):
        for c in range(W):
            t=T[r][c]
            if t<lvl: continue
            if lvl==G: tex=TILES[fill(G,c,r)]
            elif lvl==S: tex=TILES[fill(S,c,r)] if t==S else TILES[38]
            else: tex=TILES[fill(P,c,r)]
            low=set()
            for dc in(-1,0,1):
                for dr in(-1,0,1):
                    if dc or dr:
                        u=ty(c+dc,r+dr)
                        if u is not None and u<lvl: low.add((dc,dr))
            if low:   # у краевых тайлов — базовая заливка
                tex=TILES[32] if lvl==P else TILES[38]
            for py in range(32):
                for px in range(32):
                    fx,fy=px+.5,py+.5
                    pix='in'
                    hit=False
                    for (dc,dr) in((-1,-1),(1,-1),(-1,1),(1,1)):
                        if (dc,0) in low and (0,dr) in low:
                            qx=px if dc<0 else 31-px; qy=py if dr<0 else 31-py
                            if qx<14 and qy<14:
                                hit=True; k=CORNER[qy][qx]; kk=hx(k)
                                pix=None if kk=='93a25f' else (k if kk in('b0a390','e0d6c6','f3ebdb') else 'in')
                    if not hit:
                        ds=[]
                        if (0,-1) in low: ds.append(fy)
                        if (0,1) in low: ds.append(32-fy)
                        if (-1,0) in low: ds.append(fx)
                        if (1,0) in low: ds.append(32-fx)
                        for (dc,dr) in((-1,-1),(1,-1),(-1,1),(1,1)):
                            if (dc,dr) in low and (dc,0) not in low and (0,dr) not in low:
                                vx=0 if dc<0 else 32; vy=0 if dr<0 else 32
                                ds.append(((fx-vx)**2+(fy-vy)**2)**.5)
                        if ds:
                            k=int(min(ds))
                            pix=None if k<2 else (PROF[k] if k<6 else 'in')
                    if pix is None: continue
                    if pix=='in': pix=tex[py][px]
                    CAN[r*32+py][c*32+px]=tuple(pix)
lay(G); lay(S); lay(P)
def render(c,r):
    return [CAN[r*32+y][c*32:c*32+32] for y in range(32)],None
uniq={}     # ключ пикселей -> индекс в атласе
atlas=[]    # список тайлов-новых
def key(tl): return hashlib.md5(bytes(v for row in tl for p in row for v in p)).hexdigest()
for i,tl in enumerate(TILES): uniq.setdefault(key(tl),8+i)
grid=[[0]*W for _ in range(H)]
for r in range(H):
    for c in range(W):
        tl,_=render(c,r); k=key(tl)
        if k not in uniq:
            uniq[k]=8+48+len(atlas); atlas.append(tl)
        grid[r][c]=uniq[k]
COLS=8; ntiles=8+48+len(atlas); rows=(ntiles+COLS-1)//COLS
img=[[(0,0,0,0)]*(COLS*32) for _ in range(rows*32)]
def put(i,tl):
    c,r=i%COLS,i//COLS
    for y in range(32):
        for x in range(32): img[r*32+y][c*32+x]=tl[y][x]
for i,tl in enumerate(TILES): put(8+i,tl)
for j,tl in enumerate(atlas): put(56+j,tl)
png.write(f'{OUTDIR}/spr_village_square_paving.png',COLS*32,rows*32,img)
json.dump({'grid':grid,'terrain':T,'tile_count':rows*COLS,'rows':rows,'cols':COLS,'new_tiles':len(atlas)},open(f'{OUTDIR}/ground.json','w'))
# предпросмотр всей земли 1x
full=[[None]*(W*32) for _ in range(H*32)]
for r in range(H):
    for c in range(W):
        i=grid[r][c]; tc,tr=i%COLS,i//COLS
        for y in range(32):
            full[r*32+y][c*32:c*32+32]=img[tr*32+y][tc*32:tc*32+32]
png.write(f'{OUTDIR}/ground_preview_1x.png',W*32,H*32,full)
print('новых тайлов',len(atlas),'атлас',COLS*32,'x',rows*32,'всего ячеек',rows*COLS)
for r in range(H): print(''.join('.SP'[T[r][c]] for c in range(W)))
