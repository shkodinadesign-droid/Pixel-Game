# Многокадровый спрайт GameMaker по шаблону spr_maggie_cat_sleep (frames + track keyframes).
import os,re,uuid,sys
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
def sprite(P,name,frames,origin,bbox,speed,folder=('characters','folders/Sprites/characters.yy')):
    d=f'{P}/sprites/{name}'; W,H=len(frames[0][0]),len(frames[0])
    if os.path.exists(d):
        import shutil; shutil.rmtree(d)
    tpl=open(f'{P}/sprites/spr_maggie_cat_sleep/spr_maggie_cat_sleep.yy').read()
    fids=[str(uuid.uuid4()) for _ in frames]; lid=str(uuid.uuid4())
    y=tpl.replace('spr_maggie_cat_sleep',name)
    i0=y.index('"frames":[')+len('"frames":['); i1=y.index('\n  ],',i0)
    y=y[:i0]+''.join(f'\n    {{"$GMSpriteFrame":"v1","%Name":"{f}","name":"{f}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},' for f in fids)+y[i1:]
    k0=y.index('"Keyframes":[\n            {"$Keyframe<SpriteFrameKeyframe>"')+len('"Keyframes":['); k1=y.index('\n          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>"')
    y=y[:k0]+''.join('\n            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"'+f+'","path":"sprites/'+name+'/'+name+'.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n              },"Disabled":false,"id":"'+str(uuid.uuid4())+'","IsCreationKey":false,"Key":'+f'{i}.0'+',"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},' for i,f in enumerate(fids))+y[k1:]
    y=y.replace('157499cb-3c16-4567-9cd5-06d0ed006f29',lid)
    for k,v in [('bbox_left',bbox[0]),('bbox_top',bbox[1]),('bbox_right',bbox[2]),('bbox_bottom',bbox[3]),('width',W),('height',H),('xorigin',origin[0]),('yorigin',origin[1])]:
        y,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',y); assert n>=1,k
    y=re.sub(r'"origin":\d+','"origin":9',y); y=re.sub(r'"length":[\d.]+',f'"length":{len(frames)}.0',y); y=re.sub(r'"playbackSpeed":[\d.]+',f'"playbackSpeed":{float(speed)}',y)
    y=y.replace('"name":"Maggie",\n    "path":"folders/Sprites/characters/Maggie.yy"',f'"name":"{folder[0]}",\n    "path":"{folder[1]}"')
    os.makedirs(d); open(f'{d}/{name}.yy','w').write(y)
    for fid,f in zip(fids,frames):
        png.write(f'{d}/{fid}.png',W,H,f); os.makedirs(f'{d}/layers/{fid}'); png.write(f'{d}/layers/{fid}/{lid}.png',W,H,f)
    yp=f'{P}/max_farm_demo.yyp'; s=open(yp).read()
    if f'"{name}"' not in s:
        i=s.index('  "resources":['); j=s.index('\n  ],',i)
        s=s[:j]+f'\n    {{"id":{{"name":"{name}","path":"sprites/{name}/{name}.yy",}},}},'+s[j:]; open(yp,'w').write(s)
