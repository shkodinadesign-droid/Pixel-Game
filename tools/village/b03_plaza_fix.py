# Доводка площади до MASTER: без зелёного квадрата, единая плитка главной площади и площади у лавки Ивана,
# низ обеих площадей на одной линии, круг с клумбой в центре, доска объявлений в левый нижний угол,
# зелёные лунки справа убраны.
import sys,os,re,json,hashlib,shutil
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import gmtiles
P,OUT,TIN,TOUT=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
T=[list(r) for r in json.load(open(TIN))]; W,H=50,23; E=gmtiles.EMPTY
def setr(t,c0,c1,r0,r1):
    for r in range(r0,r1+1):
        for c in range(c0,c1+1): T[r][c]=t
setr('P',22,25,11,13)   # зелёный квадрат -> плитка
setr('P',37,37,9,15)    # песчаная полоса между площадями -> плитка (одна площадь)
setr('P',21,36,15,15)   # низ главной площади на одной линии с площадью Ивана (ряд 15)
json.dump([''.join(r) for r in T],open(TOUT,'w'))
B=json.load(open(f'{OUT}/b02.json')); LUT=B['lut']; RING0=B['ring0']
RANK={'G':0,'S':1,'P':2}
rnd=lambda c,r,n,salt:int(hashlib.md5(f'{salt}{c},{r}'.encode()).hexdigest(),16)%n
def ty(c,r): return T[r][c] if 0<=c<W and 0<=r<H else None
plaza=[E]*(W*H); curbs=[E]*(W*H); sand=[E]*(W*H); ring=[E]*(W*H)
for r in range(H):
    for c in range(W):
        t=T[r][c]
        if t=='P': plaza[r*W+c]=1+rnd(c,r,4,'pf')
        if t=='S': q=rnd(c,r,10,'sv'); sand[r*W+c]=4+(15 if q<6 else 16+(q-6))
        if t=='G': continue
        low={}
        for k,(dx,dy) in {'N':(0,-1),'E':(1,0),'S':(0,1),'W':(-1,0),'NE':(1,-1),'SE':(1,1),'SW':(-1,1),'NW':(-1,-1)}.items():
            u=ty(c+dx,r+dy); low[k]=(u is not None and RANK[u]<RANK[t]); low[k+'t']=u
        for dg,a_,b_ in (('NE','N','E'),('SE','S','E'),('SW','S','W'),('NW','N','W')):
            if low[a_] or low[b_]: low[dg]=False
        key=','.join(k for k in ['E','N','NE','NW','S','SE','SW','W'] if low[k])
        if not key: continue
        lows=[low[k+'t'] for k in ('N','E','S','W') if low[k]]
        curbs[r*W+c]=LUT[('sand' if 'S' in lows else 'grass')+'|'+key]
# круг 4x4: колонки 28-31, ряды 11-14 (центр 960,416 — под дверью магазина, между фонарями)
RC,RR=28,11
for dr in range(4):
    for dc in range(4):
        assert T[RR+dr][RC+dc]=='P'; ring[(RR+dr)*W+RC+dc]=RING0+dr*8+dc
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read()
def set_layer(t,name,vals):
    a=t.index('{"$GMRTileLayer":"","%Name":"'+name+'"'); b=t.index('\n',t.index('"tilesetId"',a)); line=t[a:b]
    m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',line,re.S)
    enc=gmtiles.encode(vals); s=''.join('\n          '+','.join(map(str,enc[n:n+40]))+',' for n in range(0,len(enc),40))+'\n        '
    return t[:a]+line[:m.start(1)]+s+line[m.end(1):]+t[b:]
for n,v in (('village_plaza_32',plaza),('village_curbs_32',curbs),('village_sand_32',sand)): t=set_layer(t,n,v)
# слой кольца — копия слоя бордюров
a=t.index('    {"$GMRTileLayer":"","%Name":"village_curbs_32"'); b=t.index('\n',t.index('"tilesetId"',a)); line=t[a:b]
rl=line.replace('"%Name":"village_curbs_32","depth":638','"%Name":"village_plaza_ring_32","depth":636').replace('"name":"village_curbs_32"','"name":"village_plaza_ring_32"')
assert 'village_plaza_ring_32' in rl and 'village_curbs_32' not in rl
t=t[:a]+rl+'\n'+t[a:]; t=set_layer(t,'village_plaza_ring_32',ring)
# лунки — убрать экземпляры и ресурсы
for n in (0,1):
    nm=f'inst_PLAZA_GRASS_SPOT_{n}'
    t,k1=re.subn(r'\n *\{"\$GMRInstance":"v4","%Name":"'+nm+r'".*?\},(?=\n)','',t); assert k1==1,nm
    t,k2=re.subn(r'\n *\{"name":"'+nm+r'","path":"rooms/rm_village/rm_village.yy",\},','',t); assert k2==1,nm
# доска объявлений: левый нижний угол главной площади
t,k=re.subn(r'("objectId":\{"name":"obj_village2_notice_board"[^}]*\},.*?"x":)768\.0,"y":448\.0',r'\g<1>752.0,"y":496.0',t,count=1,flags=re.S); assert k==1
# клумба в центре круга
tpl=re.search(r'\{"\$GMRInstance":"v4","%Name":"inst_94745A7".*?"y":[-\d.]+,\}',t,re.S).group(0)
nm='inst_PLAZA_FLOWERBED'
s_=tpl.replace('inst_94745A7',nm)
s_=re.sub(r'"objectId":\{"name":"\w+","path":"objects/\w+/\w+\.yy",\}','"objectId":{"name":"obj_village_plaza_flowerbed","path":"objects/obj_village_plaza_flowerbed/obj_village_plaza_flowerbed.yy",}',s_)
s_=re.sub(r'"x":[-\d.]+,"y":[-\d.]+','"x":960.0,"y":449.0',s_)
k=t.index('"%Name":"village_concept"'); k=t.index('"instances":[',k)+len('"instances":[')
t=t[:k]+'\n        '+s_+','+t[k:]
k=t.index('"instanceCreationOrder":[')+len('"instanceCreationOrder":[')
t=t[:k]+f'\n    {{"name":"{nm}","path":"rooms/rm_village/rm_village.yy",}},'+t[k:]
open(rp,'w').write(t)
yp=f'{P}/max_farm_demo.yyp'; y=open(yp).read()
for n,kd in (('obj_village_plaza_grass_spot','objects'),('spr_village_plaza_grass_spot','sprites')):
    y,k=re.subn(r'\n *\{"id":\{"name":"'+n+r'","path":"[^"]+",\},\},','',y); assert k==1,n
    shutil.rmtree(f'{P}/{kd}/{n}')
open(yp,'w').write(y)
for r in range(6,18): print(f'{r:2d}',''.join(T[r]).replace('G','.'))
