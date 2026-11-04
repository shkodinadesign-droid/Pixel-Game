# Партия 07 (лист v4): замена картинок у существующих спрайтов (имена, объекты и экземпляры те же),
# два новых спрайта природы (люпин, камни с травой) с объектами obj_vn_*, и возврат в rm_village
# предметов, убранных перед заменой: будка, скамейка, доска, ящики с цветами, клумба с камнями.
# Предмет не возвращается, если на его месте уже стоит что-то новое (ручная расстановка важнее).
import sys,os,re,json,uuid
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res,yy
G,P,OLD_ROOM=sys.argv[1],sys.argv[2],sys.argv[3]     # OLD_ROOM — rm_village.yy до ручной правки (из git)
NEW={'spr_nature_lupine','spr_nature_rocks_grass'}
def replace(name,img):
    d=f'{P}/sprites/{name}'; f=f'{d}/{name}.yy'; t=open(f).read(); old=yy.load(f)
    w,h=len(img[0]),len(img)
    # маска: та же высота полосы у основания, что была; начало координат — низ по центру
    strip=old['bbox_bottom']-old['bbox_top']
    bb=(max(0,round(old['bbox_left']*w/old['width'])),h-1-strip,min(w-1,round(old['bbox_right']*w/old['width'])),h-1)
    org=(w//2,h-1)
    if old['sequence']['xorigin']!=old['width']//2 or old['sequence']['yorigin']!=old['height']-1:
        # нестандартное начало (стволы): пересчитываем пропорционально
        org=(round(old['sequence']['xorigin']*w/old['width']),round(old['sequence']['yorigin']*h/old['height']))
    for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',w),('height',h),('xorigin',org[0]),('yorigin',org[1])]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(name,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    open(f,'w').write(t)
    for fr in old['frames']:
        png.write(f'{d}/{fr["name"]}.png',w,h,img)
        for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',w,h,img)
made=[]
for fn in sorted(os.listdir(G)):
    name=fn[:-4]; w,h,img=png.read(f'{G}/{fn}')
    if name in NEW:
        if not os.path.exists(f'{P}/sprites/{name}'):
            gm_res.sprite(P,name,img,(w//2,h-1),gm_res.opaque(img),('Village nature','folders/Sprites/Village nature.yy'))
            obj='obj_vn_'+name[len('spr_nature_'):]; gm_res.obj(P,obj,name,'obj_village_prop_soft',solid=False); made+=[name,obj]
    else: replace(name,img)
gm_res.add_to_yyp(P,made)
# ---- возврат предметов в комнату ----
BACK=['inst_V2_00','inst_V2_01','inst_V2_03','inst_V2_07','inst_7DE294D7','inst_2C155EF6','inst_2042218E','inst_2F812EB9',
      'inst_398CC164','inst_2C037839','inst_423F5DE1','inst_58F5C115']
rp=f'{P}/rooms/rm_village/rm_village.yy'; t=open(rp).read(); old=open(OLD_ROOM).read(); cur=yy.load(rp)
def box(o,x,y,sx=1):
    ob=yy.load(f'{P}/objects/{o}/{o}.yy')
    if not ob.get('spriteId'): return None
    s=ob['spriteId']['name']; sp=yy.load(f'{P}/sprites/{s}/{s}.yy'); q=sp['sequence']
    x0=x-q['xorigin']*sx; x1=x0+sp['width']*sx
    # для пересечений берём нижнюю половину предмета: «стоит на том же месте»
    return (min(x0,x1),y-sp['height']*0.5,max(x0,x1),y)
# мешают только то, что поставлено или передвинуто вручную после старой версии (соседство как было — не помеха)
was={(m.group(1),float(m.group(2)),float(m.group(3))) for m in re.finditer(r'"%Name":"(\w+)".*?"x":([-\d.]+),"y":([-\d.]+)',old)}
others=[]
for L in cur['layers']:
    for i in L.get('instances') or []:
        if i['objectId']['name'] in ('obj_forest_blocker','obj_village_water_block'): continue
        if (i['name'],float(i['x']),float(i['y'])) in was: continue
        b=box(i['objectId']['name'],i['x'],i['y'],i['scaleX'])
        if b and not i['objectId']['name'].startswith(('obj_vn_grass','obj_vn_leaves')): others.append((i['name'],i['objectId']['name'],b))
back,skip=[],[]
for nm in BACK:
    line=re.search(r'\{"\$GMRInstance":"v4","%Name":"'+nm+r'".*?\},(?=\n)',old).group(0)
    o=re.search(r'"objectId":\{"name":"(\w+)"',line).group(1); x=float(re.search(r'"x":([-\d.]+)',line).group(1)); y=float(re.search(r'"y":([-\d.]+)',line).group(1))
    b=box(o,x,y); hit=[(n2,o2) for n2,o2,b2 in others if not(b[2]<=b2[0] or b2[2]<=b[0] or b[3]<=b2[1] or b2[3]<=b[1])]
    if hit: skip.append((o,int(x),int(y),hit)); continue
    back.append((nm,line))
k=t.index('"%Name":"village_concept"'); k=t.index('"instances":[',k)+len('"instances":[')
t=t[:k]+''.join('\n        '+l for _,l in back)+t[k:]
k=t.index('"instanceCreationOrder":[')+len('"instanceCreationOrder":[')
t=t[:k]+''.join(f'\n    {{"name":"{nm}","path":"rooms/rm_village/rm_village.yy",}},' for nm,_ in back)+t[k:]
open(rp,'w').write(t)
print('новые спрайты:',made); print('возвращено:',[nm for nm,_ in back])
for s in skip: print('НЕ возвращено (место занято):',s)
