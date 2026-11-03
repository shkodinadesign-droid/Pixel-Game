# Партия 06: импорт природы деревни в проект. Каждый PNG (после b06_nature_convert.py) — свой спрайт
# spr_nature_* (папка Sprites/Village nature) и свой объект obj_vn_*:
#   деревья, ели, кусты — наследники obj_village_prop (столкновение только у основания ствола/куста);
#   трава и цветы      — наследники obj_village_prop_soft (сквозь них можно ходить).
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
G,P=sys.argv[1],sys.argv[2]
FOLDER=('Village nature','folders/Sprites/Village nature.yy')
yyp=f'{P}/max_farm_demo.yyp'; s=open(yyp).read()
if FOLDER[1] not in s:
    k=s.index('  "Folders":[')+len('  "Folders":[')
    s=s[:k]+f'\n    {{"$GMFolder":"","%Name":"{FOLDER[0]}","folderPath":"{FOLDER[1]}","name":"{FOLDER[0]}","resourceType":"GMFolder","resourceVersion":"2.0",}},'+s[k:]
    open(yyp,'w').write(s)
names=[]
for cat in ('trees','bushes','grass','flowers'):
    for fn in sorted(os.listdir(f'{G}/{cat}')):
        spr=fn[:-4]; w,h,img=png.read(f'{G}/{cat}/{fn}')
        num,kind=spr.split('_')[2],spr.split('_')[3]          # spr_nature_05_pine -> 05, pine
        if cat=='trees':
            # начало координат и маска — у основания ствола (самый нижний коричневый пиксель)
            br=[(x,y) for y in range(h) for x in range(w) if img[y][x][3] and img[y][x][0]>img[y][x][1]+10]
            by=max(y for x,y in br); xs=[x for x,y in br if y>=by-6]; cx=(min(xs)+max(xs))//2
            origin,bb=(cx,by),(cx-6,by-7,cx+6,by)
            obj,parent=f'obj_vn_{"tree" if kind=="deciduous" else "pine"}_{num}','obj_village_prop'
        elif cat=='bushes':
            origin,bb=(w//2,h-1),(round(w*.2),h-9,round(w*.8),h-1)
            obj,parent=f'obj_vn_bush_{num}','obj_village_prop'
        else:
            origin,bb=(w//2,h-1),gm_res.opaque(img)
            obj,parent=f'obj_vn_{kind if cat=="grass" else "flower"}_{num}','obj_village_prop_soft'
        gm_res.sprite(P,spr,img,origin,bb,FOLDER)
        gm_res.obj(P,obj,spr,parent,solid=(parent=='obj_village_prop'))
        names+=[spr,obj]
gm_res.add_to_yyp(P,names)
print(len(names)//2,'спрайтов и объектов')
