# Партия 14: ведро колодца отдельно (для анимации набора воды) + иконка «ведро с водой».
# Из spr_well вырезаются верёвка (рисуется в коде) и ведро; место за ведром в проёме колодца
# заполняется кладкой с той же строки (x 20..29, между левым столбом и ведром).
# Создаёт: spr_well_bucket (пустое), spr_well_bucket_full (с водой), spr_water_bucket (иконка 32x32).
# Запуск: python3 tools/village/b14_well_bucket.py max_farm_demo
import sys,os,glob
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P=sys.argv[1]; d=f'{P}/sprites/spr_well'
frames=[f for f in glob.glob(f'{d}/*.png')]; assert len(frames)==1
W,H,well=png.read(frames[0]); well=[list(r) for r in well]
X0,X1,ROPE_Y0,TOP,RIM=30,47,56,61,82          # ведро: x 30..47, ручка с y=61, низ y=82
assert well[TOP+2][36][3] and not well[58][31][3], 'колодец уже разобран?'
warm=lambda c:c[3] and c[0]-c[1]>=40
bucket=[[(0,0,0,0)]*(X1-X0+1) for _ in range(TOP,RIM+1)]
for y in range(ROPE_Y0,TOP):                    # верёвка
    for x in range(34,45): well[y][x]=(0,0,0,0)
for y in range(TOP,RIM+1):
    for x in range(X0,X1+1):
        c=well[y][x]
        if y<74:
            if c[3]: bucket[y-TOP][x-X0]=c; well[y][x]=(0,0,0,0)
        elif warm(c):
            bucket[y-TOP][x-X0]=c; well[y][x]=well[y][20+(x-X0)%10]
for x in (37,41): bucket[63-TOP][x-X0]=(197,186,183,255)   # блики, съеденные чисткой фона
# ведро с водой: светлое дно -> вода
full=[r[:] for r in bucket]
for y,r in enumerate(full):
    for x,c in enumerate(r):
        if c[:3]==(197,186,183): r[x]=(96,158,214,255) if y+TOP==64 else (140,196,236,255)
for x in (37,38): full[63-TOP][x-X0]=(214,238,250,255)
full[64-TOP][36-X0]=(64,112,176,255); full[64-TOP][42-X0]=(64,112,176,255)
for f in [frames[0]]+glob.glob(f'{d}/layers/*/*.png'): png.write(f,W,H,well)
bw,bh=len(bucket[0]),len(bucket)
for name,img in [('spr_well_bucket',bucket),('spr_well_bucket_full',full)]:
    gm_res.sprite(P,name,img,(0,0),gm_res.opaque(img),folder=('Room farm','folders/Sprites/Room farm.yy'))
# иконка 32x32: ведро по центру, снизу
icon=[[(0,0,0,0)]*32 for _ in range(32)]; ox,oy=(32-bw)//2,32-bh-2
for y in range(bh):
    for x in range(bw):
        if full[y][x][3]: icon[oy+y][ox+x]=full[y][x]
for (x,y,c) in [(ox+bw-2,oy+6,(140,196,236,255)),(ox+bw-1,oy+8,(96,158,214,255)),(ox+bw-1,oy+9,(96,158,214,255))]:
    if 0<=x<32: icon[y][x]=c                     # капля с края
gm_res.sprite(P,'spr_water_bucket',icon,(0,0),gm_res.opaque(icon),folder=('Room farm','folders/Sprites/Room farm.yy'))
gm_res.add_to_yyp(P,['spr_well_bucket','spr_well_bucket_full','spr_water_bucket'])
print('ведро',bw,'x',bh,'с y',TOP,'x',X0)
