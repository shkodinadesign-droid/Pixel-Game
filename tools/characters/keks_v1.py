# Кекс v1: лист art_incoming/characters/keks/v1/keks_sheet_v1.png (1536x1024, прозрачный фон, мягкое свечение
# с альфой < 50% — отбрасывается). Ряды: сидит (5), идёт вправо (4), идёт влево (4), идёт вниз (4), идёт вверх (4),
# спит (4), спит с облачком z/Zz/Zzz (4).
# Уменьшение в S раз (сидящий кот ~26 px, как прежний Кекс). Силуэт — по альфе исходника; пиксели на краю
# силуэта становятся контуром; внутри — цвет большинства в блоке, но тёмные детали (глаза, рот, контур лап) важнее.
# Облачка «Zzz» при таком размере не читаются — нарисованы заново пиксельными буквами.
# Кадры: холст 32x32, лапы на строке BOTTOM, кот по центру (по центру тяжести верхней половины — без дрожи при ходьбе).
import sys,os
sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','village')); import png
from b06_nature_convert import kmeans
SRC,OUT=sys.argv[1],sys.argv[2]
S,BOTTOM,K=0.16,30,16
w,h,p=png.read(SRC)
A=lambda x,y:p[y][x][3]>=128
# компоненты (кадры) по альфе
seen=[[False]*w for _ in range(h)]; comps=[]
for y0 in range(h):
    for x0 in range(w):
        if A(x0,y0) and not seen[y0][x0]:
            st=[(x0,y0)]; seen[y0][x0]=True; xs=[]; ys=[]
            while st:
                x,y=st.pop(); xs.append(x); ys.append(y)
                for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
                    if 0<=nx<w and 0<=ny<h and not seen[ny][nx] and A(nx,ny): seen[ny][nx]=True; st.append((nx,ny))
            if len(xs)>30: comps.append([min(xs),min(ys),max(xs)+1,max(ys)+1,len(xs)])
big=[c for c in comps if c[4]>5000]; small=[c for c in comps if c[4]<=5000]
rows={}
for c in big: rows.setdefault(c[3]//20,[]).append(c)
ROWS=sorted(rows.values(),key=lambda r:(r[0][3],r[0][0]))
# ряды по низу: сидит (196), вправо (363), спит (396), влево (534), спит+Z (612), вниз (737), вверх (957)
byb={}
for r in ROWS: byb[max(c[3] for c in r)]=sorted(r)
names=dict(zip(sorted(byb),['sit','walk_right','sleep','walk_left','sleep_z','walk_down','walk_up']))
# мелкие кусочки листа («!» у сидящего кота, облачка Z) не берём: при 32 px они не читаются, облачка рисуются заново
frame_box=lambda c:c[:4]
# общая палитра исходника (k-means по выборке пикселей кота)
pts=[p[y][x][:3] for y in range(0,h,3) for x in range(0,w,3) if A(x,y)]
cent=kmeans(pts,K)
lum=lambda c:0.3*c[0]+0.59*c[1]+0.11*c[2]
near={}
def q(c):
    c=c[:3]
    if c not in near: near[c]=min(range(len(cent)),key=lambda j:sum((cent[j][i]-c[i])**2 for i in range(3)))
    return near[c]
DARK={j for j,c in enumerate(cent) if lum(c)<90}
OL=min(cent,key=lum)
def down(box):
    x0,y0,x1,y1=box; W=round((x1-x0)*S); H=round((y1-y0)*S); bx=(x1-x0)/W; by=(y1-y0)/H
    img=[[(0,0,0,0)]*W for _ in range(H)]
    for j in range(H):
        for i in range(W):
            ya,yb,xa,xb=int(y0+j*by),int(y0+(j+1)*by),int(x0+i*bx),int(x0+(i+1)*bx)
            cs=[q(p[y][x]) for y in range(ya,yb) for x in range(xa,xb) if A(x,y)]
            if len(cs)<0.5*(yb-ya)*(xb-xa): continue
            cnt={}
            for k in cs: cnt[k]=cnt.get(k,0)+1
            d=sum(v for k,v in cnt.items() if k in DARK)
            k=max((k for k in cnt if k in DARK),key=cnt.get) if d>=0.3*len(cs) else max((k for k in cnt if k not in DARK),key=cnt.get,default=max(cnt,key=cnt.get))
            img[j][i]=cent[k]+(255,)
    # край силуэта — контур
    edge=[(x,y) for y in range(H) for x in range(W) if img[y][x][3] and any(not(0<=x+dx<W and 0<=y+dy<H) or not img[y+dy][x+dx][3] for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)))]
    for x,y in edge: img[y][x]=OL+(255,)
    # оторванные кусочки меньше 4 пикселей — мусор
    seen=set()
    for y0 in range(H):
        for x0 in range(W):
            if img[y0][x0][3] and (x0,y0) not in seen:
                st=[(x0,y0)]; seen.add((x0,y0)); comp=[]
                while st:
                    x,y=st.pop(); comp.append((x,y))
                    for dx in (-1,0,1):
                        for dy in (-1,0,1):
                            n=(x+dx,y+dy)
                            if 0<=n[0]<W and 0<=n[1]<H and n not in seen and img[n[1]][n[0]][3]: seen.add(n); st.append(n)
                if len(comp)<4:
                    for x,y in comp: img[y][x]=(0,0,0,0)
    return img
def place(img):
    H,W=len(img),len(img[0]); top=[(x,y) for y in range(H//2) for x in range(W) if img[y][x][3]]
    cx=sum(x for x,y in top)/len(top)
    c=[[(0,0,0,0)]*32 for _ in range(32)]; ox=round(16-cx-0.5); oy=BOTTOM+1-H
    for y in range(H):
        for x in range(W):
            if img[y][x][3] and 0<=x+ox<32 and 0<=y+oy<32: c[y+oy][x+ox]=img[y][x]
    assert oy>=0 and ox>=0 and ox+W<=32,(W,H,ox,oy)
    return c
os.makedirs(OUT,exist_ok=True); F={}
for b,name in names.items():
    F[name]=[place(down(frame_box(c))) for c in byb[b]]
    for i,f in enumerate(F[name]): png.write(f'{OUT}/{name}_{i}.png',32,32,f)
    print(name,len(F[name]),[ (len(down(frame_box(c))[0]),len(down(frame_box(c)))) for c in byb[b]])

# ---- облачка сна: z / Zz / Zzz пиксельными буквами ----
GL={'Z':["####","..#.",".#..","#...","####"],'z':["###",".#.","#..","###"]}
PAPER=max(cent,key=lum)
def bubble(f,text,bx=13,bottom=11):
    g=[r[:] for r in f]; th=5; tw=sum(len(GL[ch][0]) for ch in text)+len(text)-1
    W,H=tw+4,th+4; x0,y0=bx,bottom-H+1
    for y in range(H):
        for x in range(W):
            corner=(x in (0,W-1)) and (y in (0,H-1))
            if corner: continue
            border=x in (0,W-1) or y in (0,H-1)
            g[y0+y][x0+x]=(OL if border else PAPER)+(255,)
    cx=x0+2
    for ch in text:
        gl=GL[ch]; oy=y0+2+th-len(gl)
        for yy_,row in enumerate(gl):
            for xx,v in enumerate(row):
                if v=='#': g[oy+yy_][cx+xx]=OL+(255,)
        cx+=len(gl[0])+1
    g[bottom+1][x0+1]=OL+(255,); g[bottom+1][x0+2]=OL+(255,); g[bottom+2][x0+1]=OL+(255,)   # хвостик облачка вниз-влево
    return g
Fz=F['sleep_z']; Fz=[Fz[0],bubble(Fz[1],'z'),bubble(Fz[2],'Zz'),bubble(Fz[3],'Zzz')]
for i,f in enumerate(Fz): png.write(f'{OUT}/sleep_z_{i}.png',32,32,f)
A_,B_=F['sleep'],Fz
# последовательности кадров (скорость: спрайт 30 к/с x image_speed из obj_kitten Step: идёт 0.2 = 6 к/с,
# сидит 0.08 = 2.4 к/с, спит 0.06 = 1.8 к/с)
SIT=[F['sit'][i] for i in (0,0,0,0,1,0,0,0,0,2,2,2,0,0,0,4)]     # сидит, моргает, наклоняет голову
SLEEP=[A_[0],A_[1],A_[2],A_[3],A_[0],A_[1],A_[2],A_[3],B_[0],B_[1],B_[2],B_[3],B_[3]]   # дышит, потом z → Zz → Zzz
SPR={'spr_kitten_sit_strip4':SIT,'spr_kitten_sleep_strip4':SLEEP,'spr_kitten_walk_strip4':F['walk_right'],
     'spr_kitten_walk_down':F['walk_down'],'spr_kitten_walk_up':F['walk_up']}
P=sys.argv[3] if len(sys.argv)>3 else None
if P:
    import re,uuid,shutil; sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','village')); import gm_res,yy
    U=lambda:str(uuid.uuid4())
    def write(name,frames,tmpl='spr_kitten_walk_strip4'):
        d=f'{P}/sprites/{name}'; new=not os.path.exists(d)
        src=f'{P}/sprites/{tmpl if new else name}'; base=tmpl if new else name
        t=open(f'{src}/{base}.yy').read().replace(base,name)
        fr=re.findall(r'\n    \{"\$GMSpriteFrame".*?\},',t); kf=re.findall(r'\n            \{"\$Keyframe<SpriteFrameKeyframe>".*?"Stretch":false,\},',t,re.S)
        old=re.findall(r'"name":"([0-9a-f-]{36})","resourceType":"GMSpriteFrame"',t)
        lid=re.search(r'"\$GMImageLayer":"","%Name":"([0-9a-f-]{36})"',t).group(1)
        if new:
            nl=U(); t=t.replace(lid,nl); lid=nl
        ids=[U() for _ in frames]
        fr0=fr[0].replace(old[0],'@F'); kf0=kf[0].replace(old[0],'@F')
        kid=re.search(r'"id":"([0-9a-f-]{36})"',kf0).group(1)
        t=t.replace(''.join(fr),''.join(fr0.replace('@F',u) for u in ids))
        t=t.replace(''.join(kf),''.join(re.sub(r'"Key":[\d.]+',f'"Key":{i}.0',kf0.replace('@F',u).replace(kid,U())) for i,u in enumerate(ids)))
        t=re.sub(r'"length":[\d.]+',f'"length":{len(frames)}.0',t)
        bb=gm_res.opaque([[(0,0,0,255) if any(f[y][x][3] for f in frames) else (0,0,0,0) for x in range(32)] for y in range(32)])   # маска по всем кадрам
        for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3])]:
            t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n==1,k
        # старые кадры — прочь
        if not new:
            for u in old:
                os.remove(f'{d}/{u}.png'); shutil.rmtree(f'{d}/layers/{u}')
        for u,f in zip(ids,frames):
            os.makedirs(f'{d}/layers/{u}',exist_ok=True); png.write(f'{d}/{u}.png',32,32,f); png.write(f'{d}/layers/{u}/{lid}.png',32,32,f)
        open(f'{d}/{name}.yy','w').write(t); yy.load(f'{d}/{name}.yy')
        print(name,'кадров',len(frames),'(новый)' if new else '')
        return new
    made=[n for n,fr in SPR.items() if write(n,fr)]
    gm_res.add_to_yyp(P,made)
