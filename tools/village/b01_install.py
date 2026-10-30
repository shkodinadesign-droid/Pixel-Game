# Партия 01: импорт травы/песка в проект и подключение к rm_village.
#  - спрайты+тайлсеты: tls_village_grass_32, tls_village_sand_roads_32 (как прислано, +пустая строка),
#    tls_village_sand_roads_32_grid (раскладка по клеткам комнаты из четвертинок присланных тайлов),
#    tls_village_plaza_curb_v3_olive (копия атласа площади: только фон травы/песка у бордюров
#    перекрашен в цвета партии 01; камень и плитка без изменений);
#  - rm_village: новые слои village_grass_32 / village_sand_32 под ground_concept; в ground_concept
#    остаются только клетки площади, слой переключён на olive-копию (те же индексы).
import sys,os,re,json,glob
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gmtiles,gm_res
P,OUT,TERR,TUFT=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
T=json.load(open(TERR)); W,H=50,23
B=json.load(open(f'{OUT}/b01.json'))
def full(img): return (0,0,len(img[0])-1,len(img)-1)
def tileset(name,spr,count,cols):
    t=open(f'{P}/tilesets/tls_village_plaza_curb_v3/tls_village_plaza_curb_v3.yy').read()
    t=t.replace('spr_village_plaza_curb_v3',spr).replace('tls_village_plaza_curb_v3',name)
    t=re.sub(r'"tile_count":\d+',f'"tile_count":{count}',t); t=re.sub(r'"out_columns":\d+',f'"out_columns":{cols}',t)
    d=f'{P}/tilesets/{name}'; assert not os.path.exists(d),name; os.makedirs(d); open(f'{d}/{name}.yy','w').write(t)
made=[]
for spr,ts,f in [('spr_village_grass_32','tls_village_grass_32','spr_village_grass_32.png'),
                 ('spr_village_sand_roads_32','tls_village_sand_roads_32','spr_village_sand_roads_32.png')]:
    w,h,img=png.read(f'{OUT}/{f}'); gm_res.sprite(P,spr,img,(0,0),full(img)); tileset(ts,spr,(w//32)*(h//32),w//32); made+=[spr,ts]
# olive-копия атласа площади
src=glob.glob(f'{P}/sprites/spr_village_plaza_curb_v3/*.png')[0]; w,h,img=png.read(src); img0=img; aw0=w
hx=lambda s:(int(s[0:2],16),int(s[2:4],16),int(s[4:6],16))
REMAP={'93a25f':'8f9c4b','8f9e5c':'8f9c4b','849254':'809044','819051':'809044',
       'd3a365':'dea55e','d8a96d':'dea55e','c1955d':'cc9752','c4975c':'cc9752'}
REMAP={hx(a):hx(b) for a,b in REMAP.items()}
img=[[(REMAP.get(tuple(p[:3]),tuple(p[:3]))+(p[3],)) if p[3] else p for p in row] for row in img]
gm_res.sprite(P,'spr_village_plaza_curb_v3_olive',img,(0,0),full(img)); tileset('tls_village_plaza_curb_v3_olive','spr_village_plaza_curb_v3_olive',(w//32)*(h//32),11)
made+=['spr_village_plaza_curb_v3_olive','tls_village_plaza_curb_v3_olive']
# пучки травы — только спрайты (origin внизу по центру), в комнату не ставятся
for i in range(1,5):
    w,h,img=png.read(f'{TUFT}/spr_village_grass_tuft_{i}_32.png'); l,t,r_,b=gm_res.opaque(img)
    gm_res.sprite(P,f'spr_village_grass_tuft_{i}',img,(16,31),(l,t,r_,b)); made.append(f'spr_village_grass_tuft_{i}')
# проект
yyp=f'{P}/max_farm_demo.yyp'; s=open(yyp).read(); i=s.index('  "resources":['); j=s.index('\n  ],',i)
kind=lambda n:'tilesets' if n.startswith('tls_') else 'sprites'
s=s[:j]+''.join(f'\n    {{"id":{{"name":"{n}","path":"{kind(n)}/{n}/{n}.yy",}},}},' for n in made if f'"{n}"' not in s)+s[j:]
open(yyp,'w').write(s)
# комната
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read()
a=t.index('{"$GMRTileLayer":"","%Name":"ground_concept"'); b=t.index('\n',t.index('"tilesetId"',a))
line=t[a:b]
m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',line,re.S)
v=gmtiles.decode([int(x) for x in m.group(1).replace('\n','').split(',') if x.strip()],W*H)
E=gmtiles.EMPTY
# клетка остаётся в старом слое, если в ней есть камень (плитка или бордюр); чистая трава/песок — в новые слои
cols=aw0//32; G0={hx('93a25f'),hx('8f9e5c'),hx('849254')}; S0={hx('d3a365'),hx('d8a96d'),hx('c4975c')}
def kind(val):
    k=val&0x7FFFF; sx,sy=(k%cols)*32,(k//cols)*32
    px={tuple(img0[sy+y][sx+x][:3]) for y in range(32) for x in range(32)}
    return 'G' if px<=G0 else 'S' if px<=S0 else 'K'
K=[kind(x) for x in v]
newv=[v[k] if K[k]=='K' else E for k in range(W*H)]
import hashlib
rnd=lambda c,r,n,salt:int(hashlib.md5(f'{salt}{c},{r}'.encode()).hexdigest(),16)%n
def sand_tile(k):
    c,r=k%W,k//W; q=rnd(c,r,10,'sv'); return 4+(15 if q<6 else 16+(q-6))   # центр песка: mask_15 или варианты 16-19 (+4 пустая строка)
print('клеток: старый слой',K.count('K'),' трава',K.count('G'),' песок',K.count('S'))
def data(vals):
    enc=gmtiles.encode(vals); s=''
    for n in range(0,len(enc),40): s+='\n          '+','.join(map(str,enc[n:n+40]))+','
    return s+'\n        '
def with_data(ln,vals): return ln[:m.start(1)]+data(vals)+ln[m.end(1):] if ln is line else None
gc=line[:m.start(1)]+data(newv)+line[m.end(1):]
gc=gc.replace('"name":"tls_village_plaza_curb_v3","path":"tilesets/tls_village_plaza_curb_v3/tls_village_plaza_curb_v3.yy"',
              '"name":"tls_village_plaza_curb_v3_olive","path":"tilesets/tls_village_plaza_curb_v3_olive/tls_village_plaza_curb_v3_olive.yy"')
assert 'curb_v3_olive' in gc
def layer(name,depth,ts,vals):
    ln=line[:m.start(1)]+data(vals)+line[m.end(1):]
    ln=ln.replace('"%Name":"ground_concept","depth":640',f'"%Name":"{name}","depth":{depth}').replace('"name":"ground_concept"',f'"name":"{name}"')
    ln=ln.replace('"name":"tls_village_plaza_curb_v3","path":"tilesets/tls_village_plaza_curb_v3/tls_village_plaza_curb_v3.yy"',
                  f'"name":"{ts}","path":"tilesets/{ts}/{ts}.yy"')
    assert f'"{name}"' in ln and ts in ln and '"visible":true' in ln; return ln
sand=[sand_tile(k) if K[k]=='S' else E for k in range(W*H)]
grass=[B['grass_grid'][k//W][k%W] for k in range(W*H)]
new=gc+'\n    '+layer('village_sand_32',645,'tls_village_sand_roads_32',sand)+'\n    '+layer('village_grass_32',648,'tls_village_grass_32',grass)
t=t[:a]+new+t[b:]
open(rp,'w').write(t)
print('создано:',', '.join(made))
