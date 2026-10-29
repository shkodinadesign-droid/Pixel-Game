# Создание однокадровых спрайтов и простых объектов GameMaker по шаблонам проекта.
import os,re,uuid,sys;sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)));import png
def opaque(img):
    ys=[y for y,r in enumerate(img) if any(c[3] for c in r)]; xs=[x for x in range(len(img[0])) if any(r[x][3] for r in img)]
    return min(xs),min(ys),max(xs),max(ys)
def sprite(P,name,img,origin,bb,folder=('Village room','folders/Sprites/Village room.yy')):
    TS=open(f'{P}/sprites/spr_tree_shadow_medium/spr_tree_shadow_medium.yy').read()
    d=f'{P}/sprites/{name}'; assert not os.path.exists(d),name
    h=len(img); w=len(img[0]); fid,lid,kid=str(uuid.uuid4()),str(uuid.uuid4()),str(uuid.uuid4())
    y=TS.replace('spr_tree_shadow_medium',name).replace('d5848da5-c4e6-49b2-95b3-53d678f69d0b',fid).replace('6fee1f85-b5fa-4890-930e-3345227e9414',lid).replace('26fe25ac-b96c-4ff1-a4eb-b0e34e684a91',kid)
    for k,v in [('bboxMode',2),('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',w),('height',h),('origin',9 if origin!=(0,0) else 0),('xorigin',origin[0]),('yorigin',origin[1])]:
        y,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',y); assert n>=1,k
    y=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',y); y=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',y)
    y=y.replace('"name":"Trees and boosh",\n    "path":"folders/Sprites/Trees and boosh.yy"',f'"name":"{folder[0]}",\n    "path":"{folder[1]}"')
    os.makedirs(f'{d}/layers/{fid}'); open(f'{d}/{name}.yy','w').write(y)
    for dst in [f'{d}/{fid}.png',f'{d}/layers/{fid}/{lid}.png']: png.write(dst,w,h,img)
    return name
EV='{{"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":{num},"eventType":{typ},"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",}},'
def obj(P,name,spr,parent,events=None,solid=True):
    """events: {(type,num,filename): code}"""
    TO=open(f'{P}/objects/obj_village_lamp/obj_village_lamp.yy').read()
    od=f'{P}/objects/{name}'; assert not os.path.exists(od),name
    t=TO.replace('obj_village_lamp',name)
    t=re.sub(r'"spriteId":(\{[^}]*\}|null)','"spriteId":'+('null' if spr is None else f'{{\n    "name":"{spr}",\n    "path":"sprites/{spr}/{spr}.yy",\n  }}'),t)
    t=re.sub(r'"parentObjectId":(\{[^}]*\}|null)','"parentObjectId":'+('null' if parent is None else f'{{\n    "name":"{parent}",\n    "path":"objects/{parent}/{parent}.yy",\n  }}'),t)
    t=t.replace('"solid":true',f'"solid":{"true" if solid else "false"}')
    if events:
        t=t.replace('"eventList":[]','"eventList":[\n'+'\n'.join('    '+EV.format(num=n,typ=ty) for (ty,n,f) in events)+'\n  ]')
    os.makedirs(od); open(f'{od}/{name}.yy','w').write(t)
    for (ty,n,f),code in (events or {}).items(): open(f'{od}/{f}','w').write(code)
    return name
def add_to_yyp(P,names):
    yyp=f'{P}/max_farm_demo.yyp'; s=open(yyp).read(); i=s.index('  "resources":['); j=s.index('\n  ],',i)
    kind=lambda n:'objects' if n.startswith('obj_') else 'sprites'
    s=s[:j]+''.join(f'\n    {{"id":{{"name":"{n}","path":"{kind(n)}/{n}/{n}.yy",}},}},' for n in names if f'"{n}"' not in s)+s[j:]
    open(yyp,'w').write(s)
