# Партия 12: новые домики фермы — дом Макса (spr_house_farm), пекарня (spr_bakery_building), сарай (spr_barn_outside)
# из art_incoming/farm/houses_v1. Чёрный фон убирается заливкой от краёв (как в b08), у сарая фон уже прозрачный.
# Масштаб: площадь рисунка как у прежнего спрайта (средняя геометрическая по ширине и высоте), 32 цвета.
# Режим prev: только PNG в OUT; режим install: замена спрайтов на месте, низ по центру здания остаётся там же.
import sys,os,re,math
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
from b06_nature_convert import down,kmeans,crop
A,P,OUT=sys.argv[1],sys.argv[2],sys.argv[3]
JOBS={'spr_house_farm':'farm_house_v1.png','spr_bakery_building':'bakery_v1.png','spr_barn_outside':'barn_v1.png'}
def keyed(fn):
    w,h,p=png.read(f'{A}/{fn}')
    if any(c[3]<128 for c in p[0]): return [[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in p]
    bg=lambda c:max(c[:3])<=24
    seen=[[False]*w for _ in range(h)]; st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
    for x,y in st: seen[y][x]=True
    while st:
        x,y=st.pop()
        for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
            if 0<=nx<w and 0<=ny<h and not seen[ny][nx] and bg(p[ny][nx]): seen[ny][nx]=True; st.append((nx,ny))
    return [[(0,0,0,0) if seen[y][x] else p[y][x][:3]+(255,) for x in range(w)] for y in range(h)]
os.makedirs(OUT,exist_ok=True)
for name,fn in JOBS.items():
    ow,oh,op=png.read(f'{P}/sprites/{name}/'+[f for f in os.listdir(f'{P}/sprites/{name}') if f.endswith('.png')][0])
    oc=crop([[c if c[3]>=128 else (0,0,0,0) for c in r] for r in op]); cw,ch=len(oc[0]),len(oc)
    part=crop(keyed(fn)); pw,ph=len(part[0]),len(part)
    f=math.sqrt(cw*ch/(pw*ph))
    img=crop(down(part,pw,ph,f))
    img=[[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in img]
    pts=[c[:3] for r in img for c in r if c[3]]; cent=kmeans(pts,32)
    near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]; w,h=len(img[0]),len(img)
    png.write(f'{OUT}/{name}.png',w,h,img)
    print(name,'старый рисунок',cw,'x',ch,'-> новый',w,'x',h,'масштаб %.3f'%f)
    if os.environ.get('INSTALL')!='1': continue
    # центр двери (x в спрайте) у прежнего и нового рисунка — по нему и по низу здание встаёт на прежнее место
    DOOR={'spr_house_farm':(115.5,108),'spr_bakery_building':(87,81),'spr_barn_outside':(129,103.5)}[name]
    d=f'{P}/sprites/{name}'; yf=f'{d}/{name}.yy'; t=open(yf).read(); old=yy.load(yf)
    ox,oy=old['sequence']['xorigin'],old['sequence']['yorigin']; obb=old['bbox_bottom']
    dx=round(DOOR[0]-DOOR[1]); dy=obb-(h-1)        # смещение нового спрайта относительно прежнего
    sx=lambda v:round(v*w/ow); sy=lambda v:h-1-round((obb-v)*h/oh)
    bb=(max(0,sx(old['bbox_left'])),max(0,sy(old['bbox_top'])),min(w-1,sx(old['bbox_right'])),h-1)
    org=(ox,oy) if (ox,oy)==(0,0) else (ox-dx,oy-dy)   # у сарая начало в низу: сдвигаем начало, экземпляр не трогаем
    for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',w),('height',h),('xorigin',org[0]),('yorigin',org[1])]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(name,k)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t)
    open(yf,'w').write(t)
    for fr in old['frames']:
        png.write(f'{d}/{fr["name"]}.png',w,h,img)
        for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',w,h,img)
    if (ox,oy)==(0,0):
        obj={'spr_house_farm':'obj_home','spr_bakery_building':'obj_bakery_outside'}[name]
        rp=f'{P}/rooms/rm_farm/rm_farm.yy'; room=open(rp).read()
        m=re.search(r'\{"\$GMRInstance":"v4","%Name":"\w+".*?"objectId":\{"name":"'+obj+r'".*?\},(?=\n)',room); line=m.group(0)
        x=float(re.search(r'"x":([-\d.]+)',line).group(1)); y=float(re.search(r'"y":([-\d.]+)',line).group(1))
        room=room.replace(line,re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{x+dx},"y":{y+dy}',line)); open(rp,'w').write(room)
        print('  ',obj,(x,y),'->',(x+dx,y+dy))
    print('  установлен: начало',org,'маска',bb)
