# Новые культуры для магазина Джо: иконки мешочков семян spr_tomato_seed_icon / spr_pumpkin_seed_icon / spr_onion_seed_icon
# (мешочек — spr_seed_carrot_icon, на этикетке вместо моркови — уменьшенная иконка культуры 12 px).
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
from collections import Counter
P=sys.argv[1]
def load(n):
    d=f'{P}/sprites/{n}'; f=[x for x in os.listdir(d) if x.endswith('.png')][0]; w,h,p=png.read(f'{d}/{f}'); return [list(r) for r in p]
bag=load('spr_seed_carrot_icon')
label=Counter(c[:3] for r in bag[11:27] for c in r[8:22] if c[3] and sum(c[:3])>600).most_common(1)[0][0]
new=[]
for crop_ in ('tomato','pumpkin','onion'):
    b=[list(r) for r in bag]
    for y in range(11,27):
        for x in range(8,22): b[y][x]=label+(255,)
    ic=crop(load(f'spr_{crop_}_icon')); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in down(ic,len(ic[0]),len(ic),12/max(len(ic),len(ic[0])))])
    ox=15-len(s[0])//2; oy=19-len(s)//2
    for y,r in enumerate(s):
        for x,c in enumerate(r):
            if c[3]: b[oy+y][ox+x]=tuple(int(round(v)) for v in c[:3])+(255,)
    n=f'spr_{crop_}_seed_icon'
    if os.path.exists(f'{P}/sprites/{n}'):
        for root,_,fs in os.walk(f'{P}/sprites/{n}'):
            for f in fs:
                if f.endswith('.png'): png.write(f'{root}/{f}',32,32,b)
    else:
        gm_res.sprite(P,n,b,(0,0),(0,0,31,31),folder=('Ui','folders/Sprites/Ui.yy')); new.append(n)
    print(n)
gm_res.add_to_yyp(P,new)
