# Партия 06, v3: перерисованная природа (один лист art_incoming/village/06_nature/v3/nature_sheet_v3.png).
# Лист режется по прямоугольникам, каждый спрайт уменьшается до игрового размера, как в v2:
# деревья одним общим масштабом (большое дерево 96 px), ель 92 px, кусты/трава/цветы — по размерам v2.
# Мягкие края и цветной ореол вокруг цветов (альфа < 50%) отбрасываются.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
from b06_nature_convert import down,kmeans,clean,crop
SRC,OUT=sys.argv[1],sys.argv[2]
TREE=96/430
# имя: (x0,y0,x1,y1 в листе, высота в игре, число цветов)
CUT={'tree_big':((51,73,469,503),round(430*TREE),20),'tree_mid':((500,174,784,498),round(324*TREE),18),
     'tree_small':((845,271,1031,493),round(222*TREE),16),'pine':((1118,149,1380,499),92,20),
     'bush_round':((76,581,303,776),39,14),'bush_wide':((413,597,722,771),36,14),
     'bush_flowers':((820,597,1044,763),34,14),'bush_berries':((1150,599,1374,767),34,14),
     'grass_01':((96,896,218,994),14,7),'grass_02':((327,887,469,990),15,7),'grass_03':((573,925,668,980),9,6),
     'flowers_orange':((785,860,893,990),20,9),'flowers_white':((1002,860,1118,990),20,9),'leaves':((1214,904,1351,985),11,6)}
w,h,p=png.read(SRC); os.makedirs(OUT,exist_ok=True)
for name,((x0,y0,x1,y1),TH,K) in CUT.items():
    part=[[c if c[3]>=128 else (0,0,0,0) for c in r[x0:x1]] for r in p[y0:y1]]
    part=crop(part); pw,ph=len(part[0]),len(part)
    img=crop(clean(down(part,pw,ph,TH/ph),'trees' if name.startswith(('tree','pine','bush')) else ''))
    pts=[c[:3] for r in img for c in r if c[3]]; cent=kmeans(pts,K)
    near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]
    png.write(f'{OUT}/spr_nature_{name}.png',len(img[0]),len(img),img); print(name,len(img[0]),'x',len(img))
