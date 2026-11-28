# Зелёная тетрадь v2 (art_incoming/green_notebook_v2): развороты «Меч героя» и «поход к пещере» -> spr_green_notebook_sword
# (ширина 820) и spr_green_notebook_cave (920), как раньше. Берётся только книга (самый большой непрозрачный рисунок):
# кнопка «Дальше» с картинки отбрасывается (в игре своя). Уменьшение усреднением, без сокращения палитры — текст читается.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_anim
from b06_nature_convert import down,crop
A,P=sys.argv[1],sys.argv[2]
for src,name,W,(bx,by) in [('spread1_sword.png','spr_green_notebook_sword',820,(1100,895)),('spread2_cave.png','spr_green_notebook_cave',920,(1200,838))]:
    w,h,p=png.read(f'{A}/{src}')
    p=[[(0,0,0,0) if (x>=bx and y>=by) else c for x,c in enumerate(r)] for y,r in enumerate(p)]   # кнопка «Дальше» внизу справа
    # маска книги: заливка от большого непрозрачного компонента (по альфе >= 128)
    seen=bytearray(w*h); best=None
    for y in range(0,h,8):
        for x in range(0,w,8):
            if p[y][x][3]>=128 and not seen[y*w+x]:
                st=[(x,y)]; seen[y*w+x]=1; n=0; x0=x1=x; y0=y1=y
                while st:
                    a,b=st.pop(); n+=1; x0=min(x0,a);x1=max(x1,a);y0=min(y0,b);y1=max(y1,b)
                    for c,d in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                        if 0<=c<w and 0<=d<h and not seen[d*w+c] and p[d][c][3]>=128: seen[d*w+c]=1; st.append((c,d))
                if best is None or n>best[0]: best=(n,x0,y0,x1,y1)
    _,x0,y0,x1,y1=best
    im=[[c if c[3]>=8 else (0,0,0,0) for c in r[x0:x1+1]] for r in p[y0:y1+1]]
    s=down(im,len(im[0]),len(im),W/len(im[0]))
    s=[[tuple(int(round(v)) for v in c[:3])+(int(round(c[3])),) if c[3]>=8 else (0,0,0,0) for c in r] for r in s]
    gm_anim.sprite(P,name,[s],(0,0),(0,0,len(s[0])-1,len(s)-1),1,folder=('forest','folders/Sprites/forest.yy'))
    print(name,len(s[0]),'x',len(s),'книга на листе',x0,y0,x1,y1)
