# Речка и мост (MASTER V2) в rm_village.
#  - tls_village_river (атлас как прислан + пустая строка сверху: индекс GM = индекс CSV + 8);
#    трава атласа #8f9d4c приведена к траве комнаты #8f9c4b (разница в 1 единицу, чтобы не было шва);
#  - слой village_river_32 (depth 644: над травой и песком, под плиткой/бордюрами);
#    вода — колонки 4..7 (x 128..256) по всей высоте, берега: shore_land_W / shore_land_E;
#  - мост: spr_village_bridge_master (как прислан, без столбиков спереди) — obj_village_bridge, земля (depth 630);
#    передние столбики тем же рисунком — spr_village_bridge_front / obj_village_bridge_front (сортировка с Макс);
#  - вода непроходима: obj_village_water_block (невидимый, наследник obj_solid) сверху и снизу от настила.
import sys,os,re,json,shutil,hashlib
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gmtiles,gm_res
P,SRC,OUT=sys.argv[1],sys.argv[2],sys.argv[3]
REMOVE=sys.argv[4].split(',') if len(sys.argv)>4 and sys.argv[4] else []
W,H=50,23; E=gmtiles.EMPTY; C0,C1=4,7; BX,BY=112,355    # колонки реки, левый-верхний угол моста
os.makedirs(OUT,exist_ok=True)
def tileset(name,spr,count,cols):
    t=open(f'{P}/tilesets/tls_village_plaza_32/tls_village_plaza_32.yy').read()
    t=t.replace('spr_village_plaza_32',spr).replace('tls_village_plaza_32',name)
    t=re.sub(r'"tile_count":\d+',f'"tile_count":{count}',t); t=re.sub(r'"out_columns":\d+',f'"out_columns":{cols}',t)
    d=f'{P}/tilesets/{name}'; assert not os.path.exists(d),name; os.makedirs(d); open(f'{d}/{name}.yy','w').write(t)
made=[]
w,h,a=png.read(f'{SRC}/tls_village_river_32_MASTER.png')
a=[[(0x8f,0x9c,0x4b,255) if tuple(p[:3])==(0x8f,0x9d,0x4c) else p for p in r] for r in a]
img=[[(0,0,0,0)]*w for _ in range(32)]+a
png.write(f'{OUT}/spr_village_river_tiles.png',w,h+32,img)
gm_res.sprite(P,'spr_village_river_tiles',img,(0,0),(0,0,w-1,h+31)); tileset('tls_village_river','spr_village_river_tiles',(w//32)*((h+32)//32),w//32)
made+=['spr_village_river_tiles','tls_village_river']
# мост: настил (всё, кроме двух передних столбиков) и передние столбики
bw,bh,b=png.read(f'{SRC}/spr_village_bridge_MASTER_correct_160x128.png')
FRONT=lambda x,y: y>=68 and (x<42 or x>=117)          # передние столбики: левый и правый низ
deck=[[(0,0,0,0) if FRONT(x,y) else p for x,p in enumerate(r)] for y,r in enumerate(b)]
front=[[p if FRONT(x,y) else (0,0,0,0) for x,p in enumerate(r)] for y,r in enumerate(b)]
gm_res.sprite(P,'spr_village_bridge_master',deck,(0,0),gm_res.opaque(deck))
fb=gm_res.opaque(front)
gm_res.sprite(P,'spr_village_bridge_front',front,(0,0),(fb[0],bh-10,fb[2],bh-1))   # маска — низ столбиков
gm_res.obj(P,'obj_village_bridge','spr_village_bridge_master',None,
    events={(0,0,'Create_0.gml'):'// ===== МОСТИК ЧЕРЕЗ РЕЧКУ (CREATE) =====\n// Настил лежит на земле: под Макс, над водой и берегами. Не препятствие —\n// по настилу можно ходить; вода вокруг закрыта obj_village_water_block.\ndepth = 630;\n'},solid=False)
gm_res.obj(P,'obj_village_bridge_front','spr_village_bridge_front','obj_village_prop')
made+=['spr_village_bridge_master','spr_village_bridge_front','obj_village_bridge','obj_village_bridge_front']
# невидимая преграда воды: маска 32x32, растягивается масштабом
blk=[[(40,120,200,120)]*32 for _ in range(32)]
gm_res.sprite(P,'spr_village_water_block',blk,(0,0),(0,0,31,31))
gm_res.obj(P,'obj_village_water_block','spr_village_water_block','obj_solid',
    events={(0,0,'Create_0.gml'):'// ===== ВОДА — НЕПРОХОДИМО (CREATE) =====\n// Невидимая преграда над речкой rm_village (кроме настила моста).\nvisible = false;\n'})
made+=['spr_village_water_block','obj_village_water_block']
yp=f'{P}/max_farm_demo.yyp'; s=open(yp).read(); i=s.index('  "resources":['); j=s.index('\n  ],',i)
kind=lambda n:'tilesets' if n.startswith('tls_') else 'objects' if n.startswith('obj_') else 'sprites'
s=s[:j]+''.join(f'\n    {{"id":{{"name":"{n}","path":"{kind(n)}/{n}/{n}.yy",}},}},' for n in made if f'"{n}"' not in s)+s[j:]
open(yp,'w').write(s)
# ---- тайлы реки ----
O=8   # смещение индексов из-за пустой строки
rnd=lambda c,r,n,salt:int(hashlib.md5(f'{salt}{c},{r}'.encode()).hexdigest(),16)%n
DECO={(5,3):6,(6,6):30,(5,9):7,(6,17):29,(5,19):31,(6,21):6}   # (колонка,ряд): кувшинка/рогоз/камень — редко
vals=[E]*(W*H)
for r in range(H):
    for c in range(C0,C1+1):
        if c==C0: t=11 if rnd(c,r,3,'w')<2 else 15          # трава слева (shore_land_W / _alt)
        elif c==C1: t=9 if rnd(c,r,3,'e')<2 else 13         # трава справа
        else:
            t=DECO.get((c,r)); q=rnd(c,r,10,'wv')
            if t is None: t=0 if q<5 else (53 if q<7 else (1 if q<8 else (2 if q<9 else 54)))
        vals[r*W+c]=t+O
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read()
a0=t.index('    {"$GMRTileLayer":"","%Name":"village_sand_32"'); b0=t.index('\n',t.index('"tilesetId"',a0)); line=t[a0:b0]
m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',line,re.S)
enc=gmtiles.encode(vals); dat=''.join('\n          '+','.join(map(str,enc[n:n+40]))+',' for n in range(0,len(enc),40))+'\n        '
rl=line[:m.start(1)]+dat+line[m.end(1):]
rl=rl.replace('"%Name":"village_sand_32","depth":645','"%Name":"village_river_32","depth":644').replace('"name":"village_sand_32"','"name":"village_river_32"')
rl=rl.replace('"name":"tls_village_sand_roads_32","path":"tilesets/tls_village_sand_roads_32/tls_village_sand_roads_32.yy"','"name":"tls_village_river","path":"tilesets/tls_village_river/tls_village_river.yy"')
assert 'village_river_32' in rl and 'tls_village_river"' in rl
t=t[:a0]+rl+'\n'+t[a0:]
# ---- экземпляры ----
tpl=re.search(r'\{"\$GMRInstance":"v4","%Name":"inst_94745A7".*?"y":[-\d.]+,\}',t,re.S).group(0)
def inst(nm,obj,x,y,sx=1.0,sy=1.0):
    s_=tpl.replace('inst_94745A7',nm)
    s_=re.sub(r'"objectId":\{"name":"\w+","path":"objects/\w+/\w+\.yy",\}',f'"objectId":{{"name":"{obj}","path":"objects/{obj}/{obj}.yy",}}',s_)
    s_=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+',f'"scaleX":{sx},"scaleY":{sy}',s_)
    return nm,re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(x)},"y":{float(y)}',s_)
road_top,road_bot=384,448
ins=[inst('inst_VILLAGE_BRIDGE','obj_village_bridge',BX,BY),inst('inst_VILLAGE_BRIDGE_FRONT','obj_village_bridge_front',BX,BY),
     inst('inst_WATER_BLOCK_N','obj_village_water_block',C0*32,0,(C1-C0+1)*1.0,road_top/32),
     inst('inst_WATER_BLOCK_S','obj_village_water_block',C0*32,road_bot,(C1-C0+1)*1.0,(H*32-road_bot)/32)]
k=t.index('"%Name":"village_concept"'); k=t.index('"instances":[',k)+len('"instances":[')
t=t[:k]+''.join('\n        '+s_+',' for _,s_ in ins)+t[k:]
k=t.index('"instanceCreationOrder":[')+len('"instanceCreationOrder":[')
t=t[:k]+''.join(f'\n    {{"name":"{nm}","path":"rooms/rm_village/rm_village.yy",}},' for nm,_ in ins)+t[k:]
for nm in REMOVE:
    t,k1=re.subn(r'\n *\{"\$GMRInstance":"v4","%Name":"'+nm+r'".*?\},(?=\n)','',t); assert k1==1,nm
    t,k2=re.subn(r'\n *\{"name":"'+nm+r'","path":"rooms/rm_village/rm_village.yy",\},','',t); assert k2==1,nm
open(rp,'w').write(t)
print('создано:',', '.join(made)); print('убрано:',REMOVE)
