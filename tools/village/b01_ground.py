# Партия 01: трава + песочные дорожки для rm_village.
# Атлас песка присланный — «двойная сетка» (маска по 4 углам, граница дороги посередине тайла).
# Дороги в комнате заданы по клеткам 32x32 (граница по краю клетки), поэтому каждый тайл комнаты
# собирается из четвертинок 4 присланных тайлов — это ровно то, что дала бы раскладка с
# полутайловым сдвигом. Пиксели не перерисовываются, только переставляются четвертинки.
# Клетки площади (P) остаются в старом слое; для соседей они считаются «тем же типом», чтобы
# у бордюра не появлялась лишняя кромка.
import sys,os,json,hashlib
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
SRC,TERR,OUT=sys.argv[1],sys.argv[2],sys.argv[3]
T=json.load(open(TERR)); H=len(T); W=len(T[0])
gw,gh,GA=png.read(f'{SRC}/tls_village_grass_32.png')
sw,sh,SA=png.read(f'{SRC}/tls_village_sand_roads_32.png')
def cell(A,i,cols=4): c,r=i%cols,i//cols; return [row[c*32:c*32+32] for row in A[r*32:r*32+32]]
SAND=[cell(SA,i) for i in range(20)]
def rnd(c,r,n,salt): return int(hashlib.md5(f'{salt}{c},{r}'.encode()).hexdigest(),16)%n
def view(c,r):
    """типы клеток вокруг (c,r): P -> тип самой клетки, за краем — ближайшая клетка"""
    own=T[r][c]
    def t(x,y):
        x=min(max(x,0),W-1); y=min(max(y,0),H-1); u=T[y][x]
        return own if u=='P' else u
    return t
def mask(t,i,j):  # двойной тайл с углами в клетках (i-1,j-1),(i,j-1),(i-1,j),(i,j)
    s=lambda x,y:1 if t(x,y)=='S' else 0
    return s(i-1,j-1)*1+s(i,j-1)*2+s(i-1,j)*4+s(i,j)*8
atlas=[]; index={}
def add(tile):
    key=tuple(tuple(p) for row in tile for p in row)
    if key not in index: index[key]=len(atlas)+1; atlas.append(tile)   # 0 — пустой тайл GameMaker
    return index[key]
grid=[[0]*W for _ in range(H)]; gras=[[0]*W for _ in range(H)]
for r in range(H):
    for c in range(W):
        # трава: база grass_00, редкие варианты 1..15 (~30%), без одинаковых соседей слева/сверху
        g=0
        if rnd(c,r,10,'gv')<3:
            g=1+rnd(c,r,15,'gi')
            if (c and gras[r][c-1]==g+4) or (r and gras[r-1][c]==g+4): g=1+(g%15)
        gras[r][c]=g+4                                            # +4: в спрайте сверху пустая строка
        if T[r][c]=='P': continue
        t=view(c,r)
        m=[mask(t,c,r),mask(t,c+1,r),mask(t,c,r+1),mask(t,c+1,r+1)]   # D для NW,NE,SW,SE четвертей
        if m==[0,0,0,0]: continue                                  # чистая трава — только слой травы
        if m==[15,15,15,15]:
            k=rnd(c,r,10,'sv'); tile=SAND[15 if k<6 else 16+(k-6)]
        else:
            q=[cell(SA,m[0]),cell(SA,m[1]),cell(SA,m[2]),cell(SA,m[3])]
            # четверть NW клетки = SE-четверть D(c,r); NE = SW от D(c+1,r); SW = NE от D(c,r+1); SE = NW от D(c+1,r+1)
            tile=[[None]*32 for _ in range(32)]
            for y in range(32):
                for x in range(32):
                    if y<16: tile[y][x]=q[0][y+16][x+16] if x<16 else q[1][y+16][x-16]
                    else:    tile[y][x]=q[2][y-16][x+16] if x<16 else q[3][y-16][x-16]
        grid[r][c]=add(tile)
COLS=8; rows=(len(atlas)+1+COLS-1)//COLS
img=[[(0,0,0,0)]*(COLS*32) for _ in range(rows*32)]
for n,tile in enumerate(atlas,1):
    ox,oy=(n%COLS)*32,(n//COLS)*32
    for y in range(32):
        for x in range(32): img[oy+y][ox+x]=tile[y][x]
os.makedirs(OUT,exist_ok=True)
png.write(f'{OUT}/spr_village_sand_roads_32_grid.png',COLS*32,rows*32,img)
# исходные атласы с пустой строкой сверху (тайл 0 в GameMaker пустой): индекс GM = индекс из CSV + 4
blank=[[(0,0,0,0)]*128 for _ in range(32)]
png.write(f'{OUT}/spr_village_grass_32.png',128,gh+32,blank+[list(r) for r in GA])
png.write(f'{OUT}/spr_village_sand_roads_32.png',128,sh+32,blank+[list(r) for r in SA])
json.dump({'sand_grid':grid,'grass_grid':gras,'tile_count':rows*COLS,'cols':COLS},open(f'{OUT}/b01.json','w'))
# превью 1:1 земли (без площади)
full=[[None]*(W*32) for _ in range(H*32)]
for r in range(H):
    for c in range(W):
        gt=cell(GA,gras[r][c]-4)
        st=atlas[grid[r][c]-1] if grid[r][c] else None
        for y in range(32):
            for x in range(32):
                p=st[y][x] if st else gt[y][x]
                if T[r][c]=='P': p=(255,0,255,255)
                full[r*32+y][c*32+x]=p
png.write(f'{OUT}/ground_only_1x.png',W*32,H*32,full)
print('тайлов песка в комнате:',len(atlas),'атлас',COLS*32,'x',rows*32)
