# Продукты и ростки (art_incoming/crops_v1):
#  products_v1.png (прозрачный фон, 3x2: морковь, картофель, клубника / помидор, тыква, лук) -> иконки 32x32
#    (spr_carrot_icon, spr_potato_icon, spr_straberry_icon — замена на месте; spr_tomato_icon, spr_pumpkin_icon, spr_onion_icon — новые)
#    и иконки окна готовки spr_ingr_carrot/potato/strawberry (до 40 px);
#  sprouts_v1.png (светлая «шахматка», 3 столбца x 6 рядов: росток, подрос, урожай; ряды — морковь, картофель, клубника,
#    помидор, тыква, лук) -> растения 32x32, начало в центре (16,16), низ холмика у низа клетки, общий масштаб для всех.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
A,P=sys.argv[1],sys.argv[2]; new=[]
def comps(img,minn=400):
    h,w=len(img),len(img[0]); seen=bytearray(w*h); out=[]
    for y in range(h):
        for x in range(w):
            if img[y][x][3] and not seen[y*w+x]:
                st=[(x,y)]; seen[y*w+x]=1; pts=[]
                while st:
                    a,b=st.pop(); pts.append((a,b))
                    for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                        if 0<=c<w and 0<=d<h and not seen[d*w+c] and img[d][c][3]: seen[d*w+c]=1; st.append((c,d))
                if len(pts)>=minn: out.append(pts)
    return out
def box(pts): xs=[p[0] for p in pts]; ys=[p[1] for p in pts]; return min(xs),min(ys),max(xs),max(ys)
def cut(img,pts):
    x0,y0,x1,y1=box(pts); im=[[(0,0,0,0)]*(x1-x0+1) for _ in range(y1-y0+1)]
    for x,y in pts: im[y-y0][x-x0]=img[y][x][:3]+(255,)
    return im
def shrink(im,f,K):
    s=down(im,len(im[0]),len(im),f); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],K); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    return [[near(c)+(255,) if c[3] else c for c in r] for r in s]
def canvas(s,W,H,valign):
    out=[[(0,0,0,0)]*W for _ in range(H)]; ox=(W-len(s[0]))//2; oy=(H-len(s)) if valign=='bottom' else (H-len(s))//2
    for y,r in enumerate(s):
        for x,c in enumerate(r):
            if c[3]: out[oy+y][ox+x]=c
    return out
def put(name,img,origin):
    w,h=len(img[0]),len(img)
    if os.path.exists(f'{P}/sprites/{name}'):
        for root,_,fs in os.walk(f'{P}/sprites/{name}'):
            for f in fs:
                if f.endswith('.png'): png.write(f'{root}/{f}',w,h,img)
    else:
        gm_res.sprite(P,name,img,origin,gm_res.opaque(img),folder=('plants','folders/Sprites/plants.yy')); new.append(name)
# --- продукты ---
w,h,p=png.read(f'{A}/products_v1.png'); img=[[c[:3]+(255,) if c[3]>=200 else (0,0,0,0) for c in r] for r in p]
cs=sorted(comps(img,2000),key=lambda c:((box(c)[1]+box(c)[3])//2//(h//2),box(c)[0])); assert len(cs)==6,len(cs)
ICON=['spr_carrot_icon','spr_potato_icon','spr_straberry_icon','spr_tomato_icon','spr_pumpkin_icon','spr_onion_icon']
INGR=['spr_ingr_carrot','spr_ingr_potato','spr_ingr_strawberry',None,None,None]
for c,ic,ig in zip(cs,ICON,INGR):
    im=cut(img,c); m=max(len(im),len(im[0]))
    put(ic,canvas(shrink(im,30/m,16),32,32,'center'),(0,0)); print(ic)
    if ig: put(ig,shrink(im,40/m,24),(0,0)); print(ig)
# --- ростки ---
w,h,p=png.read(f'{A}/sprouts_v1.png'); p=[list(r) for r in p]
bg=lambda c:min(c[:3])>=215 and max(c[:3])-min(c[:3])<=14
seen=bytearray(w*h); st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
for x,y in st: seen[y*w+x]=1
while st:
    x,y=st.pop(); p[y][x]=(0,0,0,0)
    for a,b in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=a<w and 0<=b<h and not seen[b*w+a] and bg(p[b][a]): seen[b*w+a]=1; st.append((a,b))
img=[[c[:3]+(255,) if c[3] else (0,0,0,0) for c in r] for r in p]
cs=sorted(comps(img,1500),key=lambda c:((box(c)[1]+box(c)[3])//2//(h//6),box(c)[0])); assert len(cs)==18,len(cs)
f=32/max(max(box(c)[2]-box(c)[0]+1,box(c)[3]-box(c)[1]+1) for c in cs)
CROPS=['carrot','potato','strawberry','tomato','pumpkin','onion']
for i,c in enumerate(cs):
    crop_,st_=CROPS[i//3],['sprout','stage1','ready'][i%3]
    put(f'spr_{crop_}_{st_}',canvas(shrink(cut(img,c),f,16),32,32,'bottom'),(16,16)); print(f'spr_{crop_}_{st_}')
gm_res.add_to_yyp(P,new); print('новых',len(new),'масштаб ростков %.3f'%f)
