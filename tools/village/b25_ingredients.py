# Иконки ингредиентов для окна готовки (art_incoming/ingredients_v1/ingredients_sheet_v1.png, прозрачный фон)
# -> спрайты spr_ingr_<item_id> (по большей стороне 40 px, 24 цвета). Окно готовки берёт их через ingredient_icon().
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]; SIZE=40
BOX={'egg':(89,73,324,349),'milk':(489,38,705,361),'potato':(830,73,1133,345),'sugar':(1233,67,1509,343),'flour':(1613,47,1941,355),
     'water':(55,439,361,749),'carrot':(455,428,733,752),'strawberry':(830,433,1111,744),'coffee_beans':(1192,468,1520,732),'pepperoni':(1591,479,1946,714)}
w,h,p=png.read(SRC); img=[[c[:3]+(255,) if c[3]>=200 else (0,0,0,0) for c in r] for r in p]; new=[]
for k,(x0,y0,x1,y1) in BOX.items():
    im=crop([r[x0:x1+1] for r in img[y0:y1+1]])
    s=down(im,len(im[0]),len(im),SIZE/max(len(im[0]),len(im))); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],24); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    s=[[near(c)+(255,) if c[3] else c for c in r] for r in s]; sn='spr_ingr_'+k
    if os.path.exists(f'{P}/sprites/{sn}'):
        for root,_,fs in os.walk(f'{P}/sprites/{sn}'):
            for f in fs:
                if f.endswith('.png'): png.write(f'{root}/{f}',len(s[0]),len(s),s)
    else:
        gm_res.sprite(P,sn,s,(0,0),(0,0,len(s[0])-1,len(s)-1),folder=('Ui','folders/Sprites/Ui.yy')); new.append(sn)
    print(sn,len(s[0]),'x',len(s))
gm_res.add_to_yyp(P,new)
