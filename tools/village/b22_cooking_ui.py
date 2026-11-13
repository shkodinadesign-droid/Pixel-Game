# Окно готовки по макету art_incoming/ui/cooking_v1/cooking_mockup_v1.png (1448x1086).
# Из макета вырезаются элементы (кнопки < >, табличка названия рецепта, ячейка ингредиента, квадратик чек-листа),
# с подложки стираются надписи, пирог и всё содержимое правой колонки (заливка цветом бумаги/листа той же строки),
# всё уменьшается в S раз, 32/16 цветов. Чёрный фон вокруг рамки — прозрачный. Пишет PNG в OUT и печатает разметку.
import sys,os,colorsys
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
from b06_nature_convert import down,kmeans,crop
SRC,OUT=sys.argv[1],sys.argv[2]; S=0.46
w,h,p=png.read(SRC); p=[[c[:3]+(255,) for c in r] for r in p]
d2=lambda a,b:sum((a[i]-b[i])**2 for i in range(3))
# чёрный фон -> прозрачный (заливка от краёв)
seen=bytearray(w*h); st=[(x,y) for x in range(w) for y in (0,h-1)]+[(x,y) for y in range(h) for x in (0,w-1)]
for x,y in st: seen[y*w+x]=1
while st:
    x,y=st.pop(); p[y][x]=(0,0,0,0)
    for a,b in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if 0<=a<w and 0<=b<h and not seen[b*w+a] and max(p[b][a][:3])<=34: seen[b*w+a]=1; st.append((a,b))
def cut(x0,y0,x1,y1): return [list(r[x0:x1+1]) for r in p[y0:y1+1]]
def clear_inner(im,ins,fill,thr):
    for y in range(ins,len(im)-ins):
        for x in range(ins,len(im[0])-ins):
            if d2(im[y][x],fill)>thr: im[y][x]=fill+(255,)
    return im
def finish(im,K):
    s=down(im,len(im[0]),len(im),S); s=[[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s]
    cent=kmeans([c[:3] for r in s for c in r if c[3]],K); near=lambda px:min(cent,key=lambda c:d2(c,px))
    return [[near(c)+(255,) if c[3] else c for c in r] for r in s]
os.makedirs(OUT,exist_ok=True)
el={}
el['btn_left']  = cut(641,190,711,256)
el['btn_right'] = cut(1258,190,1328,256)
el['name_plaque']=clear_inner(cut(745,189,1230,256),12,(253,215,156),900)
el['cell']      = clear_inner(cut(652,555,829,688),12,(243,201,143),900)
el['check_red'] = cut(643,282,682,321)
g=[]
for r in el['check_red']:
    row=[]
    for c in r:
        hh,ss,vv=colorsys.rgb_to_hsv(c[0]/255,c[1]/255,c[2]/255)
        if ss>0.35 and (hh<0.06 or hh>0.95): R,G,B=colorsys.hsv_to_rgb(0.30,ss*0.8,vv*0.95); c=(round(R*255),round(G*255),round(B*255),255)
        row.append(c)
    g.append(row)
el['check_green']=g
# подложка: текст таблички "ПЕКАРНЯ", пирог в левой рамке, вся правая колонка
for y in range(115,183):
    for x in range(228,566):
        if d2(p[y][x],(237,182,115))>900: p[y][x]=(237,182,115,255)
def wipe(x0,x1,y0,y1,ls,rs,thr):
    for y in range(y0,y1+1):
        a,b=p[y][ls],p[y][rs]
        for x in range(x0,x1+1):
            t=(x-ls)/(rs-ls); c=tuple(round(a[i]+(b[i]-a[i])*t) for i in range(3))
            if d2(p[y][x],c)>thr: p[y][x]=c+(255,)
wipe(160,540,262,876,156,544,300)
# правая колонка — целиком ровной бумагой (иначе остаются следы ячеек); у верха обходим листик таблички (x до 650)
wipe(652,1352,98,177,650,1356,-1)
wipe(618,1352,178,940,614,1356,-1)
for k,im in el.items(): s=finish(im,16); png.write(f'{OUT}/spr_cook_{k}.png',len(s[0]),len(s),s); print(k,len(s[0]),'x',len(s))
ys=[y for y in range(h) if any(c[3] for c in p[y])]; xs=[x for x in range(w) if any(p[y][x][3] for y in range(h))]
X0,Y0=min(xs),min(ys); bg=finish([r[X0:max(xs)+1] for r in p[Y0:max(ys)+1]],32)
png.write(f'{OUT}/spr_cook_bg.png',len(bg[0]),len(bg),bg); print('bg',len(bg[0]),'x',len(bg),'сдвиг',X0,Y0)
L=lambda v,o:round((v-o)*S)
print('РАЗМЕТКА (пиксели подложки):')
for n,(x,y) in {'title':((210+583)/2,(103+194)/2),'frame':(130,241),'frame2':(568,898),'navL':(641,190),'name':(745,189),'navR':(1258,190),'chk1':(643,282),'chk_text':(710,282),'cell1':(652,555),'cell2':(880,555),'cell3':(1105,555),'cell4':(652,748),'close':(1290,126),'orn':(724,965)}.items():
    print(' ',n,L(x,X0),L(y,Y0))
print('  шаг чек-листа',round(49.5*S),' шаг ячеек x',round(228*S),' y',round(193*S))
