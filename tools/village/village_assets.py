# Ресурсы GameMaker для rm_village по концепту: тайлсет площади, спрайты декора, маски, объекты.
import os,re,uuid,sys,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
P,V2=sys.argv[1],sys.argv[2]
TS=open(f'{P}/sprites/spr_tree_shadow_medium/spr_tree_shadow_medium.yy').read()
created=[]
def opaque_bbox(img):
    ys=[y for y,row in enumerate(img) if any(c[3] for c in row)]
    xs=[x for x in range(len(img[0])) if any(row[x][3] for row in img)]
    return min(xs),min(ys),max(xs),max(ys)
def make_sprite(name,img,origin,bbox,folder,mode=2):
    d=f'{P}/sprites/{name}'; assert not os.path.exists(d),name
    h=len(img); w=len(img[0])
    fid,lid,kid=str(uuid.uuid4()),str(uuid.uuid4()),str(uuid.uuid4())
    y=TS.replace('spr_tree_shadow_medium',name).replace('d5848da5-c4e6-49b2-95b3-53d678f69d0b',fid).replace('6fee1f85-b5fa-4890-930e-3345227e9414',lid).replace('26fe25ac-b96c-4ff1-a4eb-b0e34e684a91',kid)
    l,t,r,b=bbox
    for k,v in [('bboxMode',mode),('bbox_left',l),('bbox_right',r),('bbox_top',t),('bbox_bottom',b),('width',w),('height',h),('origin',9 if origin!=(0,0) else 0),('xorigin',origin[0]),('yorigin',origin[1])]:
        y,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',y); assert n>=1,k
    y=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',y); y=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',y)
    y=y.replace('"name":"Trees and boosh",\n    "path":"folders/Sprites/Trees and boosh.yy"',f'"name":"{folder[0]}",\n    "path":"{folder[1]}"')
    assert folder[1] in y
    os.makedirs(f'{d}/layers/{fid}'); open(f'{d}/{name}.yy','w').write(y)
    for dst in [f'{d}/{fid}.png',f'{d}/layers/{fid}/{lid}.png']: png.write(dst,w,h,img)
    created.append(('sprites',name)); return name
VR=('Village room','folders/Sprites/Village room.yy')
TSF=('Tile Sets','folders/Tile Sets.yy')
# --- 1. тайлсет площади ---
w,h,atl=png.read(f'{V2}/spr_village_square_paving.png'); meta=json.load(open(f'{V2}/ground.json'))
make_sprite('spr_village_square_paving',atl,(0,0),(0,0,w-1,h-1),VR,mode=0)
tl=open(f'{P}/tilesets/tls_village_ground_v1/tls_village_ground_v1.yy').read()
tl=tl.replace('tls_village_ground_v1','tls_village_square_paving').replace('spr_village_ground_v1','spr_village_square_paving')
tl=re.sub(r'"out_columns":\d+','"out_columns":8',tl); tl=re.sub(r'"tile_count":\d+',f'"tile_count":{meta["tile_count"]}',tl)
os.makedirs(f'{P}/tilesets/tls_village_square_paving'); open(f'{P}/tilesets/tls_village_square_paving/tls_village_square_paving.yy','w').write(tl)
created.append(('tilesets','tls_village_square_paving'))
# --- 2. декор: origin внизу по центру, маска — полоса у основания ---
DECOR=[ # спрайт, файл, высота маски, отступ по бокам
 ('spr_village_lamp','01_street_lamp',6,5),
 ('spr_village_barrel','02_wooden_barrel',10,2),
 ('spr_village_planter_long','03_long_flower_planter',10,1),
 ('spr_village_planter_square','04_square_flower_planter',10,1),
 ('spr_village_flower_bed','05_flower_bed',14,3),
 ('spr_village_notice_board','06_notice_board',6,3),
 ('spr_village_sign_aframe','07_a_frame_sign',6,3),
 ('spr_village_crate','08_wooden_crate',12,1),
 ('spr_village_crates','09_stacked_crates',14,1),
 ('spr_village_hedge','10_small_hedge',12,5),
 ('spr_village_hedge_v','11_hedge_vertical',70,3),
]
for name,f,mh,ins in DECOR:
    w,h,img=png.read(f'{V2}/decor/{f}.png')
    l,t,r,b=opaque_bbox(img)
    make_sprite(name,img,(w//2,h-1),(l+ins,max(t,b-mh+1),r-ins,b),VR)
# --- 3. маски для существующих спрайтов (рисунок общий с фермой, маска — только основание) ---
MASKS={'spr_village_mask_fence_h':('spr_fence_h',(0,38,63,47)),
       'spr_village_mask_fence_post':('spr_fence_1',(1,38,14,47)),
       'spr_village_mask_bench':('spr_bench',(3,30,69,51)),
       'spr_village_mask_bush':('spr_bush',(8,40,55,53))}
for name,(base,bb) in MASKS.items():
    t=open(f'{P}/sprites/{base}/{base}.yy').read()
    W_=int(re.search(r'"width":(\d+)',t).group(1)); H_=int(re.search(r'"height":(\d+)',t).group(1))
    img=[[(255,0,255,96) if bb[0]<=x<=bb[2] and bb[1]<=y<=bb[3] else (0,0,0,0) for x in range(W_)] for y in range(H_)]
    make_sprite(name,img,(0,0),bb,VR)
# --- 4. объекты ---
TO=open(f'{P}/objects/obj_tree_pine/obj_tree_pine.yy').read()
EV0='    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},\n'
def ref(kind,n): return 'null' if n is None else f'{{\n    "name":"{n}",\n    "path":"{kind}/{n}/{n}.yy",\n  }}'
def make_obj(name,spr,parent,mask=None,create=None,solid=False):
    d=f'{P}/objects/{name}'; assert not os.path.exists(d),name
    y=TO.replace('obj_tree_pine',name)
    a=y.index('  "eventList":['); b=y.index('  ],',a)+4
    y=y[:a]+'  "eventList":[\n'+(EV0 if create else '')+'  ],'+y[b:]
    y=re.sub(r'"parent":\{\s*"name":"Trees and bushes",\s*"path":"folders/Objects/Trees and bushes.yy",\s*\}','"parent":{\n    "name":"village obj",\n    "path":"folders/Objects/village obj.yy",\n  }',y)
    y=re.sub(r'"parentObjectId":(\{[^}]*\}|null)',f'"parentObjectId":{ref("objects",parent)}',y)
    y=re.sub(r'"spriteId":(\{[^}]*\}|null)',f'"spriteId":{ref("sprites",spr)}',y)
    y=re.sub(r'"spriteMaskId":(\{[^}]*\}|null)',f'"spriteMaskId":{ref("sprites",mask)}',y)
    y=re.sub(r'"solid":(true|false)',f'"solid":{"true" if solid else "false"}',y)
    assert 'village obj' in y
    os.makedirs(d); open(f'{d}/{name}.yy','w').write(y)
    if create: open(f'{d}/Create_0.gml','w').write(create)
    created.append(('objects',name))
make_obj('obj_village_prop',None,'obj_solid',create='''// ===== ДЕКОР ДЕРЕВНИ — ПРЕПЯТСТВИЕ (CREATE) =====
// Родитель для фонарей, ящиков, кустов, изгородей, заборов и т.п. в rm_village.
// Наследник obj_solid: Макс сталкивается только с маской у основания предмета.
// Глубина по низу маски — Макс правильно заходит за предмет и выходит перед ним.
depth = -bbox_bottom;
''',solid=True)
make_obj('obj_village_prop_soft',None,None,create='''// ===== ДЕКОР ДЕРЕВНИ — БЕЗ СТОЛКНОВЕНИЙ (CREATE) =====
// Родитель для цветов и травы в rm_village: сквозь них можно ходить, глубина — по низу.
depth = -bbox_bottom;
''')
for o,s,m in [('obj_village_lamp','spr_village_lamp',None),('obj_village_barrel','spr_village_barrel',None),
              ('obj_village_planter_long','spr_village_planter_long',None),('obj_village_planter_square','spr_village_planter_square',None),
              ('obj_village_flower_bed','spr_village_flower_bed',None),('obj_village_notice_board','spr_village_notice_board',None),
              ('obj_village_sign_aframe','spr_village_sign_aframe',None),('obj_village_crate','spr_village_crate',None),
              ('obj_village_crates','spr_village_crates',None),('obj_village_hedge','spr_village_hedge',None),
              ('obj_village_hedge_v','spr_village_hedge_v',None),
              ('obj_village_fence','spr_fence_h','spr_village_mask_fence_h'),('obj_village_fence_post','spr_fence_1','spr_village_mask_fence_post'),
              ('obj_village_bench','spr_bench','spr_village_mask_bench'),('obj_village_bush','spr_bush','spr_village_mask_bush'),
              ('obj_village_bush_2','spr_bush_2','spr_village_mask_bush'),('obj_village_rock','spr_forest_big_stone',None)]:
    make_obj(o,s,'obj_village_prop',mask=m,solid=True)
for o,s in [('obj_village_flower_daisy','spr_flover_3'),('obj_village_flower_lupine','spr_flover_2'),
            ('obj_village_flower_yellow','spr_flover_1'),('obj_village_grass','spr_grass1')]:
    make_obj(o,s,'obj_village_prop_soft')
# --- 5. проект ---
yyp=f'{P}/max_farm_demo.yyp'; t=open(yyp).read()
i=t.index('  "resources":['); j=t.index('\n  ],',i)
add=''.join(f'\n    {{"id":{{"name":"{n}","path":"{k}/{n}/{n}.yy",}},}},' for k,n in created if f'"{n}"' not in t)
t=t[:j]+add+t[j:]; open(yyp,'w').write(t)
print(len(created),'ресурсов:',', '.join(n for k,n in created))
