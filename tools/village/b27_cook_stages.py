# Стадии готовки для рамки окна готовки (art_incoming/ui/cooking_v1/stages, 1254x1254, прозрачный фон):
# 1 миска с ингредиентами, 2 замешивание, 3 духовка, 4 готовый пирог с блёстками -> spr_cook_stage1..4.
# Красная кайма (чисто-красные полупрозрачные пиксели генерации) и мелкие оторванные точки убираются; общий масштаб
# для всех стадий (самый крупный рисунок — 170 px), 32 цвета. Начало — центр рисунка.
# Иконка дрожжей для ячеек (spr_ingr_yeast, до 40 px) — из icons_cells.png (5-я).
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
D,P=sys.argv[1],sys.argv[2]; new=[]
def clean(p):
    w,h=len(p[0]),len(p)
    img=[[(0,0,0,0) if (c[3]<200 or (c[0]>190 and c[1]<70 and c[2]<70)) else c[:3]+(255,) for c in r] for r in p]
    seen=bytearray(w*h)
    for y in range(h):
        for x in range(w):
            if img[y][x][3] and not seen[y*w+x]:
                st=[(x,y)]; seen[y*w+x]=1; pts=[]
                while st:
                    a,b=st.pop(); pts.append((a,b))
                    for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                        if 0<=c<w and 0<=d<h and not seen[d*w+c] and img[d][c][3]: seen[d*w+c]=1; st.append((c,d))
                if len(pts)<150:
                    for a,b in pts: img[b][a]=(0,0,0,0)
    return crop(img)
def shrink(im,f,K):
    s=down(im,len(im[0]),len(im),f); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],K); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    return [[near(c)+(255,) if c[3] else c for c in r] for r in s]
def put(name,img,origin):
    w,h=len(img[0]),len(img)
    if os.path.exists(f'{P}/sprites/{name}'):
        for root,_,fs in os.walk(f'{P}/sprites/{name}'):
            for f in fs:
                if f.endswith('.png'): png.write(f'{root}/{f}',w,h,img)
    else:
        gm_res.sprite(P,name,img,origin,gm_res.opaque(img),folder=('Ui','folders/Sprites/Ui.yy')); new.append(name)
ims=[]
for f in ['stage1_mix','stage2_stir','stage3_oven','stage4_pie']:
    w,h,p=png.read(f'{D}/{f}.png'); ims.append(clean(p))
F=170/max(max(len(i),len(i[0])) for i in ims)
for k,im in enumerate(ims,1):
    s=shrink(im,F,32); put(f'spr_cook_stage{k}',s,(len(s[0])//2,len(s)//2)); print(f'spr_cook_stage{k}',len(s[0]),'x',len(s))
w,h,p=png.read(f'{D}/icons_cells.png'); img=[[c[:3]+(255,) if c[3]>=200 else (0,0,0,0) for c in r] for r in p]
y=crop([r[1560:1900] for r in img[180:600]]); s=shrink(y,40/max(len(y),len(y[0])),24); put('spr_ingr_yeast',s,(0,0)); print('spr_ingr_yeast',len(s[0]),'x',len(s))
gm_res.add_to_yyp(P,new)
