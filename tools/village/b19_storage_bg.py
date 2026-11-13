# Подложка окна ящика хранения (spr_storage_bg) из книги дневника spr_diary_bg (836x470):
# на правой странице убраны белый лист и закладка (заливка бумагой — плавно между цветом бумаги слева и справа от листа
# в той же строке), на их место скопирована табличка заголовка с веточками с левой страницы (сдвиг +370 px).
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P=sys.argv[1]
d=f'{P}/sprites/spr_diary_bg'; f=[x for x in os.listdir(d) if x.endswith('.png')][0]
w,h,img=png.read(f'{d}/{f}'); img=[list(r) for r in img]
X0,X1,Y0,Y1,LS,RS=439,760,72,298,438,761
for y in range(Y0,Y1+1):
    a,b=img[y][LS],img[y][RS]
    for x in range(X0,X1+1):
        t=(x-LS)/(RS-LS); img[y][x]=tuple(round(a[i]+(b[i]-a[i])*t) for i in range(3))+(255,)
DX=370
for y in range(82,134):
    for x in range(86,388): img[y][x+DX]=img[y][x]
if not os.path.exists(f'{P}/sprites/spr_storage_bg'):
    gm_res.sprite(P,'spr_storage_bg',img,(0,0),(0,0,w-1,h-1),folder=('Ui','folders/Sprites/Ui.yy')); gm_res.add_to_yyp(P,['spr_storage_bg'])
else:
    d2=f'{P}/sprites/spr_storage_bg'
    for root,_,fs in os.walk(d2):
        for x in fs:
            if x.endswith('.png'): png.write(f'{root}/{x}',w,h,img)
print('spr_storage_bg',w,'x',h)
