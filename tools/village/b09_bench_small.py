# Скамейка деревни поменьше: spr_village2_bench заново из листа v4 (тот же кусок, что в b07_props_v4_convert.py),
# но шириной W px вместо 84. Спрайт меняется на месте; низ по центру остаётся на месте, маска — в тех же долях.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
from b06_nature_convert import down,kmeans,clean,crop
SRC,P=sys.argv[1],sys.argv[2]
NAME,BENCH,W,K='spr_village2_bench',(224,245,489,417),64,14
w,h,p=png.read(SRC); x0,y0,x1,y1=BENCH
part=crop([[c if c[3]>=128 else (0,0,0,0) for c in r[x0:x1]] for r in p[y0:y1]]); pw,ph=len(part[0]),len(part)
img=crop(clean(down(part,pw,ph,W/pw),'trees'))
pts=[c[:3] for r in img for c in r if c[3]]; cent=kmeans(pts,K)
near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]; nw,nh=len(img[0]),len(img)
d=f'{P}/sprites/{NAME}'; f=f'{d}/{NAME}.yy'; t=open(f).read(); old=yy.load(f); ow,oh=old['width'],old['height']
assert (old['sequence']['xorigin'],old['sequence']['yorigin'])==(ow//2,oh-1)
bb=(round(old['bbox_left']*nw/ow),nh-1-round((oh-1-old['bbox_top'])*nh/oh),min(nw-1,round(old['bbox_right']*nw/ow)),nh-1)
for k,v in [('bbox_left',bb[0]),('bbox_right',bb[2]),('bbox_top',bb[1]),('bbox_bottom',bb[3]),('width',nw),('height',nh),('xorigin',nw//2),('yorigin',nh-1)]:
    t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{nh}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{nw}.0',t)
open(f,'w').write(t)
for fr in old['frames']:
    png.write(f'{d}/{fr["name"]}.png',nw,nh,img)
    for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',nw,nh,img)
print(NAME,ow,'x',oh,'->',nw,'x',nh,'маска',bb)
