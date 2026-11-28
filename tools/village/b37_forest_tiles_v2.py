# Новые тайлы леса (art_incoming/forest_v1/forest_tiles_v1.png, 4x4 клеток по ~313 px) -> spr_forest_tiles_v2 128x128
# в ТОЙ ЖЕ раскладке, что старый spr_forest_tiles (16 тайлов 32x32), и тайлсет tls_forest_v2. Комната леса просто
# переключается на новый тайлсет — дорога и поляны остаются на своих местах; старый tls_forest (деревня) не трогается.
# Лист уменьшается до 256x256 (клетка = 64 px = 2x2 тайла), 32 цвета.
#   1-3 трава, 4 земля, 5-6 земля сверху/трава снизу, 7-8 трава сверху/земля снизу, 9-10 земля слева/трава справа,
#   11-12 трава слева/земля справа, 13 скос «почти вся земля» (трава в углу справа-снизу), 14 скос «почти вся трава»
#   (земля в углу слева-сверху) — по диагоналям дороги, с отражениями; 15 земля (вариант).
import sys,os,re,uuid,shutil
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans
SRC,P=sys.argv[1],sys.argv[2]
w,h,p=png.read(SRC)
s=down([[c[:3]+(255,) for c in r] for r in p],w,h,256/w)
cent=kmeans([tuple(int(v) for v in c[:3]) for r in s for c in r][::3],32); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
s=[[near(c)+(255,) for c in r] for r in s]
# Бесшовность: крупные мягкие пятна на траве и земле обрываются на краях тайлов 32x32 и рисуют сетку —
# близкие к основному цвету травы/земли пиксели приводятся к нему, но только вдали (>3 px) от кромки дороги:
# тёмная травяная кайма, травинки и камешки остаются.
from collections import Counter
grass=Counter(c[:3] for r in s[0:64] for c in r).most_common(1)[0][0]
dirt =Counter(c[:3] for r in s[64:128] for c in r).most_common(1)[0][0]
d2=lambda a,b:sum((a[i]-b[i])**2 for i in range(3))
def flatten(tile):
    kind=[[('g' if d2(c,grass)<26**2 else 'd' if d2(c,dirt)<24**2 else 'x') for c in r] for r in tile]
    out=[list(r) for r in tile]
    for y in range(32):
        for x in range(32):
            k=kind[y][x]
            if k=='x': continue
            near_edge=any(kind[yy][xx] not in (k,'x') or (kind[yy][xx]=='x' and d2(tile[yy][xx],(60,80,40))<45**2)
                          for yy in range(max(0,y-3),min(32,y+4)) for xx in range(max(0,x-3),min(32,x+4)))
            if not near_edge: out[y][x]=(grass if k=='g' else dirt)+(255,)
    return out
def win(cx,cy,x0,y0):           # окно 32x32 из клетки (cx,cy) 64x64, с отступом (x0,y0)
    return [r[cx*64+x0:cx*64+x0+32] for r in s[cy*64+y0:cy*64+y0+32]]
T={0:[[(0,0,0,0)]*32 for _ in range(32)],
   1:win(0,0,0,0), 2:win(1,0,32,0), 3:win(3,0,0,32),
   4:win(0,1,16,16),
   5:win(0,2,0,32), 6:win(0,2,32,32),          # горизонтальная дорога, нижняя кромка: земля сверху
   7:win(0,2,0,0),  8:win(0,2,32,0),           # верхняя кромка: трава сверху, земля снизу
   9:win(1,2,32,0), 10:win(1,2,32,32),         # вертикальная дорога, правая кромка: земля слева
   11:win(1,2,0,0), 12:win(1,2,0,32),          # левая кромка: земля справа
   13:win(1,3,26,22),                          # скос: почти вся земля, скруглённый уголок травы справа-снизу
   14:win(1,3,32,32),                          # обратный скос: почти вся трава, земля в углу слева-сверху
   15:win(2,1,32,16)}
T={i:(flatten(v) if i else v) for i,v in T.items()}
img=[[(0,0,0,0)]*128 for _ in range(128)]
for i,t in T.items():
    ox,oy=(i%4)*32,(i//4)*32
    for y in range(32):
        for x in range(32): img[oy+y][ox+x]=t[y][x]
if not os.path.exists(f'{P}/sprites/spr_forest_tiles_v2'):
    gm_res.sprite(P,'spr_forest_tiles_v2',img,(0,0),(0,0,127,127),folder=('forest','folders/Sprites/forest.yy')); gm_res.add_to_yyp(P,['spr_forest_tiles_v2'])
else:
    for root,_,fs in os.walk(f'{P}/sprites/spr_forest_tiles_v2'):
        for f in fs:
            if f.endswith('.png'): png.write(f'{root}/{f}',128,128,img)
# тайлсет — копия tls_forest с новым спрайтом
td=f'{P}/tilesets/tls_forest_v2'
if not os.path.exists(td):
    os.makedirs(td); t=open(f'{P}/tilesets/tls_forest/tls_forest.yy').read().replace('tls_forest','tls_forest_v2').replace('spr_forest_tiles','spr_forest_tiles_v2')
    open(f'{td}/tls_forest_v2.yy','w').write(t)
    yp=f'{P}/max_farm_demo.yyp'; y=open(yp).read()
    y=y.replace('    {"id":{"name":"tls_forest","path":"tilesets/tls_forest/tls_forest.yy",},},','    {"id":{"name":"tls_forest","path":"tilesets/tls_forest/tls_forest.yy",},},\n    {"id":{"name":"tls_forest_v2","path":"tilesets/tls_forest_v2/tls_forest_v2.yy",},},',1)
    assert 'tls_forest_v2' in y; open(yp,'w').write(y)
rp=f'{P}/rooms/rm_forest_entrance/rm_forest_entrance.yy'; r=open(rp).read()
n=r.count('"tilesetId":{"name":"tls_forest","path":"tilesets/tls_forest/tls_forest.yy",}')
r=r.replace('"tilesetId":{"name":"tls_forest","path":"tilesets/tls_forest/tls_forest.yy",}','"tilesetId":{"name":"tls_forest_v2","path":"tilesets/tls_forest_v2/tls_forest_v2.yy",}')
open(rp,'w').write(r); print('слоёв переключено',n)
png.write(sys.argv[3] if len(sys.argv)>3 else '/dev/null',128,128,img)
