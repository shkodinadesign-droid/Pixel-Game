# Партия 08 (v5): новые домики деревни — магазин Джошуа, мясная лавка Ивана (лист shops_v5.png) и дом Джастина
# (justin_house_v5.png) из art_incoming/village/08_houses/v5. Фон у листов чёрный и непрозрачный: убирается
# заливкой от краёв (почти чёрные пиксели, связанные с краем), тёмные контуры внутри рисунка остаются.
# Скамейки по бокам магазина в спрайт не входят (это отдельный объект obj_village2_bench).
# Картинки заменяются на месте (те же спрайты и объекты), маска — в тех же долях, что у прежней;
# здание стоит на том же месте: низ по центру совпадает с прежним.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
from b06_nature_convert import down,kmeans,clean,crop
A,P=sys.argv[1],sys.argv[2]
SHOPS=0.44     # общий масштаб листа магазинов: магазин 227 px в ширину, как прежний
JOBS={'spr_joshua_shop':('shops_v5.png',(191,0,709,10**6),SHOPS),'spr_ivan_butcher':('shops_v5.png',(900,0,1400,10**6),SHOPS),
      'spr_justin_house':('justin_house_v5.png',(0,0,10**6,10**6),248/1052)}
def keyed(fn):
    w,h,p=png.read(f'{A}/{fn}'); bg=lambda c:max(c[:3])<=24
    seen=[[False]*w for _ in range(h)]; st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
    for x,y in st: seen[y][x]=True
    while st:
        x,y=st.pop()
        for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
            if 0<=nx<w and 0<=ny<h and not seen[ny][nx] and bg(p[ny][nx]): seen[ny][nx]=True; st.append((nx,ny))
    return [[(0,0,0,0) if seen[y][x] else p[y][x][:3]+(255,) for x in range(w)] for y in range(h)]
src={}
rp=f'{P}/rooms/rm_village/rm_village.yy'; room=open(rp).read()
for name,(fn,(x0,y0,x1,y1),f) in JOBS.items():
    if fn not in src: src[fn]=keyed(fn)
    part=crop([r[x0:x1] for r in src[fn][y0:y1]]); pw,ph=len(part[0]),len(part)
    img=crop(clean(down(part,pw,ph,f),'trees'))
    pts=[c[:3] for r in img for c in r if c[3]]; cent=kmeans(pts,32)
    near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]; w,h=len(img[0]),len(img)
    d=f'{P}/sprites/{name}'; yf=f'{d}/{name}.yy'; t=open(yf).read(); old=yy.load(yf); ow,oh=old['width'],old['height']
    ox,oy=old['sequence']['xorigin'],old['sequence']['yorigin']
    bb=(round(old['bbox_left']*w/ow),h-1-round((oh-1-old['bbox_top'])*h/oh),min(w-1,round(old['bbox_right']*w/ow)),h-1)
    org=(w//2,h-1) if (ox,oy)==(ow//2,oh-1) else (round(ox*w/ow),round(oy*h/oh))
    for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',w),('height',h),('xorigin',org[0]),('yorigin',org[1])]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(name,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    open(yf,'w').write(t)
    for fr in old['frames']:
        png.write(f'{d}/{fr["name"]}.png',w,h,img)
        for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',w,h,img)
    # экземпляры с нецентровым началом (магазин: левый верхний угол) сдвигаются, чтобы низ по центру остался на месте
    if org!=(w//2,h-1):
        obj=[o for o in os.listdir(f'{P}/objects') if f'"name":"{name}"' in open(f'{P}/objects/{o}/{o}.yy').read()][0]
        for m in re.finditer(r'\{"\$GMRInstance":"v4","%Name":"\w+".*?"objectId":\{"name":"'+obj+r'".*?\},(?=\n)',room):
            line=m.group(0); x=float(re.search(r'"x":([-\d.]+)',line).group(1)); y=float(re.search(r'"y":([-\d.]+)',line).group(1))
            bx,by=x-ox+ow/2,y-oy+oh                # прежний низ по центру
            nx,ny=round(bx-w/2+org[0]),round(by-h+org[1])
            room=room.replace(line,re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(nx)},"y":{float(ny)}',line))
            print('  сдвинут',obj,(x,y),'->',(nx,ny))
    print(name,ow,'x',oh,'->',w,'x',h)
open(rp,'w').write(room)
