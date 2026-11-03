# Партия 06: перерасстановка природы в rm_village по мастер-сцене.
# Убираются старые общие деревья/кусты (дуб, клён, ель, bush, bush_2); яблоня и груша (квест) остаются.
# Порядок: крупные деревья -> ели -> кусты -> цветы -> трава. Здания, дороги, плитка, речка, мост, площадь не трогаются.
# Деревья и кусты — по краям и группами, середина и проходы свободны. Трава и мелкие цветы — случайно (seed),
# только на траве, не ближе 12 px к дороге/площади/воде и не под кронами и зданиями.
import sys,os,re,random
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import yy,gmtiles
P=sys.argv[1]; rp=f'{P}/rooms/rm_village/rm_village.yy'
REMOVE_OBJ={'obj_tree_oak','obj_tree_maple','obj_tree_pine','obj_village_bush','obj_village_bush_2'}
# (объект, x, y) — x,y = основание ствола / низ куста или цветка
TREES=[('obj_vn_tree_01',56,120),('obj_vn_tree_02',580,124),('obj_vn_tree_03',768,204),('obj_vn_tree_04',1120,150),
       ('obj_vn_tree_01',1544,132),('obj_vn_tree_02',720,730),('obj_vn_tree_04',968,724),('obj_vn_tree_03',1316,704),
       ('obj_vn_tree_02',1548,734)]
PINES=[('obj_vn_pine_06',300,84),('obj_vn_pine_05',662,120),('obj_vn_pine_07',1204,70),('obj_vn_pine_06',1566,262),
       ('obj_vn_pine_05',40,268),('obj_vn_pine_07',46,616),('obj_vn_pine_06',648,700),('obj_vn_pine_05',842,640),
       ('obj_vn_pine_07',1570,604)]
BUSHES=[('obj_vn_bush_01',480,346),('obj_vn_bush_03',590,342),('obj_vn_bush_05',530,264),('obj_vn_bush_04',284,644),
        ('obj_vn_bush_02',576,664),('obj_vn_bush_06',1552,524),('obj_vn_bush_02',30,724),('obj_vn_bush_03',1000,124),
        ('obj_vn_bush_06',1300,86),('obj_vn_bush_05',890,720)]
FLOWERS=[('obj_vn_flower_01',296,272),('obj_vn_flower_09',448,286),('obj_vn_flower_04',552,650),('obj_vn_flower_13',284,700),
         ('obj_vn_flower_11',1236,586),('obj_vn_flower_02',1036,700),('obj_vn_flower_05',100,560),('obj_vn_flower_06',762,600),
         ('obj_vn_flower_03',1440,600),('obj_vn_flower_12',620,320),('obj_vn_flower_14',1478,112)]
N_GRASS,N_ACCENT=30,16
d=yy.load(rp); W,H=d['roomSettings']['Width'],d['roomSettings']['Height']
def objspr(o):
    t=yy.load(f'{P}/objects/{o}/{o}.yy'); return t['spriteId']['name'] if t.get('spriteId') else None
def box(o,x,y,sx=1,sy=1):
    s=objspr(o)
    if not s: return None
    t=yy.load(f'{P}/sprites/{s}/{s}.yy'); q=t['sequence']
    x0=x-q['xorigin']*sx; y0=y-q['yorigin']*sy; return (x0,y0,x0+t['width']*sx,y0+t['height']*sy)
# занятые места: всё, кроме убираемой зелени и невидимых преград воды (вода учтена тайлами)
blocked=[]
for L in d['layers']:
    for i in L.get('instances') or []:
        o=i['objectId']['name']
        if o in REMOVE_OBJ or o.startswith('obj_vn_') or o in ('obj_forest_blocker','obj_village_water_block'): continue
        b=box(o,i['x'],i['y'],i['scaleX'],i['scaleY'])
        if b: blocked.append(b)
        else: blocked.append((i['x']-24,i['y']-48,i['x']+24,i['y']+16))   # точки входа/выхода, NPC без спрайта
free=[[True]*(W//4) for _ in range(H//4)]   # сетка 4 px: трава без дороги/площади/воды
for L in d['layers']:
    if L['name'] in ('village_sand_32','village_plaza_32','village_curbs_32','village_river_32','village_plaza_ring_32'):
        td=L['tiles']; TW,TH=td['SerialiseWidth'],td['SerialiseHeight']; v=gmtiles.decode(td['TileCompressedData'],TW*TH)
        for k,val in enumerate(v):
            if val!=gmtiles.EMPTY and (val&0x7FFFF):
                r,c=divmod(k,TW)
                for yy4 in range(max(0,r*8-3),min(H//4,r*8+11)):
                    for xx4 in range(max(0,c*8-3),min(W//4,c*8+11)): free[yy4][xx4]=False
greens=TREES+PINES+BUSHES+FLOWERS
for o,x,y in greens: blocked.append(box(o,x,y))
def ok(x,y,pad=4):
    if not (8<=x<W-8 and 16<=y<H-4) or not free[int(y)//4][int(x)//4]: return False
    return not any(b[0]-pad<=x<=b[2]+pad and b[1]-pad<=y<=b[3]+pad for b in blocked)
for o,x,y in FLOWERS: assert free[y//4][x//4],('цветы на дороге',o,x,y)
random.seed(6); pts=[(x,y) for _,x,y in FLOWERS]; small=[]
def scatter(n,objs,mind):
    tries=0
    while n and tries<20000:
        tries+=1; x,y=random.randrange(8,W-8),random.randrange(16,H-4)
        if ok(x,y) and all((x-a)**2+(y-b)**2>=mind**2 for a,b in pts):
            o=objs[len(small)%len(objs)]; small.append((o,x,y)); pts.append((x,y)); n-=1
GRASS=[f'obj_vn_grass_{k:02d}' for k in range(1,18)]
ACC=[f'obj_vn_flower_{k:02d}' for k in (7,8,10,15,16,17,18,19,20,21,22,23,24,25,26,27,28)]
scatter(N_GRASS,GRASS,64); g=len(small); scatter(N_ACCENT,ACC,52)
print('трава',g,'акценты',len(small)-g)
place=greens+small
# ---- запись в комнату ----
t=open(rp).read()
tpl=re.search(r'\{"\$GMRInstance":"v4","%Name":"inst_94745A7".*?"y":[-\d.]+,\}',t,re.S).group(0)
removed=[]
for nm,o in re.findall(r'\{"\$GMRInstance":"v4","%Name":"(\w+)".*?"objectId":\{"name":"(\w+)"',t):
    if o in REMOVE_OBJ or o.startswith('obj_vn_'): removed.append(nm)
for nm in removed:
    t,k1=re.subn(r'\n *\{"\$GMRInstance":"v4","%Name":"'+nm+r'".*?\},(?=\n)','',t); assert k1==1,nm
    t,k2=re.subn(r'\n *\{"name":"'+nm+r'","path":"rooms/rm_village/rm_village.yy",\},','',t); assert k2==1,nm
ins=[]
for n,(o,x,y) in enumerate(place):
    nm=f'inst_VN_{n:03d}'
    s_=tpl.replace('inst_94745A7',nm)
    s_=re.sub(r'"objectId":\{"name":"\w+","path":"objects/\w+/\w+\.yy",\}',f'"objectId":{{"name":"{o}","path":"objects/{o}/{o}.yy",}}',s_)
    ins.append((nm,re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(x)},"y":{float(y)}',s_)))
k=t.index('"%Name":"village_concept"'); k=t.index('"instances":[',k)+len('"instances":[')
t=t[:k]+''.join('\n        '+s_+',' for _,s_ in ins)+t[k:]
k=t.index('"instanceCreationOrder":[')+len('"instanceCreationOrder":[')
t=t[:k]+''.join(f'\n    {{"name":"{nm}","path":"rooms/rm_village/rm_village.yy",}},' for nm,_ in ins)+t[k:]
open(rp,'w').write(t)
print('убрано',len(removed),'поставлено',len(ins),'(деревья',len(TREES),'ели',len(PINES),'кусты',len(BUSHES),'клумбы',len(FLOWERS),')')
