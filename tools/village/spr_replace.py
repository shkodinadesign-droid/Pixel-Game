# Замена картинки в существующем однокадровом спрайте GameMaker (размер, bbox и origin пересчитываются).
import sys,os,re;sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)));import png
def opaque(img):
    ys=[y for y,r in enumerate(img) if any(c[3] for c in r)]; xs=[x for x in range(len(img[0])) if any(r[x][3] for r in img)]
    return min(xs),min(ys),max(xs),max(ys)
def replace(P,name,src,origin='bc',mask_h=None):
    d=f'{P}/sprites/{name}'; y=open(f'{d}/{name}.yy').read()
    w,h,img=png.read(src)
    fid=re.findall(r'"\$GMSpriteFrame":"[^"]*","%Name":"([^"]+)"',y); assert len(fid)==1; fid=fid[0]
    lid=re.findall(r'"\$GMImageLayer":"","%Name":"([^"]+)"',y)[0]
    for dst in [f'{d}/{fid}.png',f'{d}/layers/{fid}/{lid}.png']: png.write(dst,w,h,img)
    l,t,r,b=opaque(img)
    if mask_h: ins=2 if r-l>16 else 0; l,t,r=l+ins,max(t,b-mask_h+1),r-ins
    ox,oy=(w//2,h-1) if origin=='bc' else (0,0)
    for k,v in [('bbox_left',l),('bbox_right',r),('bbox_top',t),('bbox_bottom',b),('width',w),('height',h),('xorigin',ox),('yorigin',oy)]:
        y,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',y); assert n>=1,k
    y=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',y); y=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',y)
    open(f'{d}/{name}.yy','w').write(y); return w,h
