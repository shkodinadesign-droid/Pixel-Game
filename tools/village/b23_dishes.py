# Превью блюд (art_incoming/dishes_v1/dishes_sheet_v1.png, 4x3 на прозрачном фоне) -> спрайты spr_dish_<id>.
# В каждой клетке листа берётся самый большой рисунок (блюдо с тарелкой) и всё рядом с ним (+10 px), что начинается выше низа тарелки; подпись
# под блюдом отбрасывается. Уменьшение в S раз, 32 цвета, начало — левый верхний угол.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]; S=0.45
NAMES=['potato_pie','carrot_pie','carrot_muffin','pizza','apple_bun','pudding','latte','cappuccino','cocoa','tea_aromatic','tea_sunny','tea_grandma']
w,h,p=png.read(SRC); A=lambda x,y:p[y][x][3]>=160
CW,CH=w//4,h//3; new=[]
for i,name in enumerate(NAMES):
    cx0,cy0=(i%4)*CW,(i//4)*CH; seen=set(); comps=[]
    for y in range(cy0,cy0+CH):
        for x in range(cx0,cx0+CW):
            if A(x,y) and (x,y) not in seen:
                st=[(x,y)]; seen.add((x,y)); pts=[]
                while st:
                    a,b=st.pop(); pts.append((a,b))
                    for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                        if cx0<=c<cx0+CW and cy0<=d<cy0+CH and (c,d) not in seen and A(c,d): seen.add((c,d)); st.append((c,d))
                xs=[q[0] for q in pts]; ys=[q[1] for q in pts]; comps.append((pts,(min(xs),min(ys),max(xs),max(ys))))
    big=max(comps,key=lambda c:len(c[0])); bx0,by0,bx1,by1=big[1]
    keep=[c for c in comps if c[1][0]<=bx1+10 and c[1][2]>=bx0-10 and c[1][1]<by1-8 and c[1][3]>=by0-10 and len(c[0])>30]
    pts=[q for c in keep for q in c[0]]
    X0=min(q[0] for q in pts); Y0=min(q[1] for q in pts); X1=max(q[0] for q in pts); Y1=max(q[1] for q in pts)
    im=[[(0,0,0,0)]*(X1-X0+1) for _ in range(Y1-Y0+1)]
    for x,y in pts: im[y-Y0][x-X0]=p[y][x][:3]+(255,)
    s=down(im,len(im[0]),len(im),S); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[k]-px[k])**2 for k in range(3)))
    s=[[near(c)+(255,) if c[3] else c for c in r] for r in s]
    sn='spr_dish_'+name
    if os.path.exists(f'{P}/sprites/{sn}'):
        for root,_,fs in os.walk(f'{P}/sprites/{sn}'):
            for x in fs:
                if x.endswith('.png'): png.write(f'{root}/{x}',len(s[0]),len(s),s)
    else:
        gm_res.sprite(P,sn,s,(0,0),(0,0,len(s[0])-1,len(s)-1),folder=('Ui','folders/Sprites/Ui.yy')); new.append(sn)
    print(sn,len(s[0]),'x',len(s))
gm_res.add_to_yyp(P,new)
