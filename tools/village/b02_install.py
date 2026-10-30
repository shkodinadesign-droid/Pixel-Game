# Этап 2 + 3А: подключение плитки и бордюров к rm_village.
#  tls_village_plaza_32 (заливка, бордюры blob-47, кольцо); слои village_plaza_32 (642) и village_curbs_32 (638);
#  старый ground_concept скрыт (не удалён). Две зелёные «лунки» правой площади перенесены декалью.
#  Клумба-центр: спрайт+объект созданы, в комнату не ставятся (на текущей площади кольцо не помещается).
import sys,os,re,json,glob,math,hashlib
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gmtiles,gm_res,yy
P,OUT,TERR=sys.argv[1],sys.argv[2],sys.argv[3]
T=json.load(open(TERR)); W,H=50,23; E=gmtiles.EMPTY
B=json.load(open(f'{OUT}/b02.json')); LUT=B['lut']
def full(img): return (0,0,len(img[0])-1,len(img)-1)
def tileset(name,spr,count,cols):
    t=open(f'{P}/tilesets/tls_village_plaza_curb_v3/tls_village_plaza_curb_v3.yy').read()
    t=t.replace('spr_village_plaza_curb_v3',spr).replace('tls_village_plaza_curb_v3',name)
    t=re.sub(r'"tile_count":\d+',f'"tile_count":{count}',t); t=re.sub(r'"out_columns":\d+',f'"out_columns":{cols}',t)
    d=f'{P}/tilesets/{name}'; assert not os.path.exists(d),name; os.makedirs(d); open(f'{d}/{name}.yy','w').write(t)
made=[]
w,h,img=png.read(f'{OUT}/spr_village_plaza_32.png'); gm_res.sprite(P,'spr_village_plaza_32',img,(0,0),full(img))
tileset('tls_village_plaza_32','spr_village_plaza_32',(w//32)*(h//32),w//32); made+=['spr_village_plaza_32','tls_village_plaza_32']
# клумба в центре круга: origin внизу по центру, маска — кадка
w,h,img=png.read(f'{OUT}/spr_village_plaza_flowerbed.png')
gm_res.sprite(P,'spr_village_plaza_flowerbed',img,(w//2,h-1),(6,h-26,w-7,h-3))
gm_res.obj(P,'obj_village_plaza_flowerbed','spr_village_plaza_flowerbed','obj_village_prop'); made+=['spr_village_plaza_flowerbed','obj_village_plaza_flowerbed']
# зелёные лунки правой площади — из старой земли (ground_concept), центр в углу тайла
r=yy.load(P+'/rooms/rm_village/rm_village.yy')
L=[l for l in r['layers'] if l['%Name']=='ground_concept'][0]
v=gmtiles.decode(L['tiles']['TileCompressedData'],W*H)
f=glob.glob(P+'/sprites/spr_village_plaza_curb_v3_olive/*.png')[0]; aw,ah,a=png.read(f); acols=aw//32
hx=lambda s:(int(s[0:2],16),int(s[2:4],16),int(s[4:6],16))
KEEP={hx('8f9c4b'):hx('8f9c4b'),hx('809044'):hx('809044'),hx('aa9d88'):(150,116,80),hx('bfb29d'):(185,151,111),
      hx('cbbea9'):(219,187,148),hx('e0d3bc'):(220,189,150)}
def pix(X,Y):
    c,rw=X//32,Y//32; k=v[rw*W+c]&0x7FFFF; return tuple(a[(k//acols)*32+Y%32][(k%acols)*32+X%32][:3])
spot=[[(KEEP[pix(1376-16+x,352-16+y)]+(255,)) if pix(1376-16+x,352-16+y) in KEEP else (0,0,0,0) for x in range(32)] for y in range(32)]
spot2=[[(KEEP[pix(1376-16+x,416-16+y)]+(255,)) if pix(1376-16+x,416-16+y) in KEEP else (0,0,0,0) for x in range(32)] for y in range(32)]
assert spot==spot2, 'лунки различаются'
gm_res.sprite(P,'spr_village_plaza_grass_spot',spot,(16,16),gm_res.opaque(spot))
gm_res.obj(P,'obj_village_plaza_grass_spot','spr_village_plaza_grass_spot',None,
           events={(0,0,'Create_0.gml'):'// ===== ЗЕЛЁНАЯ ЛУНКА В ПЛИТКЕ (CREATE) =====\n// Рисунок на земле площади: над плиткой и бордюрами, под всеми предметами. Не препятствие.\ndepth = 630;\n'},solid=False)
made+=['spr_village_plaza_grass_spot','obj_village_plaza_grass_spot']
yyp=f'{P}/max_farm_demo.yyp'; s=open(yyp).read(); i=s.index('  "resources":['); j=s.index('\n  ],',i)
kind=lambda n:'tilesets' if n.startswith('tls_') else 'objects' if n.startswith('obj_') else 'sprites'
s=s[:j]+''.join(f'\n    {{"id":{{"name":"{n}","path":"{kind(n)}/{n}/{n}.yy",}},}},' for n in made if f'"{n}"' not in s)+s[j:]
open(yyp,'w').write(s)
# ---- раскладка ----
RANK={'G':0,'S':1,'P':2}
def ty(c,rw):
    if 0<=c<W and 0<=rw<H: return T[rw][c]
    return None
rnd=lambda c,rw,n,salt:int(hashlib.md5(f'{salt}{c},{rw}'.encode()).hexdigest(),16)%n
plaza=[E]*(W*H); curbs=[E]*(W*H); stats={}
for rw in range(H):
    for c in range(W):
        t=T[rw][c]
        if t=='P': plaza[rw*W+c]=1+rnd(c,rw,4,'pf')
        if t=='G': continue
        low={}
        for k,(dx,dy) in {'N':(0,-1),'E':(1,0),'S':(0,1),'W':(-1,0),'NE':(1,-1),'SE':(1,1),'SW':(-1,1),'NW':(-1,-1)}.items():
            u=ty(c+dx,rw+dy); low[k]=(u is not None and RANK[u]<RANK[t]); low[k+'t']=u
        for dg,a_,b_ in (('NE','N','E'),('SE','S','E'),('SW','S','W'),('NW','N','W')):
            if low[a_] or low[b_]: low[dg]=False
        key=','.join(k for k in ['E','N','NE','NW','S','SE','SW','W'] if low[k])
        if not key: continue
        # цвет снаружи внешних углов: песок, если хоть один из «низших» соседей песок
        lows=[low[k+'t'] for k in ('N','E','S','W') if low[k]]
        lo='sand' if 'S' in lows else 'grass'
        curbs[rw*W+c]=LUT[f'{lo}|{key}']; stats[key]=stats.get(key,0)+1
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read()
a0=t.index('{"$GMRTileLayer":"","%Name":"ground_concept"'); b0=t.index('\n',t.index('"tilesetId"',a0)); line=t[a0:b0]
m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',line,re.S)
def data(vals):
    enc=gmtiles.encode(vals); s=''
    for n in range(0,len(enc),40): s+='\n          '+','.join(map(str,enc[n:n+40]))+','
    return s+'\n        '
def layer(name,depth,ts,vals):
    ln=line[:m.start(1)]+data(vals)+line[m.end(1):]
    ln=ln.replace('"%Name":"ground_concept","depth":640',f'"%Name":"{name}","depth":{depth}').replace('"name":"ground_concept"',f'"name":"{name}"')
    ln=ln.replace('"name":"tls_village_plaza_curb_v3_olive","path":"tilesets/tls_village_plaza_curb_v3_olive/tls_village_plaza_curb_v3_olive.yy"',
                  f'"name":"{ts}","path":"tilesets/{ts}/{ts}.yy"')
    assert f'"{name}"' in ln and ts in ln and '"visible":true' in ln; return ln
hidden=line.replace('"visible":true','"visible":false',1); assert hidden!=line
t=t[:a0]+layer('village_curbs_32',638,'tls_village_plaza_32',curbs)+'\n    '+hidden+'\n    '+layer('village_plaza_32',642,'tls_village_plaza_32',plaza)+t[b0:]
# декали-лунки — в слой village_concept, рядом с остальным декором
tpl=re.search(r'\{"\$GMRInstance":"v4","%Name":"inst_[A-Z0-9_]+".*?"y":[-\d.]+,\}',t,re.S).group(0)
ins=[]
for n,(x,y) in enumerate([(1376,352),(1376,416)]):
    nm=f'inst_PLAZA_GRASS_SPOT_{n}'; s_=tpl
    s_=re.sub(r'"%Name":"inst_[A-Z0-9_]+"',f'"%Name":"{nm}"',s_); s_=re.sub(r'"name":"inst_[A-Z0-9_]+"',f'"name":"{nm}"',s_)
    s_=re.sub(r'"objectId":\{"name":"\w+","path":"objects/\w+/\w+\.yy",\}',f'"objectId":{{"name":"obj_village_plaza_grass_spot","path":"objects/obj_village_plaza_grass_spot/obj_village_plaza_grass_spot.yy",}}',s_)
    s_=re.sub(r'"x":[-\d.]+',f'"x":{x}.0',s_); s_=re.sub(r'"y":[-\d.]+,\}',f'"y":{y}.0,}}',s_)
    s_=re.sub(r'"scaleX":[-\d.]+','"scaleX":1.0',s_); s_=re.sub(r'"scaleY":[-\d.]+','"scaleY":1.0',s_); s_=re.sub(r'"rotation":[-\d.]+','"rotation":0.0',s_)
    s_=re.sub(r'"hasCreationCode":true','"hasCreationCode":false',s_)
    ins.append((nm,s_))
k=t.index('"%Name":"village_concept"'); k=t.index('"instances":[',k)+len('"instances":[')
t=t[:k]+''.join('\n        '+s_+',' for _,s_ in ins)+t[k:]
k=t.index('"instanceCreationOrder":[')+len('"instanceCreationOrder":[')
t=t[:k]+''.join(f'\n    {{"name":"{nm}","path":"rooms/rm_village/rm_village.yy",}},' for nm,_ in ins)+t[k:]
open(rp,'w').write(t)
print('создано:',', '.join(made)); print('бордюров по видам:',len(stats))
