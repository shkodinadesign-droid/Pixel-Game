# Дневник v1, установка: из сконвертированной книги (b14_diary_convert.py) убираются нарисованные на страницах
# 4 карточки слева и 2 ячейки справа внизу (заливка цветом бумаги этой же строки) — это общая подложка spr_diary_bg;
# содержимое разделов рисует obj_diary. Табличка заголовка, белый лист с закладкой, вкладки и орнаменты остаются.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy
SRC,P=sys.argv[1],sys.argv[2]
w,h,img=png.read(SRC); img=[list(r) for r in img]
for (x0,x1,y0,y1,sx) in [(59,387,142,392,56),(437,766,306,392,772)]:
    for y in range(y0,y1+1):
        c=img[y][sx]
        for x in range(x0,x1+1): img[y][x]=c
d=f'{P}/sprites/spr_diary_bg'; yf=f'{d}/spr_diary_bg.yy'; old=yy.load(yf); t=open(yf).read()
for k,v in [('bbox_left',0),('bbox_right',w-1),('bbox_top',0),('bbox_bottom',h-1),('width',w),('height',h)]:
    t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{h}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{w}.0',t); open(yf,'w').write(t)
for fr in old['frames']:
    png.write(f'{d}/{fr["name"]}.png',w,h,img)
    for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',w,h,img)
print('spr_diary_bg',w,'x',h)
