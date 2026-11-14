# Фермер Джо сидит у вагончика Джека и курит трубку (art_incoming/farmer_joe_v1/joe_sheet_v1.png, кадр 1 — с трубкой).
# Тело — самый большой рисунок верхнего левого кадра (дымок с листа отбрасывается), высота 50 px, 32 цвета.
# Анимация spr_farmer_joe_smoke, 8 кадров, 4 кадра/с: дыхание (голова и туловище на 1 px вверх в кадрах 2-5)
# и дым из трубки — три колечка поднимаются и тают. Начало — низ по центру.
import sys,os,re,uuid
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]
w,h,p=png.read(SRC); q=[[c[:3]+(255,) if c[3]>=200 and not (c[0]>190 and c[1]<70 and c[2]<70) else (0,0,0,0) for c in r[:w//2]] for r in p[:h//2]]
W,H=len(q[0]),len(q); seen=bytearray(W*H); best=[]
for y in range(H):
    for x in range(W):
        if q[y][x][3] and not seen[y*W+x]:
            st=[(x,y)]; seen[y*W+x]=1; pts=[]
            while st:
                a,b=st.pop(); pts.append((a,b))
                for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                    if 0<=c<W and 0<=d<H and not seen[d*W+c] and q[d][c][3]: seen[d*W+c]=1; st.append((c,d))
            if len(pts)>len(best): best=pts
xs=[a for a,b in best]; ys=[b for a,b in best]; X0,Y0=min(xs),min(ys)
body=[[(0,0,0,0)]*(max(xs)-X0+1) for _ in range(max(ys)-Y0+1)]
for a,b in best: body[b-Y0][a-X0]=q[b][a]
pipe_x=(575-X0)/len(body[0]); pipe_y=(240-Y0)/len(body)        # чаша трубки на листе (доля от рисунка)
s=down(body,len(body[0]),len(body),50/len(body)); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
cent=kmeans([c[:3] for r in s for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
s=[[near(c)+(255,) if c[3] else c for c in r] for r in s]; bw,bh=len(s[0]),len(s)
TOP,RIGHT=14,12; CW,CH=bw+RIGHT,bh+TOP+1                       # место под дым сверху и справа
WAIST=round(bh*0.70)                                            # граница: выше — голова и туловище (дышат)
px,py=round(pipe_x*bw),round(pipe_y*bh)+TOP+1
SM,SO=(196,196,202,255),(128,128,138,255)
def puff(f,x,y,r):
    for dy in range(-r-1,r+2):
        for dx in range(-r-1,r+2):
            X,Y=x+dx,y+dy
            if 0<=X<CW and 0<=Y<CH:
                d=dx*dx+dy*dy
                if d<=r*r: f[Y][X]=SM
                elif d<=(r+1)*(r+1) and f[Y][X][3]==0: f[Y][X]=SO
frames=[]
for k in range(8):
    f=[[(0,0,0,0)]*CW for _ in range(CH)]
    lift=1 if k in (2,3,4,5) else 0
    for y in range(bh):
        for x in range(bw):
            if s[y][x][3]:
                yy=y+TOP+1-(lift if y<WAIST else 0)
                if f[yy][x][3]==0 or y<WAIST: f[yy][x]=s[y][x]
    if lift:                                                   # на вдохе строка у пояса тянется — без щели
        for x in range(bw):
            if s[WAIST-1][x][3] and f[WAIST+TOP][x][3]==0: f[WAIST+TOP][x]=s[WAIST-1][x]
    for j in range(3):                                         # колечки дыма: стартуют по очереди, поднимаются вправо
        t=(k-j*3)%8
        if t<6: puff(f,px+2+t//2,py-3-t*2-lift,1 if t<3 else 2)
    frames.append(f)
# многокадровый спрайт по шаблону spr_maggie_cat_sleep
name='spr_farmer_joe_smoke'; d=f'{P}/sprites/{name}'
tpl=open(f'{P}/sprites/spr_maggie_cat_sleep/spr_maggie_cat_sleep.yy').read()
if not os.path.exists(d):
    fids=[str(uuid.uuid4()) for _ in frames]; lid=str(uuid.uuid4())
    y=tpl.replace('spr_maggie_cat_sleep',name)
    i0=y.index('"frames":[')+len('"frames":['); i1=y.index('\n  ],',i0)
    y=y[:i0]+''.join(f'\n    {{"$GMSpriteFrame":"v1","%Name":"{f}","name":"{f}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},' for f in fids)+y[i1:]
    k0=y.index('"Keyframes":[\n            {"$Keyframe<SpriteFrameKeyframe>"')+len('"Keyframes":['); k1=y.index('\n          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>"')
    kf=''.join('\n            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"'+f+'","path":"sprites/'+name+'/'+name+'.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n              },"Disabled":false,"id":"'+str(uuid.uuid4())+'","IsCreationKey":false,"Key":'+f'{i}.0'+',"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},' for i,f in enumerate(fids))
    y=y[:k0]+kf+y[k1:]
    y=y.replace('157499cb-3c16-4567-9cd5-06d0ed006f29',lid)
    bl,bt=0,CH-12
    for k,v in [('bbox_left',2),('bbox_right',bw-3),('bbox_top',CH-10),('bbox_bottom',CH-1),('width',CW),('height',CH),('xorigin',bw//2),('yorigin',CH-1)]:
        y,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',y); assert n>=1,k
    y=re.sub(r'"origin":\d+','"origin":9',y); y=re.sub(r'"length":[\d.]+',f'"length":{len(frames)}.0',y); y=re.sub(r'"playbackSpeed":[\d.]+','"playbackSpeed":4.0',y)
    y=y.replace('"name":"Maggie",\n    "path":"folders/Sprites/characters/Maggie.yy"','"name":"characters",\n    "path":"folders/Sprites/characters.yy"')
    os.makedirs(d); open(f'{d}/{name}.yy','w').write(y)
    for fid,f in zip(fids,frames):
        png.write(f'{d}/{fid}.png',CW,CH,f); os.makedirs(f'{d}/layers/{fid}'); png.write(f'{d}/layers/{fid}/{lid}.png',CW,CH,f)
    gm_res.add_to_yyp(P,[name])
else:
    import json
    for root,_,fs in os.walk(d): pass
print(name,CW,'x',CH,'тело',bw,'x',bh,'трубка',px,py)
# превью кадров
out=[[(110,150,80,255)]*(CW*8+16) for _ in range(CH+4)]
for i,f in enumerate(frames):
    for yy in range(CH):
        for xx in range(CW):
            if f[yy][xx][3]: out[2+yy][2+i*(CW+2)+xx]=f[yy][xx]
png.write(sys.argv[3],len(out[0]),len(out),out)
# объект и экземпляр в деревне: справа от вагончика Джека (вагончик — низ по центру 1408,576, правый край ~1475)
if not os.path.exists(f'{P}/objects/obj_farmer_joe'):
    gm_res.obj(P,'obj_farmer_joe',name,'obj_village_prop',events={(0,0,'Create_0.gml'):
        '// ===== ФЕРМЕР ДЖО (CREATE) =====\n// Сидит у вагончика Джека и курит трубку: анимация спрайта spr_farmer_joe_smoke (8 кадров, 4 кадра/с).\n'
        '// Препятствие с маской у табурета, глубина по низу маски (obj_village_prop).\nevent_inherited();\n'},solid=True)
    gm_res.add_to_yyp(P,['obj_farmer_joe'])
vp=f'{P}/rooms/rm_village/rm_village.yy'; v=open(vp).read()
if 'inst_FARMER_JOE' not in v:
    line='{"$GMRInstance":"v4","%Name":"inst_FARMER_JOE","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_FARMER_JOE","objectId":{"name":"obj_farmer_joe","path":"objects/obj_farmer_joe/obj_farmer_joe.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":1500.0,"y":578.0,},'
    m=re.search(r'\{"\$GMRInstanceLayer":"","%Name":"Instances",[^\n]*"instances":\[',v); assert m
    v=v[:m.end()]+'\n        '+line+v[m.end():]
    v=v.replace('"instanceCreationOrder":[','"instanceCreationOrder":[\n    {"name":"inst_FARMER_JOE","path":"rooms/rm_village/rm_village.yy",},',1)
    open(vp,'w').write(v); print('Джо поставлен в rm_village (1500,578)')
