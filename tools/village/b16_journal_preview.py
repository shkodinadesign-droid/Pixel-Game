# Дневник v2 (архив PixelGame_Journal_UI): превью до внедрения. Книга 1672x941 уменьшается ровно в 2 раза (836x470,
# пиксели арта 2x2 — берём левый верхний пиксель блока), элементы ставятся 1:1 поверх. Текст в превью не рисуется
# (его рисует игра). Пишет PNG в OUT; проект не трогает.
import sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png
R,OUT=sys.argv[1],sys.argv[2]; S=f'{R}/sprites'
def load(p): w,h,px=png.read(p); return [list(r) for r in px]
def half(img): return [[img[y][x] for x in range(0,len(img[0])-1,2)] for y in range(0,len(img)-1,2)]
def blit(dst,src,x0,y0):
    for y,r in enumerate(src):
        for x,c in enumerate(r):
            X,Y=x0+x,y0+y
            if c[3] and 0<=Y<len(dst) and 0<=X<len(dst[0]):
                a=c[3]/255; d=dst[Y][X]
                dst[Y][X]=tuple(round(c[i]*a+d[i]*(1-a)) for i in range(3))+(255,)
SP={}
def sp(cat,name):
    k=(cat,name)
    if k not in SP: SP[k]=load(f'{S}/{cat}/{name}.png')
    return SP[k]
TABS=['quests','inventory','recipes','plants','adventures','friendship','money']
TAB_X=lambda i:64+i*57; TAB_Y=4; BOOK_Y=0
def book(kind,active):
    base=half(load(f'{S}/book/ui_journal_book_{kind}_1672x941.png'))
    W,H=len(base[0]),len(base); bg=(46,30,24,255)   # фон под книгой — затемнённая игра
    out=[[bg]*W for _ in range(H)]; blit(out,base,0,BOOK_Y)
    for i,t in enumerate(TABS):
        blit(out,sp('tabs',f'ui_tab_{t}_{"active" if i==active else "inactive"}'),TAB_X(i),TAB_Y)
    blit(out,sp('controls','ui_close_normal'),W-46,14)
    return out
os.makedirs(OUT,exist_ok=True)
for kind in ('base','reference_clean'):
    b=book(kind,0)
    # задания: заголовок группы + 4 карточки (одна выбрана, одна под мышью), значки статуса и типа
    blit(b,sp('quests','ui_quest_group_heading'),62,136)
    for i,st in enumerate(['selected','hover','normal','normal']):
        y=160+i*60; blit(b,sp('quests',f'ui_quest_card_{st}'),62,y)
        blit(b,sp('quests',['ui_quest_type_star','ui_quest_type_star','ui_quest_type_leaf','ui_quest_type_check'][i]),74,y+12)
        blit(b,sp('quests',['ui_quest_status_read','ui_quest_status_new','ui_quest_status_new','ui_quest_status_done'][i]),356,y+20)
    blit(b,sp('controls','ui_arrow_left_disabled'),180,404); blit(b,sp('controls','ui_arrow_right_normal'),236,404)
    png.write(f'{OUT}/journal_{kind}_quests.png',len(b[0]),len(b),b)
b=book('base',1)
for r in range(4):
    for c in range(5):
        st='selected' if (r,c)==(0,1) else ('hover' if (r,c)==(1,2) else ('item' if r*5+c<8 else 'empty'))
        x,y=95+c*54,150+r*54; blit(b,sp('inventory',f'ui_inventory_slot_{st}'),x,y)
        if st in('item','selected','hover'): blit(b,sp('inventory','ui_count_badge'),x+36,y+36)
blit(b,sp('inventory','ui_inventory_item_preview_96x96'),546,132); blit(b,sp('inventory','ui_quantity_label_200x28'),494,330)
png.write(f'{OUT}/journal_base_inventory.png',len(b[0]),len(b),b)
b=book('base',2)
for i,(st,ic) in enumerate([('active','bread'),('inactive','plate'),('inactive','cup')]):
    x=72+i*104; blit(b,sp('recipes',f'ui_recipe_category_{st}'),x,138); blit(b,sp('recipes',f'ui_recipe_icon_{ic}'),x+8,143)
for r in range(4):
    for c in range(4):
        st='selected' if (r,c)==(0,0) else ('normal' if r*4+c<3 else ('locked' if r*4+c<5 else 'empty'))
        blit(b,sp('recipes',f'ui_recipe_slot_{st}'),121+c*54,174+r*54)
blit(b,sp('recipes','ui_recipe_large_dish_200x120'),494,140)
for i in range(6):
    blit(b,sp('recipes','ui_recipe_ingredient_'+('missing' if i==4 else 'available')),446+(i//3)*162,306+(i%3)*28)
png.write(f'{OUT}/journal_base_recipes.png',len(b[0]),len(b),b)
b=book('base',3)
for i,st in enumerate(['selected','normal','normal']):
    y=150+i*62; blit(b,sp('plants',f'ui_plant_card_{st}'),62,y); blit(b,sp('plants','ui_plant_icon_clock'),122,y+32)
blit(b,sp('plants','ui_growth_stages_empty_260x64'),464,190)
for i,ic in enumerate(['clock','drop','sun']): blit(b,sp('plants',f'ui_plant_icon_{ic}'),470+i*90,320)
png.write(f'{OUT}/journal_base_plants.png',len(b[0]),len(b),b)
print('ok',len(b[0]),'x',len(b))
