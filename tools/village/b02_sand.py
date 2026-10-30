# Слой village_sand_32: песок во всех клетках S (центр mask_15 + варианты 16-19, индекс GM = CSV + 4),
# т.к. старый ground_concept (где были краевые клетки дорог) теперь скрыт.
import sys,os,re,json,hashlib
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import gmtiles
P,TERR=sys.argv[1],sys.argv[2]; T=json.load(open(TERR)); W,H=50,23; E=gmtiles.EMPTY
rnd=lambda c,r,n,salt:int(hashlib.md5(f'{salt}{c},{r}'.encode()).hexdigest(),16)%n
def st(k):
    c,r=k%W,k//W; q=rnd(c,r,10,'sv'); return 4+(15 if q<6 else 16+(q-6))
vals=[st(k) if T[k//W][k%W]=='S' else E for k in range(W*H)]
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read()
a=t.index('{"$GMRTileLayer":"","%Name":"village_sand_32"'); b=t.index('\n',t.index('"tilesetId"',a)); line=t[a:b]
m=re.search(r'"TileCompressedData":\[(.*?)\],"TileDataFormat"',line,re.S)
enc=gmtiles.encode(vals); s=''.join('\n          '+','.join(map(str,enc[n:n+40]))+',' for n in range(0,len(enc),40))+'\n        '
t=t[:a]+line[:m.start(1)]+s+line[m.end(1):]+t[b:]; open(rp,'w').write(t)
print('клеток песка',sum(v!=E for v in vals))
