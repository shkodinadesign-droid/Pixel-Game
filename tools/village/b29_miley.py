# Лист персонажа (Майли: art_incoming/miley_v1, Иван: art_incoming/ivan_v1 — одинаковая раскладка): ряд 1 — стоя (лицом x2, вправо x2, спиной x2, влево x2),
# ряд 2 — ходьба (вправо x4, влево x4), ряд 3 — 4 позы разговора, ряд 4 — 5 портретов.
# Фигуры: холст 48x48, рост 47 px (масштаб по ряду), низ по центру, начало (24,47); портреты 56x56. 32 цвета на спрайт.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_anim
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]; N=sys.argv[3] if len(sys.argv)>3 else 'miley'   # имя персонажа в спрайтах spr_<N>_*
FH=int(sys.argv[4]) if len(sys.argv)>4 else 47   # рост фигуры (Майли и Иван — 53, как бабуля Мэгги)
C=FH+3                                             # квадратный холст, низ по центру
w,h,p=png.read(SRC)
A=lambda c:c[3]>=200 and not (c[0]>190 and c[1]<70 and c[2]<70)
img=[[c[:3]+(255,) if A(c) else (0,0,0,0) for c in r] for r in p]
seen=bytearray(w*h); comps=[]
for y in range(h):
    for x in range(w):
        if img[y][x][3] and not seen[y*w+x]:
            st=[(x,y)]; seen[y*w+x]=1; pts=[]
            while st:
                a,b=st.pop(); pts.append((a,b))
                for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                    if 0<=c<w and 0<=d<h and not seen[d*w+c] and img[d][c][3]: seen[d*w+c]=1; st.append((c,d))
            if len(pts)>5000: comps.append(pts)
box=lambda pts:(min(a for a,b in pts),min(b for a,b in pts),max(a for a,b in pts),max(b for a,b in pts))
comps.sort(key=lambda c:((box(c)[1]+box(c)[3])//2//300,box(c)[0])); assert len(comps)==25,len(comps)
def cut(pts):
    x0,y0,x1,y1=box(pts); im=[[(0,0,0,0)]*(x1-x0+1) for _ in range(y1-y0+1)]
    for a,b in pts: im[b-y0][a-x0]=img[b][a]
    return im
def build(idx,H,CW,CH,align):
    ims=[cut(comps[i]) for i in idx]; f=H/max(len(i) for i in ims)
    sm=[crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in down(i,len(i[0]),len(i),f)]) for i in ims]
    cent=kmeans([c[:3] for s in sm for r in s for c in r if c[3]],32); near=lambda px:min(cent,key=lambda c:sum((c[k]-px[k])**2 for k in range(3)))
    out=[]
    for s in sm:
        fr=[[(0,0,0,0)]*CW for _ in range(CH)]; ox=(CW-len(s[0]))//2; oy=CH-len(s) if align=='bottom' else (CH-len(s))//2
        for y,r in enumerate(s):
            for x,c in enumerate(r):
                if c[3] and 0<=oy+y<CH and 0<=ox+x<CW: fr[oy+y][ox+x]=near(c)+(255,)
        out.append(fr)
    return out
rows=[list(range(0,8)),list(range(8,16))]
for name,idx,row in [(f'spr_{N}_idle_down',[0,1],0),(f'spr_{N}_idle_right',[2,3],0),(f'spr_{N}_idle_up',[4,5],0),(f'spr_{N}_idle_left',[6,7],0),
                     (f'spr_{N}_walk_right',[8,9,10,11],1),(f'spr_{N}_walk_left',[12,13,14,15],1)]:
    # масштаб по всему ряду (рост одинаковый во всех кадрах ряда)
    allr=[cut(comps[i]) for i in rows[row]]; H=FH*max(len(cut(comps[i])) for i in idx)/max(len(a) for a in allr)
    if N=='toby' and 'walk' in name:                               # у Тоби оба ряда ходьбы — один цикл вправо из 8 кадров
        fr=build(list(range(8,16)),round(H),C,C,'bottom')
        if name.endswith('left'): fr=[[list(reversed(r)) for r in f] for f in fr]   # влево — зеркало
    else:
        fr=build(idx,round(H),C,C,'bottom')
    gm_anim.sprite(P,name,fr,(C//2,C-1),(C//2-10,C-8,C//2+9,C-1),0); print(name,len(fr))
fr=build([16,17,18,19],FH,C,C,'bottom'); gm_anim.sprite(P,f'spr_{N}_talk',fr,(C//2,C-1),(C//2-10,C-8,C//2+9,C-1),0); print(f'spr_{N}_talk',4)
fr=build([20,21,22,23,24],54,56,56,'bottom'); gm_anim.sprite(P,f'spr_{N}_portrait_anim',fr,(0,0),(0,0,55,55),0,folder=('Ui','folders/Sprites/Ui.yy')); print(f'spr_{N}_portrait_anim',5)
# превью
import itertools
