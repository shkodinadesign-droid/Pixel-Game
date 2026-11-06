# Партия 11: фруктовые деревья фермы (obj_tree_apple / obj_tree_pear) в стиле деревни.
# spr_apple_tree_empty и spr_pear_tree_empty получают картинку большого дерева деревни (spr_nature_tree_big);
# у груши — зеркально, чтобы деревья не были одинаковыми. Спрайты меняются на месте; начало — основание ствола,
# маска — та же, что у дерева деревни (только ствол). Экземпляры деревьев стоят где стояли.
# Плоды (obj_apple_on_tree / obj_pear_on_tree) переезжают на новую крону: центр плода в долях старой кроны
# переносится в те же доли новой.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
P=sys.argv[1]; SRC='spr_nature_tree_big'
TREES={'spr_apple_tree_empty':(False,'obj_tree_apple','obj_apple_on_tree'),'spr_pear_tree_empty':(True,'obj_tree_pear','obj_pear_on_tree')}
def load(s):
    d=yy.load(f'{P}/sprites/{s}/{s}.yy'); w,h,img=png.read(f'{P}/sprites/{s}/{d["frames"][0]["name"]}.png'); return d,w,h,img
def crown(d,w,h,img):
    # крона относительно основания ствола: сплошная полоса строк вокруг самой широкой, где ширина силуэта больше
    # половины самой широкой (трава под стволом у дерева деревни тоже широкая — её полоса отдельная)
    rows=[(y,[x for x in range(w) if img[y][x][3]]) for y in range(h)]; mw=max(len(r) for y,r in rows)
    y0=y1=max(range(h),key=lambda y:len(rows[y][1]))
    while y0>0 and len(rows[y0-1][1])>mw/2: y0-=1
    while y1<h-1 and len(rows[y1+1][1])>mw/2: y1+=1
    ys=range(y0,y1+1); xs=[x for y in ys for x in rows[y][1]]
    ox,oy=d['sequence']['xorigin'],d['sequence']['yorigin']
    return min(xs)-ox,min(ys)-oy,max(xs)+1-ox,max(ys)+1-oy
sd,sw,sh,simg=load(SRC)
rp=f'{P}/rooms/rm_farm/rm_farm.yy'; room=open(rp).read()
inst=lambda o:[m.group(0) for m in re.finditer(r'\{"\$GMRInstance":"v4","%Name":"\w+".*?\},(?=\n)',room) if f'"objectId":{{"name":"{o}"' in m.group(0)]
xy=lambda l:tuple(float(v) for v in re.search(r'"x":([-\d.]+),"y":([-\d.]+)',l).groups())
for s,(mir,tobj,fobj) in TREES.items():
    od,ow,oh,oimg=load(s); oc=crown(od,ow,oh,oimg)
    img=[r[::-1] for r in simg] if mir else [r[:] for r in simg]
    ox=sw-1-sd['sequence']['xorigin'] if mir else sd['sequence']['xorigin']; oy=sd['sequence']['yorigin']
    bl,br=(sw-1-sd['bbox_right'],sw-1-sd['bbox_left']) if mir else (sd['bbox_left'],sd['bbox_right'])
    nd={'sequence':{'xorigin':ox,'yorigin':oy}}; nc=crown(nd,sw,sh,img)
    # спрайт
    f=f'{P}/sprites/{s}/{s}.yy'; t=open(f).read()
    for k,v in [('bbox_left',bl),('bbox_right',br),('bbox_top',sd['bbox_top']),('bbox_bottom',sd['bbox_bottom']),('width',sw),('height',sh),('xorigin',ox),('yorigin',oy)]:
        t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
    t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{sh}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{sw}.0',t)
    open(f,'w').write(t)
    for fr in od['frames']:
        png.write(f'{P}/sprites/{s}/{fr["name"]}.png',sw,sh,img)
        for L in od['layers']: png.write(f'{P}/sprites/{s}/layers/{fr["name"]}/{L["name"]}.png',sw,sh,img)
    print(s,ow,'x',oh,'->',sw,'x',sh,'крона',oc,'->',nc)
    # плоды: к ближайшему дереву этого вида
    trees=[xy(l) for l in inst(tobj)]
    for l in inst(fobj):
        fx,fy=xy(l); sc=float(re.search(r'"scaleX":([-\d.]+)',l).group(1))
        half=24*sc*(27/24 if 'pear' in fobj else 1)/2                       # плод рисуется от левого верхнего угла
        tx,ty=min(trees,key=lambda p:(p[0]-fx)**2+(p[1]-fy)**2); cx,cy=fx+half-tx,fy+half-ty
        u,v=(cx-oc[0])/(oc[2]-oc[0]),(cy-oc[1])/(oc[3]-oc[1])
        ncx,ncy=nc[0]+u*(nc[2]-nc[0]),nc[1]+v*(nc[3]-nc[1])
        px,py=round(ncx+ox),round(ncy+oy); assert img[py][px][3],(fx,fy)    # центр плода — на кроне
        nx,ny=round(tx+ncx-half),round(ty+ncy-half)
        room=room.replace(l,re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(nx)},"y":{float(ny)}',l))
        print(' ',fobj,(fx,fy),'->',(nx,ny))
open(rp,'w').write(room); yy.load(rp)
