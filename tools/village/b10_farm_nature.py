# Партия 10: на ферме (rm_farm) старая зелень заменяется природой деревни (obj_vn_*), старая скамейка — скамейкой
# деревни (obj_village2_bench). Каждый новый предмет встаёт туда, где у старого был низ по центру (по непрозрачным
# пикселям спрайта); имя экземпляра и слой сохраняются (порядок создания не меняется).
# Не трогаются: фруктовые деревья с плодами (квест: obj_tree_apple/pear, obj_apple_tree_fruit, obj_pear_tree,
# obj_*_on_tree), туи в горшках у пекарни (obj_decorativetree), ящик с цветами (obj_flowerbedh), Object98.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
P=sys.argv[1]
MAP={'obj_tree_maple':['obj_vn_tree_big','obj_vn_tree_mid'],'obj_tree_pine':['obj_vn_pine'],
     'obj_bush':['obj_vn_bush_round'],'obj_bush11':['obj_vn_bush_wide','obj_vn_bush_berries'],'obj_bush_2':['obj_vn_bush_flowers','obj_vn_bush_round'],
     'obj_bosh22':['obj_vn_bush_berries'],'obj_village_hedge':['obj_vn_bush_wide'],'obj_village3_hedge_small':['obj_vn_bush_round'],
     'obj_village_grass':['obj_vn_grass_01','obj_vn_grass_02'],'obj_village_flower_daisy':['obj_vn_flowers_white'],
     'obj_village_flower_yellow':['obj_vn_flowers_orange'],'obj_village_flower_lupine':['obj_vn_lupine'],
     'obj_fl':['obj_vn_flowers_white','obj_vn_lupine'],'obj_flower2':['obj_vn_flowers_orange'],'obj_flower3':['obj_vn_flowers_orange'],
     'obj_bench':['obj_village2_bench']}
MIRROR={'obj_vn_tree_big','obj_vn_tree_mid','obj_vn_pine','obj_vn_bush_round','obj_vn_bush_wide'}   # через одного — зеркально, для разнообразия
def spr(o):
    s=yy.load(f'{P}/objects/{o}/{o}.yy')['spriteId']['name']; d=yy.load(f'{P}/sprites/{s}/{s}.yy')
    w,h,img=png.read(f'{P}/sprites/{s}/{d["frames"][0]["name"]}.png')
    xs=[x for y in range(h) for x in range(w) if img[y][x][3]]; ys=[y for y in range(h) for x in range(w) if img[y][x][3]]
    return d['sequence']['xorigin'],d['sequence']['yorigin'],(min(xs)+max(xs)+1)/2,max(ys)+1
rp=f'{P}/rooms/rm_farm/rm_farm.yy'; t=open(rp).read(); n=0; used={}
for m in list(re.finditer(r'\{"\$GMRInstance":"v4","%Name":"\w+".*?\},(?=\n)',t)):
    line=m.group(0); o=re.search(r'"objectId":\{"name":"(\w+)"',line).group(1)
    if o not in MAP: continue
    x,y=(float(v) for v in re.search(r'"x":([-\d.]+),"y":([-\d.]+)',line).groups())
    sx,sy=(float(v) for v in re.search(r'"scaleX":([-\d.]+),"scaleY":([-\d.]+)',line).groups())
    ox,oy,cx,by=spr(o); bx,bby=x+(cx-ox)*sx,y+(by-oy)*sy                     # низ по центру старого
    k=used.get(o,0); used[o]=k+1; new=MAP[o][k%len(MAP[o])]
    nox,noy,ncx,nby=spr(new); mir=-1.0 if new in MIRROR and k%2 else 1.0
    nx,ny=round(bx-(ncx-nox)*mir),round(bby-(nby-noy))
    nl=line.replace(f'"name":"{o}","path":"objects/{o}/{o}.yy"',f'"name":"{new}","path":"objects/{new}/{new}.yy"')
    nl=re.sub(r'"scaleX":[-\d.]+,"scaleY":[-\d.]+',f'"scaleX":{mir},"scaleY":1.0',nl)
    nl=re.sub(r'"x":[-\d.]+,"y":[-\d.]+',f'"x":{float(nx)},"y":{float(ny)}',nl); assert new in nl
    t=t.replace(line,nl); n+=1; print(o,(x,y),'->',new,(nx,ny),'зеркально' if mir<0 else '')
open(rp,'w').write(t); yy.load(rp); print('заменено',n)
