# Кот Мэгги: спит на крыше её дома (art_incoming/characters/maggie_cat/maggie_cat_sleep.png, ~75 px «пикселей» в ширину).
# Размер — как у Кекса (спящий Кекс ~22x24): кот 32x20 вместе с контуром.
# Уменьшение: силуэт берётся по светлой шёрстке (контур и свечение исходника при уменьшении рвались), затем вокруг
# силуэта рисуется новый контур в 1 px. Внутри блока тёмные пиксели (глаза, линии лап) важнее светлых.
# После уменьшения — ручные правки: глаза и нос по одному штриху, обрывки усов и выступы контура убраны.
# Анимация «дышит»: спина (колонки BACK и правее) на вдохе поднимается на 1 px — верхняя половина
# сдвигается вверх, средняя строка дублируется, так что дыр нет. Голова неподвижна.
import sys,os
sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','village')); import png
SRC,OUT=sys.argv[1],sys.argv[2]; P=sys.argv[3] if len(sys.argv)>3 else None   # P — папка проекта: установить
W,DT,K=30,0.3,9; OL=(84,46,35,255); BACK=19
ROOF=(392,474)   # место на крыше дома Мэгги (дом: низ по центру 416,640; левый скат у конька)
w,h,p=png.read(SRC)
lum=lambda c:0.3*c[0]+0.59*c[1]+0.11*c[2]
out=[[False]*w for _ in range(h)]; st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
for x,y in st: out[y][x]=True
while st:
    x,y=st.pop()
    for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=nx<w and 0<=ny<h and not out[ny][nx] and lum(p[ny][nx])<130: out[ny][nx]=True; st.append((nx,ny))
ys=[y for y in range(h) for x in range(0,w,3) if not out[y][x]]; xs=[x for y in range(0,h,3) for x in range(w) if not out[y][x]]
X0,X1,Y0,Y1=min(xs),max(xs)+1,min(ys),max(ys)+1; B=(X1-X0)/W; H=round((Y1-Y0)/B)
img=[[(0,0,0,0)]*(W+2) for _ in range(H+2)]
for j in range(H):
    for i in range(W):
        ya,yb,xa,xb=int(Y0+j*B),min(h,int(Y0+(j+1)*B)),int(X0+i*B),min(w,int(X0+(i+1)*B))
        px=[p[y][x][:3] for y in range(ya,yb) for x in range(xa,xb) if not out[y][x]]
        if len(px)<0.5*(yb-ya)*(xb-xa): continue
        dark=[c for c in px if lum(c)<120]; pink=[c for c in px if lum(c)>=120 and c[0]-c[2]>70]
        g=dark if len(dark)>=DT*len(px) else pink if len(pink)>=0.3*len(px) else [c for c in px if lum(c)>=120] or px
        img[j+1][i+1]=tuple(round(sum(c[k] for c in g)/len(g)) for k in range(3))+(255,)
CW,CH=W+2,H+2
for x,y in [(x,y) for y in range(CH) for x in range(CW) if not img[y][x][3] and any(0<=x+dx<CW and 0<=y+dy<CH and img[y+dy][x+dx][3] for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)))]:
    img[y][x]=OL
assert (CW,CH)==(32,20),(CW,CH)
# ручные правки (координаты в готовом 32x20)
from collections import Counter
FUR=Counter(c for r in img for c in r if c[3] and lum(c)>=200).most_common(1)[0][0]
EYE=Counter(c for r in img for c in r if c[3] and lum(c)<120 and c!=OL).most_common(1)[0][0]
NOSE=max((c for r in img for c in r if c[3] and c[0]-c[2]>70),key=lambda c:c[0]-c[1])
for x,y in [(16,11),(18,11),(19,10),(14,14),(27,14),(5,15),(6,16),(13,14),(7,17),(8,17),(14,12),(15,12)]: img[y][x]=FUR   # усы, обрывки
img[3][9]=(0,0,0,0); img[4][9]=OL; img[18][8]=OL                       # выступы контура
for x,y in [(7,14),(8,14),(9,14),(10,14)]: img[y][x]=EYE                # левый глаз (закрыт)
for x,y in [(14,11),(15,12),(16,12),(17,11)]: img[y][x]=EYE             # правый глаз (закрыт, дугой)
img[13][13]=NOSE
img[9][21]=FUR                                                          # тёмная точка на спине
# палитра: контур, глаза и нос — как есть, остальное сводится к K цветам
from b06_nature_convert import kmeans
keep={OL,EYE,NOSE}; pts=[c[:3] for r in img for c in r if c[3] and c not in keep]; cent=kmeans(pts,K)
near={q:min(cent,key=lambda c:sum((c[i]-q[i])**2 for i in range(3))) for q in set(pts)}
img=[[c if not c[3] or c in keep else near[c[:3]]+(255,) for c in r] for r in img]
def breathe(f):
    g=[r[:] for r in f]; mid=CH//2
    for x in range(BACK,CW):
        for y in range(0,mid): g[y][x]=f[y+1][x]
    return g
frames=[img,img,breathe(img),breathe(img)]   # выдох — пауза — вдох — пауза
os.makedirs(OUT,exist_ok=True)
for i,f in enumerate(frames): png.write(f'{OUT}/frame_{i:02d}.png',CW,CH,f)
print('кот',CW,'x',CH,'цветов',len(set(c for r in img for c in r if c[3])))

if P:
    # спрайт spr_maggie_cat_sleep (4 кадра, начало — низ по центру, 2 кадра/с) по образцу spr_kitten_sit_strip4,
    # объект obj_maggie_cat и экземпляр на крыше дома Мэгги в rm_village (слой Instances)
    import re,uuid; sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','village')); import gm_res
    name,obj,T='spr_maggie_cat_sleep','obj_maggie_cat','spr_kitten_sit_strip4'
    d=f'{P}/sprites/{name}'; assert not os.path.exists(d)
    y=open(f'{P}/sprites/{T}/{T}.yy').read().replace(T,name)
    fr=re.findall(r'\n    \{"\$GMSpriteFrame".*?\},',y); y=y.replace(fr[-1],'')
    kf=re.findall(r'\n            \{"\$Keyframe<SpriteFrameKeyframe>".*?"Stretch":false,\},',y,re.S); y=y.replace(kf[-1],'')
    ids=re.findall(r'"name":"([0-9a-f-]{36})","resourceType":"GMSpriteFrame"',y); lid=re.search(r'"\$GMImageLayer":"","%Name":"([0-9a-f-]{36})"',y).group(1)
    for u in set(re.findall(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',y)): y=y.replace(u,str(uuid.uuid4()))
    ids=re.findall(r'"name":"([0-9a-f-]{36})","resourceType":"GMSpriteFrame"',y); lid=re.search(r'"\$GMImageLayer":"","%Name":"([0-9a-f-]{36})"',y).group(1)
    bb=gm_res.opaque(img)
    for k,v in [('bboxMode',0),('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',CW),('height',CH),('origin',7),('xorigin',CW//2),('yorigin',CH-1)]:
        y,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',y); assert n>=1,k
    y=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{CH}.0',y); y=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{CW}.0',y)
    y=y.replace('"length":5.0','"length":4.0').replace('"playbackSpeed":30.0','"playbackSpeed":2.0')
    y=y.replace('"name":"Keks",\n    "path":"folders/Sprites/characters/Keks.yy"','"name":"Maggie",\n    "path":"folders/Sprites/characters/Maggie.yy"')
    assert len(ids)==4 and '"playbackSpeed":2.0' in y and 'characters/Maggie.yy' in y
    for u,f in zip(ids,frames):
        os.makedirs(f'{d}/layers/{u}',exist_ok=True); png.write(f'{d}/{u}.png',CW,CH,f); png.write(f'{d}/layers/{u}/{lid}.png',CW,CH,f)
    open(f'{d}/{name}.yy','w').write(y)
    gm_res.obj(P,obj,name,None,events={(0,0,'Create_0.gml'):
        '// ===== КОТ МЭГГИ — CREATE =====\n// Спит на крыше дома Мэгги и тихонько дышит (анимация спрайта, 2 кадра/с).\n'
        '// Рисуется сразу над домом: глубина на 1 меньше глубины слоя.\ndepth = layer_get_depth(layer) - 1;\n'},solid=False)
    gm_res.add_to_yyp(P,[name,obj])
    rp=f'{P}/rooms/rm_village/rm_village.yy'; r=open(rp).read(); assert obj not in r
    m=re.search(r'\{"\$GMRInstance":"v4","%Name":"inst_3F64F4CE".*?\},(?=\n)',r).group(0)   # дом Мэгги — образец строки
    line=re.sub(r'"%Name":"inst_3F64F4CE"','"%Name":"inst_MAGGIE_CAT"',m).replace('"name":"inst_3F64F4CE"','"name":"inst_MAGGIE_CAT"')
    line=re.sub(r'"objectId":\{"name":"obj_maggie_house","path":"objects/obj_maggie_house/obj_maggie_house.yy",\}','"objectId":{"name":"obj_maggie_cat","path":"objects/obj_maggie_cat/obj_maggie_cat.yy",}',line)
    line=re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(ROOF[0])},"y":{float(ROOF[1])}',line); assert 'obj_maggie_cat' in line
    r=r.replace(m,m+'\n        '+line,1)
    k=r.index('{"name":"inst_3F64F4CE","path":"rooms/rm_village/rm_village.yy",},')
    r=r.replace('{"name":"inst_3F64F4CE","path":"rooms/rm_village/rm_village.yy",},','{"name":"inst_3F64F4CE","path":"rooms/rm_village/rm_village.yy",},\n    {"name":"inst_MAGGIE_CAT","path":"rooms/rm_village/rm_village.yy",},',1)
    open(rp,'w').write(r); print('установлен',name,obj,'на',ROOF)
