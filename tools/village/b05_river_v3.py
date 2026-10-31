# Речка V3 + чистый мост (deck / front_rail) в rm_village — заменяет речку и мост V2.
#  - tls_village_river_32.png: угловые маски (бит = вода: NW=1 NE=2 SE=4 SW=8), граница посередине тайла.
#    Русло в комнате задано клетками 32x32 (граница по краю клетки), поэтому тайл комнаты собирается из
#    четвертинок 4 присланных тайлов (без перерисовки). Полная вода — тайлы 15-18 целиком.
#    Трава атласа #8f9d4c -> #8f9c4b (трава комнаты).
#  - мост: spr_village_bridge_deck (настил, за Макс, depth 630) и spr_village_bridge_front_rail (передняя
#    сторона и столбы, перед Макс) — один холст 160x128, origin (0,0), одинаковые x,y.
#    Проход — по верхней части настила (локально y 24..60); вода сверху/снизу закрыта obj_village_water_block.
import sys,os,re,json,shutil,hashlib
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gmtiles,gm_res
P,SRC,OUT=sys.argv[1],sys.argv[2],sys.argv[3]
W,H=50,23; E=gmtiles.EMPTY
BX,BY=112,374                 # левый-верхний угол моста (оба слоя)
WALK=(24,60)                  # проходимая полоса настила по y (локально)
WATER=[[0]*W for _ in range(H)]
for r in range(H):
    for c in range(4, 8 if r<=15 else 7): WATER[r][c]=1     # 4 клетки, ниже моста сужение до 3 (как в примере V3)
os.makedirs(OUT,exist_ok=True)
tw,th,TA=png.read(f'{SRC}/tls_village_river_32.png')
TA=[[(0x8f,0x9c,0x4b,255) if tuple(p[:3])==(0x8f,0x9d,0x4c) else p for p in r] for r in TA]
def cell(i): c,r=i%4,i//4; return [row[c*32:c*32+32] for row in TA[r*32:r*32+32]]
def wt(c,r): return WATER[min(max(r,0),H-1)][min(max(c,0),W-1)]
def mask(i,j): return wt(i-1,j-1)*1+wt(i,j-1)*2+wt(i,j)*4+wt(i-1,j)*8      # NW NE SE SW
rnd=lambda c,r,n,s:int(hashlib.md5(f'{s}{c},{r}'.encode()).hexdigest(),16)%n
atlas=[]; idx={}
def add(t):
    k=tuple(tuple(p) for row in t for p in row)
    if k not in idx: idx[k]=len(atlas)+1; atlas.append(t)
    return idx[k]
grid=[E]*(W*H)
for r in range(H):
    for c in range(W):
        m=[mask(c,r),mask(c+1,r),mask(c,r+1),mask(c+1,r+1)]   # D для четвертей NW,NE,SW,SE клетки
        if m==[0,0,0,0]: continue
        if m==[15,15,15,15]:
            q=rnd(c,r,10,'wv'); t=cell(15 if q<6 else 16+(q-6)%3)
        else:
            q=[cell(x) for x in m]; t=[[None]*32 for _ in range(32)]
            for y in range(32):
                for x in range(32):
                    if y<16: t[y][x]=q[0][y+16][x+16] if x<16 else q[1][y+16][x-16]
                    else:    t[y][x]=q[2][y-16][x+16] if x<16 else q[3][y-16][x-16]
        grid[r*W+c]=add(t)
COLS=8; rows=(len(atlas)+1+COLS-1)//COLS
img=[[(0,0,0,0)]*(COLS*32) for _ in range(rows*32)]
for n,t in enumerate(atlas,1):
    ox,oy=(n%COLS)*32,(n//COLS)*32
    for y in range(32):
        for x in range(32): img[oy+y][ox+x]=t[y][x]
png.write(f'{OUT}/spr_village_river_32.png',COLS*32,rows*32,img)
# ---- ресурсы ----
def tileset(name,spr,count,cols):
    t=open(f'{P}/tilesets/tls_village_plaza_32/tls_village_plaza_32.yy').read()
    t=t.replace('spr_village_plaza_32',spr).replace('tls_village_plaza_32',name)
    t=re.sub(r'"tile_count":\d+',f'"tile_count":{count}',t); t=re.sub(r'"out_columns":\d+',f'"out_columns":{cols}',t)
    d=f'{P}/tilesets/{name}'; assert not os.path.exists(d),name; os.makedirs(d); open(f'{d}/{name}.yy','w').write(t)
gm_res.sprite(P,'spr_village_river_32',img,(0,0),(0,0,COLS*32-1,rows*32-1)); tileset('tls_village_river_32','spr_village_river_32',rows*COLS,COLS)
_,_,deck=png.read(f'{SRC}/spr_village_bridge_deck_160x128.png'); _,_,front=png.read(f'{SRC}/spr_village_bridge_front_rail_160x128.png')
gm_res.sprite(P,'spr_village_bridge_deck',deck,(0,0),gm_res.opaque(deck))
fb=gm_res.opaque(front); gm_res.sprite(P,'spr_village_bridge_front_rail',front,(0,0),(fb[0],fb[3]-9,fb[2],fb[3]))   # маска — низ столбов
def setspr(o,s):
    p=f'{P}/objects/{o}/{o}.yy'; t=open(p).read()
    t,k=re.subn(r'"spriteId":\{\s*"name":"\w+",\s*"path":"sprites/\w+/\w+\.yy",\s*\}',f'"spriteId":{{\n    "name":"{s}",\n    "path":"sprites/{s}/{s}.yy",\n  }}',t); assert k==1,o
    open(p,'w').write(t)
setspr('obj_village_bridge','spr_village_bridge_deck'); setspr('obj_village_bridge_front','spr_village_bridge_front_rail')
# старые V2: тайлсет/спрайт речки и спрайты моста
OLD=[('tilesets','tls_village_river'),('sprites','spr_village_river_tiles'),('sprites','spr_village_bridge_master'),('sprites','spr_village_bridge_front')]
yp=f'{P}/max_farm_demo.yyp'; y=open(yp).read()
for kd,n in OLD:
    y,k=re.subn(r'\n *\{"id":\{"name":"'+n+r'","path":"[^"]+",\},\},','',y); assert k==1,n; shutil.rmtree(f'{P}/{kd}/{n}')
i=y.index('  "resources":['); j=y.index('\n  ],',i)
new=[('sprites','spr_village_river_32'),('tilesets','tls_village_river_32'),('sprites','spr_village_bridge_deck'),('sprites','spr_village_bridge_front_rail')]
y=y[:j]+''.join(f'\n    {{"id":{{"name":"{n}","path":"{kd}/{n}/{n}.yy",}},}},' for kd,n in new)+y[j:]
open(yp,'w').write(y)
# ---- комната ----
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read()
a=t.index('{"$GMRTileLayer":"","%Name":"village_river_32"'); b=t.index('\n',t.index('"tilesetId"',a)); line=t[a:b]
m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',line,re.S)
enc=gmtiles.encode(grid); dat=''.join('\n          '+','.join(map(str,enc[n:n+40]))+',' for n in range(0,len(enc),40))+'\n        '
line=line[:m.start(1)]+dat+line[m.end(1):]
line,k=re.subn(r'"tilesetId":\{"name":"tls_village_river","path":"tilesets/tls_village_river/tls_village_river.yy",\}','"tilesetId":{"name":"tls_village_river_32","path":"tilesets/tls_village_river_32/tls_village_river_32.yy",}',line); assert k==1
# речка под песком дороги (646 < 648 трава, > 645 песок): берег не перекрывает дорогу у моста
line,k=re.subn(r'"%Name":"village_river_32","depth":\d+','"%Name":"village_river_32","depth":646',line); assert k==1
t=t[:a]+line+t[b:]
# под руслом не должно быть песка дороги и её бордюров (иначе бордюр виден поперёк воды у моста)
def clear(t,name):
    a=t.index('{"$GMRTileLayer":"","%Name":"'+name+'"'); b=t.index('\n',t.index('"tilesetId"',a)); ln=t[a:b]
    m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',ln,re.S)
    v=gmtiles.decode([int(x) for x in m.group(1).replace('\n','').split(',') if x.strip()],W*H)
    v=[E if WATER[k//W][k%W] else v[k] for k in range(W*H)]
    enc=gmtiles.encode(v); d=''.join('\n          '+','.join(map(str,enc[n:n+40]))+',' for n in range(0,len(enc),40))+'\n        '
    return t[:a]+ln[:m.start(1)]+d+ln[m.end(1):]+t[b:]
t=clear(t,'village_sand_32'); t=clear(t,'village_curbs_32')
def place(nm,x,y,sx=None,sy=None):
    global t
    s=re.search(r'\{"\$GMRInstance":"v4","%Name":"'+nm+r'".*?\},(?=\n)',t).group(0); s2=re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(x)},"y":{float(y)}',s)
    if sx is not None: s2=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+',f'"scaleX":{float(sx)},"scaleY":{float(sy)}',s2)
    t=t.replace(s,s2)
place('inst_VILLAGE_BRIDGE',BX,BY); place('inst_VILLAGE_BRIDGE_FRONT',BX,BY)
top,bot=BY+WALK[0],BY+WALK[1]
place('inst_WATER_BLOCK_N',128,0,4,top/32)
place('inst_WATER_BLOCK_S',128,bot,4,(16*32-bot)/32)            # до конца ряда 15 — ширина 4 клетки
tpl=re.search(r'\{"\$GMRInstance":"v4","%Name":"inst_WATER_BLOCK_S".*?\},(?=\n)',t).group(0)
if 'inst_WATER_BLOCK_S2' not in t:
    s2=tpl.replace('inst_WATER_BLOCK_S','inst_WATER_BLOCK_S2'); s2=re.sub(r'"x":[-\d.]+,"y":[-\d.]+','"x":128.0,"y":512.0',s2)
    s2=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+',f'"scaleX":3.0,"scaleY":{(H*32-512)/32}',s2)
    t=t.replace(tpl,tpl+'\n        '+s2)
    k=t.index('"instanceCreationOrder":[')+len('"instanceCreationOrder":[')
    t=t[:k]+'\n    {"name":"inst_WATER_BLOCK_S2","path":"rooms/rm_village/rm_village.yy",},'+t[k:]
open(rp,'w').write(t)
print('тайлов речки',len(atlas),'проход по мосту y',top,'..',bot)
