# Установка спрайтов окна готовки из b22_cooking_ui.py (папка OUT) + кнопка spr_cook_btn 170x31 — табличка названия,
# укороченная по середине (края 30 px как есть, середина — повтор центральных столбцов), без растяжения пикселей.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
OUT,P=sys.argv[1],sys.argv[2]
def load(f): w,h,p=png.read(f); return [list(r) for r in p]
def put(name,img):
    w,h=len(img[0]),len(img)
    if os.path.exists(f'{P}/sprites/{name}'):
        for root,_,fs in os.walk(f'{P}/sprites/{name}'):
            for x in fs:
                if x.endswith('.png'): png.write(f'{root}/{x}',w,h,img)
        return None
    gm_res.sprite(P,name,img,(0,0),(0,0,w-1,h-1),folder=('Ui','folders/Sprites/Ui.yy')); return name
new=[]
for k in ('bg','btn_left','btn_right','name_plaque','cell','check_red','check_green'):
    n=put(f'spr_cook_{k}',load(f'{OUT}/spr_cook_{k}.png')); new+=[n] if n else []
pl=load(f'{OUT}/spr_cook_name_plaque.png'); W=len(pl[0]); E=30; T=170; mid=W//2
btn=[r[:E]+[r[mid+((x-E)%8)-4] for x in range(E,T-E)]+r[W-E:] for r in pl]
n=put('spr_cook_btn',btn); new+=[n] if n else []
gm_res.add_to_yyp(P,new); print('новых',len(new))
# Дочистка: светлые следы стёртого текста внутри табличек (названия рецепта, кнопки, "Пекарня" на подложке)
from collections import Counter
def declean(name,x0,y0,x1,y1,full=False):
    d=f'{P}/sprites/{name}'
    for root,_,fs in os.walk(d):
        for f in fs:
            if not f.endswith('.png'): continue
            w,h,im=png.read(f'{root}/{f}'); im=[list(r) for r in im]
            mode=Counter(im[y][x][:3] for y in range(y0,y1) for x in range(x0,x1)).most_common(1)[0][0]
            for y in range(y0,y1):
                for x in range(x0,x1):
                    c=im[y][x]
                    if c[3] and (full or sum(c[:3])>sum(mode)+12): im[y][x]=mode+(255,)
            png.write(f'{root}/{f}',w,h,im)
declean('spr_cook_name_plaque',9,7,215,24,True); declean('spr_cook_btn',9,7,161,24,True); declean('spr_cook_bg',88,44,236,72)
print('дочищено')
