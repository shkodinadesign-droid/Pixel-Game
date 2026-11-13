# Партия 21: новая мебель магазина Джошуа из art_incoming/joshua_shop_v1/shop_sheet_v1.png (прозрачный фон).
# Предметы вырезаются по компонентам (альфа >= 200 — полупрозрачная красная кайма отбрасывается), уменьшаются
# по площади прежнего рисунка (стеллаж с фруктами — под высоту двух прежних ящиков, 192 px, и режется пополам),
# 32 цвета. Картинки меняются на месте: экземпляры не двигаются, низ рисунка на прежнем уровне (холст дополняется сверху).
import sys,os,re,math
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]
w,h,p=png.read(SRC)
img=[[c[:3]+(255,) if c[3]>=200 else (0,0,0,0) for c in r] for r in p]
BOX={'counter':(106,61,578,499),'fridge':(1000,95,1195,459),'rack':(75,561,242,1022),'shelfA':(321,601,685,942),'shelfB':(754,601,1119,941)}
def part(k):
    x0,y0,x1,y1=BOX[k]; return crop([r[x0:x1+1] for r in img[y0:y1+1]])
def conv(im,f):
    s=down(im,len(im[0]),len(im),f); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    return [[near(c)+(255,) if c[3] else c for c in r] for r in s]
def install(name,im):
    d=f'{P}/sprites/{name}'; yf=f'{d}/{name}.yy'; old=yy.load(yf); ow,oh=old['width'],old['height']
    nw,nh=len(im[0]),len(im); H=max(nh,oh)
    canvas=[[(0,0,0,0)]*nw for _ in range(H)]
    for y in range(nh): canvas[H-nh+y]=im[y]
    oy=H-oh                                        # низ рисунка на уровне прежнего низа, экземпляр на месте
    t=open(yf).read()
    for k,v in [('bbox_left',0),('bbox_right',nw-1),('bbox_top',H-nh),('bbox_bottom',H-1),('width',nw),('height',H),('xorigin',0),('yorigin',oy)]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,(name,k)
    if oy: t=re.sub(r'"origin":\d+','"origin":9',t)
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{H}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{nw}.0',t); open(yf,'w').write(t)
    for fr in old['frames']:
        png.write(f'{d}/{fr["name"]}.png',nw,H,canvas)
        for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',nw,H,canvas)
    print(name,ow,'x',oh,'->',nw,'x',nh,'(холст',nw,'x',H,', начало y',oy,')')
def area_fit(k,name):
    d=f'{P}/sprites/{name}'; old=yy.load(f'{d}/{name}.yy'); im=part(k)
    f=math.sqrt(old['width']*old['height']/(len(im[0])*len(im))); install(name,conv(im,f))
area_fit('counter','spr_shelfr'); area_fit('fridge','spr_frozen'); area_fit('shelfA','spr_storesh1'); area_fit('shelfB','spr_storesh2')
rk=conv(part('rack'),192/len(part('rack')))
if len(rk)!=192: rk=([[(0,0,0,0)]*len(rk[0])]*(192-len(rk))+rk)[-192:]
install('spr_fruitbox1',rk[:96]); install('spr_fruitbox2',rk[96:])
