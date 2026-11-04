# Партия 07 (лист v4, art_incoming/village/07_props/v4/props_sheet_v4.png): фонарь, скамейка, доска объявлений,
# телефонная будка, ящики с цветами, клумба с камнями + новые кусты, трава и цветы в той же приглушённой палитре.
# Каждый кусок листа уменьшается до размера спрайта, который он заменяет (по ширине; фонарь — по высоте),
# так что места и маски в комнате не съезжают. Мягкие края и цветной ореол (альфа < 50%) отбрасываются.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
from b06_nature_convert import down,kmeans,clean,crop
SRC,OUT=sys.argv[1],sys.argv[2]
LAMP,BENCH,BOARD,PHONE=(99,99,200,417),(224,245,489,417),(522,108,821,422),(853,53,1151,439)
PL_WIDE,PL_LUPINE,PL_LONG,BED=(65,499,347,650),(389,481,574,650),(609,523,991,649),(1029,478,1390,652)
GRASS,GRASS_S,CLOVER,YELLOW,LUPINE,ROCKS,LEAVES=(68,707,210,818),(268,737,375,818),(444,728,580,821),(654,722,770,820),(832,700,961,819),(1015,719,1187,820),(1240,745,1367,820)
B_ROUND,B_WIDE,B_FLOW,B_BERRY=(132,876,323,1040),(399,900,667,1039),(757,884,984,1040),(1084,882,1299,1039)
SMALL=0.16    # общий масштаб травы и цветов (крупная трава -> 18 px)
# спрайт: (кусок листа, ('w'|'h', размер в игре), число цветов)
JOBS={'spr_village_lamp':(LAMP,('h',84),12),'spr_village2_lamp':(LAMP,('h',86),12),
      'spr_village2_bench':(BENCH,('w',84),14),'spr_village2_notice_board':(BOARD,('w',84),20),
      'spr_village2_phone_booth':(PHONE,('w',87),22),'spr_village2_planter_wide':(PL_WIDE,('w',91),18),
      'spr_village2_planter_small':(PL_LUPINE,('w',60),18),'spr_village3_planter_lupine':(PL_LUPINE,('w',36),14),
      'spr_village3_planter_small':(PL_LUPINE,('w',35),14),'spr_village3_planter_long':(PL_LONG,('w',71),14),
      'spr_village2_planter_long':(PL_LONG,('w',120),16),'spr_village2_flower_bush':(BED,('w',116),20),
      'spr_nature_bush_round':(B_ROUND,('h',39),14),'spr_nature_bush_wide':(B_WIDE,('h',36),14),
      'spr_nature_bush_flowers':(B_FLOW,('h',34),14),'spr_nature_bush_berries':(B_BERRY,('h',34),14),
      'spr_nature_grass_01':(GRASS,('h',round(111*SMALL)),7),'spr_nature_grass_02':(GRASS_S,('h',round(81*SMALL)),7),
      'spr_nature_grass_03':(GRASS_S,('h',9),6),'spr_nature_flowers_white':(CLOVER,('h',round(93*SMALL)),9),
      'spr_nature_flowers_orange':(YELLOW,('h',round(98*SMALL)),9),'spr_nature_lupine':(LUPINE,('h',round(119*SMALL)),9),
      'spr_nature_rocks_grass':(ROCKS,('h',round(101*SMALL)),9),'spr_nature_leaves':(LEAVES,('h',round(75*SMALL)),7)}
w,h,p=png.read(SRC); os.makedirs(OUT,exist_ok=True)
for name,((x0,y0,x1,y1),(ax,size),K) in JOBS.items():
    part=crop([[c if c[3]>=128 else (0,0,0,0) for c in r[x0:x1]] for r in p[y0:y1]]); pw,ph=len(part[0]),len(part)
    img=crop(clean(down(part,pw,ph,size/(pw if ax=='w' else ph)),'trees'))
    pts=[c[:3] for r in img for c in r if c[3]]; cent=kmeans(pts,K)
    near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    img=[[near(c)+(255,) if c[3] else (0,0,0,0) for c in r] for r in img]
    png.write(f'{OUT}/{name}.png',len(img[0]),len(img),img); print(name,len(img[0]),'x',len(img))
