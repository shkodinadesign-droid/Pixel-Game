# Дневник v2, установка ресурсов: подложка spr_diary_bg = ui_journal_book_reference_clean_1672x941 уменьшенная ровно в 2 раза
# (836x470, пиксели арта 2x2); элементы архива — новые спрайты spr_ui_* 1:1 (папка Sprites/Ui); вкладки — из b17 (иконки
# с утверждённой картинки на фоне вкладок архива).
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,yy,gm_res
R,TABS,P=sys.argv[1],sys.argv[2],sys.argv[3]; S=f'{R}/sprites'
def load(p): w,h,px=png.read(p); return [list(r) for r in px]
# 1) подложка
w,h,img=png.read(f'{S}/book/ui_journal_book_reference_clean_1672x941.png')
img=[[img[y][x] for x in range(0,w-1,2)] for y in range(0,h-1,2)]; W,H=len(img[0]),len(img)
d=f'{P}/sprites/spr_diary_bg'; yf=f'{d}/spr_diary_bg.yy'; old=yy.load(yf); t=open(yf).read()
for k,v in [('bbox_left',0),('bbox_right',W-1),('bbox_top',0),('bbox_bottom',H-1),('width',W),('height',H)]:
    t,n=re.subn(r'"'+k+r'":-?\d+',f'"{k}":{v}',t); assert n>=1,k
t=re.sub(r'"seqHeight":[\d.]+',f'"seqHeight":{H}.0',t); t=re.sub(r'"seqWidth":[\d.]+',f'"seqWidth":{W}.0',t); open(yf,'w').write(t)
for fr in old['frames']:
    png.write(f'{d}/{fr["name"]}.png',W,H,img)
    for L in old['layers']: png.write(f'{d}/layers/{fr["name"]}/{L["name"]}.png',W,H,img)
print('spr_diary_bg',W,'x',H)
# 2) элементы
names=[]
for cat in ('controls','quests','inventory','recipes','plants','tabs'):
    for f in sorted(os.listdir(f'{S}/{cat}')):
        if not f.endswith('.png'): continue
        src=f'{TABS}/{f}' if cat=='tabs' else f'{S}/{cat}/{f}'
        im=load(src); name='spr_'+f[:-4]
        if os.path.exists(f'{P}/sprites/{name}'): continue
        gm_res.sprite(P,name,im,(0,0),(0,0,len(im[0])-1,len(im)-1),folder=('Ui','folders/Sprites/Ui.yy')); names.append(name)
gm_res.add_to_yyp(P,names); print('новых спрайтов',len(names))
