# Джастин v1: кадры, нарисованные пользователем (art_incoming/characters/justin/v1, 15 файлов 32x48 с именами
# spr_max_idle_down*.png — имена ошибочные, позы определены по картинкам):
#   0 — стоит лицом, 1 — стоит спиной, 2..5 — шаг влево, 6..9 — шаг вверх (спиной), 10..14 — шаг вниз (11 = копия 10).
# Чистка: альфа порогом 128 (без полупрозрачного ореола), одна общая палитра на все кадры (PAL цветов),
# одиночные оторванные пиксели удаляются.
# Ошибка в кадре 5 (второй широкий шаг влево): туловище нарисовано иначе, чем в кадре 3 (нет рубашки, корпус уже,
# руки по-другому), поэтому фигура «дёргается». Исправление: голова и туловище с руками (строки 0..37) — из кадра 3,
# ноги (строки 38..47) — свои, из кадра 5.
# Кадры кладутся в существующие спрайты (имена, объекты, .yy не меняются); холст в проекте 32x56 —
# сверху добавляются 8 прозрачных строк, ноги остаются на нижней строке. walk_right — зеркало walk_left.
import sys,os
sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','village')); import png,yy
SRC,P=sys.argv[1],sys.argv[2]; OUT=sys.argv[3] if len(sys.argv)>3 else None
PAL=24; SEAM=38
BLUSH=(238,148,130)   # румянец близок к коже — его центр закреплён, иначе k-means сливает его с кожей
F=[]
for k in range(15):
    w,h,p=png.read(f'{SRC}/spr_max_idle_down'+('' if k==0 else f'-{k}')+'.png'); assert (w,h)==(32,48),k
    F.append([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in p])
F[5]=[r[:] for r in F[3][:SEAM]]+[r[:] for r in F[5][SEAM:]]
# общая палитра: k-means, начальные центры — самые удалённые друг от друга цвета (мелкие детали вроде глаз и румянца не теряются)
pts=[c[:3] for f in F for r in f for c in r if c[3]]
d2=lambda a,b:sum((a[i]-b[i])**2 for i in range(3))
uniq=list(set(pts)); cent=[BLUSH,max(set(pts),key=pts.count)]
while len(cent)<PAL: cent.append(max(uniq,key=lambda q:min(d2(q,c) for c in cent)))
for it in range(15):
    g=[[0,0,0,0] for _ in cent]
    for q in pts:
        j=min(range(len(cent)),key=lambda j:d2(q,cent[j])); s=g[j]; s[0]+=q[0]; s[1]+=q[1]; s[2]+=q[2]; s[3]+=1
    cent=[(s[0]/s[3],s[1]/s[3],s[2]/s[3]) if s[3] and j else cent[j] for j,s in enumerate(g)]
cent=[tuple(int(round(v)) for v in c) for c in cent]
near={q:min(cent,key=lambda c:d2(q,c)) for q in set(pts)}
for f in F:
    for r in f:
        for x,c in enumerate(r):
            if c[3]: r[x]=near[c[:3]]+(255,)
    # одиночный пиксель без соседей (по 8 направлениям) — мусор
    for y in range(48):
        for x in range(32):
            if f[y][x][3] and not any(f[y+dy][x+dx][3] for dx in (-1,0,1) for dy in (-1,0,1) if (dx or dy) and 0<=x+dx<32 and 0<=y+dy<48):
                f[y][x]=(0,0,0,0)
print('цветов в палитре:',len(set(cent)))
mirror=lambda f:[r[::-1] for r in f]
SPR={'spr_justin_idle_down':[F[0],F[2],F[1],mirror(F[2])],
     'spr_justin_idle_walk_left_strip4':[F[2],F[3],F[4],F[5]],
     'spr_justin_idle_walk_rightt_strip4':[mirror(F[k]) for k in (2,3,4,5)],
     'spr_justin_idle_walk_up_strip4':[F[6],F[7],F[8],F[9]],
     'spr_justin_walk_down':[F[10],F[12],F[13],F[14]]}
if OUT:
    os.makedirs(OUT,exist_ok=True)
    for k,f in enumerate(F): png.write(f'{OUT}/justin_{k:02d}.png',32,48,f)
for name,frames in SPR.items():
    d=f'{P}/sprites/{name}'; s=yy.load(f'{d}/{name}.yy'); assert (s['width'],s['height'])==(32,56) and len(s['frames'])==4,name
    for fr,img in zip(s['frames'],frames):
        img=[[(0,0,0,0)]*32 for _ in range(8)]+img
        png.write(f'{d}/{fr["name"]}.png',32,56,img)
        for L in s['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',32,56,img)
    print(name,'ok')
