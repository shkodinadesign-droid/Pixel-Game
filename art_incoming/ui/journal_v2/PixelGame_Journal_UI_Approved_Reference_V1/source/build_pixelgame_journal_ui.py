from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import csv, json, zipfile, math, random
from collections import deque

OUT=Path('/mnt/data/PixelGame_Journal_UI_Approved_Reference_V1')
OUT.mkdir(exist_ok=True)
S=OUT/'sprites'
S.mkdir(exist_ok=True)
W,H=1672,941
P={
 'paper':'#FCDEAA', 'card':'#EAC698', 'card_border':'#CB9F6C',
 'frame':'#AC6837', 'white':'#FAF1E2', 'cover':'#793929',
 'inactive':'#F1C488', 'ink':'#5E3626', 'outline':'#51281F',
 'bright':'#FFE8BB', 'paper_shadow':'#E9BD82', 'card_hover':'#F1D4AA',
 'paper_rim':'#E9BF82', 'rust':'#BE6E37', 'red':'#C74740',
 'green':'#609C63', 'gray':'#9C948A', 'gray_light':'#D0C4B8',
 'gold':'#DFA453', 'orange':'#D87A32', 'leaf':'#9E8B4C'
}

def C(name): return P.get(name,name)

def poly_rect(x,y,w,h,c=6):
    # solid stepped corners, all integer aligned, pixel-art; c should be even
    c=min(c,w//3,h//3)
    return [(x+c,y),(x+w-c-1,y),(x+w-1,y+c),
            (x+w-1,y+h-c-1),(x+w-c-1,y+h-1),
            (x+c,y+h-1),(x,y+h-c-1),(x,y+c)]

def stepped(d,x,y,w,h,fill,edge=None,c=4,b=2):
    if w<4 or h<4: return
    d.polygon(poly_rect(x,y,w,h,c),fill=C(edge or fill))
    if edge and b>0 and w>2*b and h>2*b:
        d.polygon(poly_rect(x+b,y+b,w-2*b,h-2*b,max(1,c-b)),fill=C(fill))

def line(d,points,fill='ink',width=2): d.line(points,fill=C(fill),width=width,joint='curve')

def diamonds(d,cx,cy):
    for off, size in [(-26,4),(0,7),(26,4)]:
        d.polygon([(cx+off,cy-size),(cx+off+size,cy),(cx+off,cy+size),(cx+off-size,cy)],fill=C('frame'))

def branch(d,x,y,flip=1):
    # small ornamental leaves in the book heading, pixel cutouts
    line(d,[(x,y+18),(x+flip*18,y+5)],'frame',3)
    for dx,dy,dd in [(4,12,-1),(11,7,1),(17,3,-1)]:
        xx=x+flip*dx; yy=y+dy
        d.polygon([(xx,yy),(xx+flip*6,yy-6*dd),(xx+flip*10,yy-4*dd),(xx+flip*4,yy+2*dd)],fill=C('frame'))

def build_book():
    im=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    # cover and spine; bright edging underneath paper
    stepped(d,31,55,1587,858,'cover','outline',36,7)
    stepped(d,44,68,1560,831,'cover','frame',30,6)
    # book cover top emboss and outer top segments
    d.rectangle((76,62,1590,98),fill=C('cover'))
    d.rectangle((77,66,1587,71),fill=C('frame'))
    for x in (850,1130,1400):
        d.rectangle((x,67,x+6,99),fill=C('outline'))
    # leaf stack layers along bottom and lower corners
    stepped(d,71,111,1503,763,'paper_shadow','cover',30,8)
    stepped(d,67,104,1512,760,'paper','frame',30,6)
    # right-side paper section separately, paper border
    stepped(d,835,100,741,757,'paper','card_border',26,7)
    # left-side page white-ish inner gloss strip and border
    stepped(d,85,112,735,737,'paper','bright',18,4)
    stepped(d,850,113,705,734,'paper','bright',18,4)
    # inside page boundary ornament lines
    stepped(d,117,129,687,690,'paper','frame',12,4)
    stepped(d,864,129,672,690,'paper','frame',12,4)
    # revert inner book to clean, flat page color, maintaining border edges
    d.rectangle((125,138,796,808),fill=C('paper'))
    d.rectangle((872,138,1527,808),fill=C('paper'))
    # retained inner-edge strokes in several corners
    for x,y,sx,sy in [(137,148,1,1),(783,148,-1,1),(137,796,1,-1),(783,796,-1,-1),
                      (884,148,1,1),(1514,148,-1,1),(884,796,1,-1),(1514,796,-1,-1)]:
        d.rectangle((min(x,x+6*sx),min(y,y+6*sy),max(x,x+6*sx),max(y,y+6*sy)),fill=C('frame'))
        d.rectangle((min(x+10*sx,x+14*sx),min(y+9*sy,y+13*sy),max(x+10*sx,x+14*sx),max(y+9*sy,y+13*sy)),fill=C('frame'))
    # central binding and fold
    d.polygon([(806,108),(829,122),(853,106),(853,842),(832,880),(809,840)], fill=C('card_border'))
    d.polygon([(816,114),(831,123),(845,115),(845,843),(832,863),(819,843)], fill=C('paper_shadow'))
    d.line([(827,124),(827,853)],fill=C('frame'),width=3)
    d.line([(837,124),(837,853)],fill=C('paper'),width=4)
    # left heading plaque centered near top, with stylized bracket ends
    stepped(d,240,166,461,96,'card','frame',16,6)
    stepped(d,253,176,435,75,'card','card_border',12,4)
    d.rectangle((265,187,677,238), fill=C('card'))
    branch(d,184,203,1); branch(d,747,203,-1)
    # large right page pinned white paper; blank main area reserved for system text
    stepped(d,879,184,617,394,'white','frame',24,7)
    stepped(d,889,194,596,372,'white','card_border',18,4)
    stepped(d,900,204,572,350,'white','paper_rim',12,2)
    # top bookmark on sheet
    d.polygon([(1133,170),(1148,156),(1249,156),(1262,170),(1262,254),(1198,233),(1133,254)], fill=C('frame'))
    d.polygon([(1141,173),(1152,164),(1245,164),(1254,172),(1254,240),(1198,220),(1141,240)], fill=C('rust'))
    d.polygon([(1198,182),(1201,197),(1210,203),(1199,208),(1198,215),(1187,207),(1185,201),(1196,198)],fill=C('bright'))
    # bottom edge ornament on both pages
    for cx in (463,1184):
        d.rectangle((cx-151,787,cx-47,791),fill=C('frame'))
        d.rectangle((cx+47,787,cx+151,791),fill=C('frame'))
        diamonds(d,cx,789)
    # bottom paper layers, with irregular pixel stepped edges to mimic original page
    for x1,x2,y in [(85,815,843),(855,1554,843),(97,813,852),(863,1541,852)]:
        d.line((x1,y,x2,y),fill=C('card_border'),width=4)
    d.polygon([(74,838),(313,838),(587,844),(804,843),(828,864),(848,843),(1073,843),(1352,837),(1560,838),(1565,856),(850,869),(832,879),(810,863),(80,865)],fill=C('paper_shadow'))
    # front of page stack with dark notch
    d.line([(90,860),(754,859),(819,868),(831,879),(847,870),(917,859),(1554,860)],fill=C('frame'),width=5)
    d.line([(90,855),(754,854),(819,862)],fill=C('bright'),width=3)
    d.line([(846,862),(917,853),(1554,855)],fill=C('bright'),width=3)
    # bookmark coming out bottom left
    d.polygon([(157,855),(199,855),(199,913),(179,898),(157,916)], fill=C('outline'))
    d.polygon([(162,859),(194,859),(194,906),(179,892),(162,909)], fill=C('rust'))
    # warm cover bottom edge
    d.line([(90,888),(768,888),(810,909),(845,910),(894,888),(1567,889)],fill=C('outline'),width=5)
    return im


def blank(w,h): return Image.new('RGBA',(w,h),(0,0,0,0))

# pixel symbol primitives all drawn at requested size

def draw_icon(d,name,x,y,scale=1,color='ink'):
    """Draw within about 24x24*s, no smoothing; simple pixel icon silhouettes."""
    s=scale
    ink=C(color); light=C('bright'); edge=C('outline')
    def R(a,b,c,e,col=ink): d.rectangle((x+a*s,y+b*s,x+c*s,y+e*s),fill=col)
    def L(pts,col=ink,width=2): d.line([(x+a*s,y+b*s) for a,b in pts],fill=col,width=max(1,width*s))
    def E(a,b,c,e,col=ink,wid=2): d.ellipse((x+a*s,y+b*s,x+c*s,y+e*s),outline=col,width=max(1,wid*s))
    if name=='note':
        R(4,2,19,22); R(7,5,17,19,light); R(9,8,15,9); R(9,12,15,13); R(9,16,14,17)
    elif name=='backpack':
        R(6,6,18,20); R(4,9,7,16); R(17,9,20,16); R(7,7,10,9,ink); R(15,7,18,9,ink)
        R(8,4,11,6); R(14,4,17,6); R(9,11,16,17,light); R(11,13,13,15)
    elif name=='chef':
        for i,j in [(3,9),(6,4),(12,3),(17,5)]: E(i,j,i+5,j+7,ink,2)
        R(5,11,20,16,light); R(5,15,20,22); R(7,17,18,19,light)
    elif name=='apple':
        E(5,8,20,22,ink,3); R(12,5,13,10); L([(13,6),(18,3),(21,5),(17,7)],ink,2)
    elif name=='sword':
        L([(5,19),(18,5)],ink,4); L([(15,4),(20,3),(18,8)],ink,3)
        L([(7,12),(13,18)],ink,3); L([(3,21),(7,17)],ink,3)
    elif name=='heart':
        d.polygon([(x+12*s,y+21*s),(x+3*s,y+12*s),(x+3*s,y+7*s),(x+7*s,y+4*s),(x+12*s,y+8*s),(x+17*s,y+4*s),(x+21*s,y+7*s),(x+21*s,y+12*s)],fill=ink)
    elif name=='coin':
        E(2,2,22,22,ink,3); E(6,6,18,18,ink,2); L([(15,8),(10,8),(8,10),(8,15),(10,17),(15,17)],ink,2)
    elif name=='star':
        d.polygon([(x+12*s,y+1*s),(x+15*s,y+9*s),(x+23*s,y+9*s),(x+17*s,y+15*s),(x+19*s,y+23*s),(x+12*s,y+18*s),(x+5*s,y+23*s),(x+7*s,y+15*s),(x+1*s,y+9*s),(x+9*s,y+9*s)],fill=ink)
    elif name=='leaf':
        d.polygon([(x+3*s,y+18*s),(x+9*s,y+6*s),(x+21*s,y+3*s),(x+19*s,y+15*s),(x+10*s,y+22*s)],fill=ink)
        L([(6,19),(14,12),(19,8)],light,1)
    elif name=='check': L([(4,12),(9,17),(20,5)],ink,4)
    elif name=='bread':
        d.polygon([(x+2*s,y+13*s),(x+3*s,y+8*s),(x+8*s,y+5*s),(x+15*s,y+4*s),(x+22*s,y+9*s),(x+21*s,y+19*s),(x+4*s,y+19*s)],fill=ink)
        L([(8,10),(7,13)],light,2); L([(13,8),(12,12)],light,2)
    elif name=='plate':
        E(3,9,21,18,ink,2); E(7,11,17,16,ink,2)
    elif name=='cup':
        R(4,9,17,19); R(6,11,15,16,light); E(15,10,22,17,ink,2)
        L([(8,6),(9,3)],ink,1); L([(13,6),(14,3)],ink,1)
    elif name=='lock':
        E(6,2,18,16,ink,3); R(4,11,20,22); R(11,15,13,19,light)
    elif name=='clock':
        E(3,3,21,21,ink,3); L([(12,6),(12,12),(17,15)],ink,2)
    elif name=='drop':
        d.polygon([(x+12*s,y+2*s),(x+20*s,y+14*s),(x+19*s,y+19*s),(x+15*s,y+22*s),(x+9*s,y+22*s),(x+5*s,y+18*s),(x+4*s,y+14*s)],fill=ink)
    elif name=='sun':
        E(8,8,17,17,ink,2)
        for a,b,c,e in [(12,1,12,5),(12,20,12,23),(1,12,5,12),(20,12,23,12),(4,4,6,6),(18,18,20,20),(4,20,6,18),(18,6,20,4)]: L([(a,b),(c,e)],ink,2)
    elif name=='left': L([(15,5),(8,12),(15,19)],ink,3)
    elif name=='right': L([(9,5),(16,12),(9,19)],ink,3)
    elif name=='cross': L([(6,6),(18,18)],ink,3); L([(18,6),(6,18)],ink,3)
    elif name=='exclaim': R(11,5,13,15); R(11,18,13,20)
    else: R(4,4,20,20)

items=[]

def save_item(key,category,im,desc,slot=None):
    p=S/category
    p.mkdir(exist_ok=True)
    filename=key+'.png'
    im.save(p/filename)
    items.append({'id':key,'category':category,'file':f'sprites/{category}/{filename}','width':im.width,'height':im.height,'description':desc,'game_field':slot or ''})

book=build_book()
save_item('ui_journal_book_base_1672x941','book',book,'Книга без вкладок, карточек и текста; вся структура в 1672x941 px')

# tabs
for key,label,ic in [('quests','Задания','note'),('inventory','Инвентарь','backpack'),('recipes','Рецепты','chef'),('plants','Растения','apple'),('adventures','Приключения','sword'),('friendship','Дружба','heart'),('money','Деньги','coin')]:
    for state in ['inactive','active']:
        im=blank(50,48);d=ImageDraw.Draw(im)
        top=4 if state=='inactive' else 0
        h=48-top
        stepped(d,1,top+1,48,h-1,'inactive' if state=='inactive' else 'paper','outline',7,3)
        stepped(d,4,top+4,42,h-6,'inactive' if state=='inactive' else 'paper','card_border',5,2)
        if state=='active':
            # visually joins the page below, no bottom border
            d.rectangle((5,42,44,47),fill=C('paper'))
        else: d.rectangle((1,45,48,47),fill=C('frame'))
        draw_icon(d,ic,13,top+9,1,'cover')
        save_item(f'ui_tab_{key}_{state}','tabs',im,f'Вкладка {label}, {"активная" if state=="active" else "неактивная"}',state)

# button close
for state in ('normal','hover'):
    im=blank(30,30);d=ImageDraw.Draw(im)
    stepped(d,1,1,28,28,'card_hover' if state=='hover' else 'card','outline',7,3)
    d.ellipse((5,5,24,24),fill=C('paper' if state=='normal' else 'white'),outline=C('frame'),width=2)
    line(d,[(11,11),(18,18)],'cover',3);line(d,[(18,11),(11,18)],'cover',3)
    save_item(f'ui_close_{state}','controls',im,'Закрыть '+state)

for side in ('left','right'):
    for state in ('normal','disabled'):
        im=blank(20,20);d=ImageDraw.Draw(im)
        stepped(d,0,0,20,20,'card' if state=='normal' else 'gray_light','frame' if state=='normal' else 'gray',4,2)
        draw_icon(d,side,0,0,1,'cover' if state=='normal' else 'gray')
        save_item(f'ui_arrow_{side}_{state}','controls',im,'Листание '+side+' '+state)

# quest cards
for state in ['normal','hover','selected']:
    im=blank(320,56);d=ImageDraw.Draw(im)
    fill={'normal':'card','hover':'card_hover','selected':'white'}[state]
    stepped(d,0,0,320,56,fill,'frame' if state=='selected' else 'card_border',7,3)
    stepped(d,4,4,312,48,fill,'card_border',5,2)
    stepped(d,9,8,40,40,'paper','card_border',5,2)
    save_item(f'ui_quest_card_{state}','quests',im,'Карточка задания '+state,'quest_text_x=58 quest_text_y=11')
# quest statuses
for name in ['new','read','done']:
    im=blank(16,16);d=ImageDraw.Draw(im)
    if name=='new':
        d.ellipse((0,0,15,15),fill=C('red'),outline=C('outline'),width=1)
        d.rectangle((7,3,9,9),fill=C('white')); d.rectangle((7,11,9,12),fill=C('white'))
    if name=='read':
        stepped(d,1,1,14,14,'paper','gray',3,2)
    if name=='done':
        stepped(d,1,1,14,14,'green','cover',3,2)
        line(d,[(3,8),(6,11),(12,4)],'white',2)
    save_item(f'ui_quest_status_{name}','quests',im,'Статус задания '+name)
# group heading no text
im=blank(320,20);d=ImageDraw.Draw(im)
stepped(d,0,0,320,20,'card','frame',5,2)
d.rectangle((11,5,14,14),fill=C('rust'));d.rectangle((306,5,309,14),fill=C('rust'))
save_item('ui_quest_group_heading','quests',im,'Плашка раздела без текста 320x20')
for name in ('star','leaf','check'):
    im=blank(32,32);d=ImageDraw.Draw(im)
    stepped(d,1,1,30,30,'paper','frame',5,2)
    draw_icon(d,name,4,4,1,'cover')
    save_item('ui_quest_type_'+name,'quests',im,'Тип задания '+name)

# inventory cells 48x48: visually distinct, blank slot for engine icon
for name in ('empty','item','hover','selected'):
    im=blank(48,48);d=ImageDraw.Draw(im)
    bg={'empty':'card','item':'card','hover':'card_hover','selected':'white'}[name]
    stepped(d,0,0,48,48,bg,'frame' if name=='selected' else 'card_border',5,3)
    stepped(d,5,5,38,38,'card' if name in ('empty','item') else bg,'card_border',3,1)
    if name=='item':
        d.rectangle((7,7,39,8),fill=C('paper_rim'))
    save_item(f'ui_inventory_slot_{name}','inventory',im,'Слот инвентаря '+name)
im=blank(16,16);d=ImageDraw.Draw(im)
d.ellipse((0,0,15,15),fill=C('cover'),outline=C('outline'),width=1)
save_item('ui_count_badge','inventory',im,'Бейдж количества, без цифр')
im=blank(96,96);d=ImageDraw.Draw(im)
stepped(d,0,0,96,96,'white','frame',7,4);stepped(d,6,6,84,84,'white','card_border',5,3)
save_item('ui_inventory_item_preview_96x96','inventory',im,'Рамка под увеличенную иконку 96x96')
im=blank(200,28);d=ImageDraw.Draw(im)
stepped(d,0,0,200,28,'card','frame',5,3)
save_item('ui_quantity_label_200x28','inventory',im,'Плашка количества, без текста')

# category buttons and icons
for state in ['inactive','active']:
    im=blank(96,26);d=ImageDraw.Draw(im)
    stepped(d,0,0,96,26,'inactive' if state=='inactive' else 'white','frame',5,2)
    if state=='active': d.rectangle((6,21,90,23),fill=C('card_border'))
    save_item('ui_recipe_category_'+state,'recipes',im,'Кнопка категории '+state)
for name in ['bread','plate','cup']:
    im=blank(16,16);d=ImageDraw.Draw(im)
    # draw 24x24 at 3/5 scale by painting on 24x24 then nearest resizing to 16x16
    temp=blank(24,24);td=ImageDraw.Draw(temp);draw_icon(td,name,0,0,1,'cover')
    im=temp.resize((16,16),resample=Image.Resampling.NEAREST)
    save_item('ui_recipe_icon_'+name,'recipes',im,'Иконка категории '+name)
# recipe 46x46
for state in ('empty','normal','selected','locked'):
    im=blank(46,46);d=ImageDraw.Draw(im)
    fill='white' if state=='selected' else ('inactive' if state=='locked' else 'card')
    stepped(d,0,0,46,46,fill,'frame' if state=='selected' else 'card_border',5,3)
    stepped(d,5,5,36,36,fill,'card_border',3,1)
    if state=='locked':
        draw_icon(d,'lock',11,11,1,'cover')
    save_item('ui_recipe_slot_'+state,'recipes',im,'Ячейка рецепта '+state)
im=blank(200,120);d=ImageDraw.Draw(im)
stepped(d,0,0,200,120,'white','frame',7,4);stepped(d,6,6,188,108,'white','card_border',5,3)
save_item('ui_recipe_large_dish_200x120','recipes',im,'Рамка большой иллюстрации блюда')
for state in ['available','missing']:
    im=blank(150,24);d=ImageDraw.Draw(im)
    stepped(d,0,0,150,24,'card','card_border',4,2)
    if state=='available':
        stepped(d,126,4,18,16,'green','cover',3,1)
        line(d,[(130,11),(133,15),(140,7)],'white',2)
    else:
        stepped(d,126,4,18,16,'red','cover',3,1)
        line(d,[(132,8),(139,15)],'white',2)
        line(d,[(139,8),(132,15)],'white',2)
    save_item('ui_recipe_ingredient_'+state,'recipes',im,'Ингредиент: '+state)

# plant list
for state in ('normal','selected'):
    im=blank(320,56);d=ImageDraw.Draw(im)
    fill='white' if state=='selected' else 'card'
    stepped(d,0,0,320,56,fill,'frame' if state=='selected' else 'card_border',7,3)
    stepped(d,8,8,40,40,'paper','card_border',5,2)
    save_item('ui_plant_card_'+state,'plants',im,'Карточка растения '+state,'plant_text_x=58 plant_text_y=11')
# growth stages strip 260x64, 4 cells no plant content
im=blank(260,64);d=ImageDraw.Draw(im)
xs=[1,72,143,214]
for x in xs:
    stepped(d,x,8,46,48,'card','frame',5,3)
    stepped(d,x+5,13,36,38,'paper','card_border',3,1)
for x in (54,125,196):
    draw_icon(d,'right',x-1,18,1,'frame')
save_item('ui_growth_stages_empty_260x64','plants',im,'4 пустые клетки стадий роста со стрелками')
for name in ('clock','drop','sun'):
    temp=blank(24,24);d=ImageDraw.Draw(temp);draw_icon(d,name,0,0,1,'cover')
    im=temp.resize((16,16),Image.Resampling.NEAREST)
    save_item('ui_plant_icon_'+name,'plants',im,'Иконка растений '+name)

# preview book + sample of tab bar; separate preview art only
preview=Image.new('RGBA',(W,H),(255,252,246,255))
preview.alpha_composite(book)
preview.save(OUT/'PREVIEW_BOOK_EMPTY_ON_LIGHT.png')

# sprite atlas with each item padded, no overlap; book top, everything else shelf underneath
ATLAS_W,ATLAS_H=2048,2048
atlas=blank(ATLAS_W,ATLAS_H)
coords=[]
# reserve book on top
atlas.alpha_composite(book,(16,16))
coords.append({'id':'ui_journal_book_base_1672x941','x':16,'y':16,'w':W,'h':H})
# pack other controls under book, max height 2048
x,y,rowh=16,976,0
for item in items[1:]:
    w,h=item['width'],item['height']
    if x+w+16>ATLAS_W:
        x=16;y+=rowh+16;rowh=0
    if y+h+16>ATLAS_H:
        raise RuntimeError(f'Atlas overflow at {item["id"]} {y=} {h=}')
    sprite=Image.open(OUT/item['file']).convert('RGBA')
    atlas.alpha_composite(sprite,(x,y))
    coords.append({'id':item['id'],'x':x,'y':y,'w':w,'h':h})
    x+=w+16;rowh=max(rowh,h)

atlas.save(OUT/'ATLAS_ALL_2048x2048_TRANSPARENT.png')
with open(OUT/'SPRITE_MANIFEST.csv','w',newline='',encoding='utf-8') as f:
    writer=csv.DictWriter(f,fieldnames=['id','category','file','width','height','description','game_field']);writer.writeheader();writer.writerows(items)
with open(OUT/'ATLAS_COORDINATES.csv','w',newline='',encoding='utf-8') as f:
    writer=csv.DictWriter(f,fieldnames=['id','x','y','w','h']);writer.writeheader();writer.writerows(coords)
with open(OUT/'ATLAS_COORDINATES.json','w',encoding='utf-8') as f:
    json.dump(coords,f,ensure_ascii=False,indent=2)
# create labeled professional contact sheet; not engine sprite sheet
thumb=Image.new('RGB',(1800,1320),('#F8F2E9'))
d=ImageDraw.Draw(thumb)
try: font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',22)
except: font=ImageFont.load_default()
d.text((38,22),'PIXEL-GAME / JOURNAL UI — 1672×941 base + independent game sprites',font=font,fill=P['cover'])
# smaller empty book at top left (scale nearest)
bi=book.resize((1120,630),Image.Resampling.NEAREST)
thumb.paste(bi,(22,68),bi)
# icon tab groups top right
startx,starty=1190,80
for i,key in enumerate(['quests','inventory','recipes','plants','adventures','friendship','money']):
    fi=OUT/f'sprites/tabs/ui_tab_{key}_active.png'
    im=Image.open(fi)
    yy=starty+(i//3)*140;xx=startx+(i%3)*150
    disp=im.resize((100,96),Image.Resampling.NEAREST)
    thumb.paste(disp,(xx,yy),disp)
    d.text((xx,yy+98),key,font=font,fill=P['cover'])
# controls sample below, 3x smaller for cards if needed
pos_y=735
for cat,keys in [('Задания',['ui_quest_card_normal','ui_quest_card_selected','ui_quest_status_new','ui_quest_status_done']),
                 ('Инвентарь',['ui_inventory_slot_empty','ui_inventory_slot_selected','ui_count_badge','ui_inventory_item_preview_96x96']),
                 ('Рецепты',['ui_recipe_category_active','ui_recipe_slot_locked','ui_recipe_ingredient_available','ui_recipe_ingredient_missing']),
                 ('Растения',['ui_plant_card_normal','ui_growth_stages_empty_260x64'])]:
    d.text((32,pos_y),cat,font=font,fill=P['cover'])
    xx=230
    for key in keys:
        item=next(t for t in items if t['id']==key)
        im=Image.open(OUT/item['file'])
        if im.width>280:
            im=im.resize((im.width//2,im.height//2),Image.Resampling.NEAREST)
        elif im.width<56:
            im=im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST)
        thumb.paste(im,(xx,pos_y-6),im)
        xx+=im.width+26
    pos_y+=140
thumb.save(OUT/'PREVIEW_CATALOG.png')

readme=f'''# Pixel-Game — JOURNAL UI V1

**Основа:** приложенный утверждённый референс книги `пиксельное_меню_книга_для_уютной_игры.png` (1672×941 px).

## Файлы
- `sprites/book/ui_journal_book_base_1672x941.png` — **основа без вкладок, карточек и текста** в неизменном размере 1672×941.
- `sprites/tabs/` — семь разделов, две версии каждого (`active`, `inactive`), размер 50×48.
- `sprites/controls/` — кнопка ×, стрелки ‹ › в двух состояниях.
- `sprites/quests/`, `sprites/inventory/`, `sprites/recipes/`, `sprites/plants/` — элементы перечисленных разделов.
- `ATLAS_ALL_2048x2048_TRANSPARENT.png` — все ресурсы на одном прозрачном листе, отступы 16 px.
- `ATLAS_COORDINATES.csv` — координаты на атласе; `SPRITE_MANIFEST.csv` — размеры и назначение.
- `PREVIEW_CATALOG.png` — отдельная демонстрация (не импортировать в GameMaker).

## Важные ограничения
- **Все PNG в RGBA на прозрачном фоне.** Элементы отрисованы целочисленными координатами, без градиентов/размытия/сглаживания.
- Размеры точные: книга 1672×941; вкладки 50×48; карточки 320×56; слоты 48×48 и т.д.
- Изображение книги **перерисовано по референсу**, чтобы убрать содержимое и вкладки, сохранив общую компоновку и габариты. Это НЕ пиксель-в-пиксель исходное изображение; сверить визуально перед заменой!
- Символы и декоративные элементы внутри вкладок — графика, но **заголовки, подписи, описания, числа, названия заданий, названия предметов и рецептов должна рисовать игра**.
- `ui_quest_card_...` и `ui_plant_card_...` НЕ содержат псевдотекста. Места под текст пустые.
- В описании раздела «Приключения» входное ТЗ обрывается; для разделов «Приключения», «Дружба», «Деньги» сейчас подготовлены **вкладки**, не внутренние экраны.
- Параметры происхождения (origins) для вкладок рекомендуется держать top-left, позиционирование inactive/active с одинаковым origin, активация уже отражена в высоте на 4px внутри PNG.
- В GameMaker отключить texture filtering / использовать nearest-neighbor, integer масштаб UI.

## Палитра
{chr(10).join(f'- {key}: `{val}`' for key,val in P.items() if key in ['paper','card','card_border','frame','white','cover','inactive'])}

## Что делать Claude Code
1. Сначала сделать отдельный тестовый room/preview UI, **не заменяя сразу действующий дневник**.
2. Загрузить книгу и две серии вкладок; расположить вкладки над книгой по центру, отдельными PNG поверх основы.
3. Реализовать hitbox вкладок и кнопки закрытия. После проверки — добавить соответствующие панели.
4. Рисовать текст, количество, предметы и рецепты программно, отдельно от PNG.
5. Проверить наложение над 1672×941, чтение и клики. При необходимости масштабировать *всю композицию* одинаковым integer/nearest без изменения соотношений и отдельных спрайтов.
6. Показать скриншот на утверждение, не мерджить в main без согласования.
'''
(OUT/'README_FOR_CLAUDE_RU.md').write_text(readme,encoding='utf-8')

zip_file=Path('/mnt/data/PixelGame_Journal_UI_Approved_Reference_V1.zip')
with zipfile.ZipFile(zip_file,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in sorted(OUT.rglob('*')):
        if file.is_file(): z.write(file,arcname=file.relative_to(OUT.parent).as_posix())
print('OUTPUT',OUT,zip_file)
print('SPRITES',len(items),'final atlas last',x,y,'row height',rowh)
print('SIZE ZIP',zip_file.stat().st_size)
print('TOP categories',{cat:sum(it['category']==cat for it in items) for cat in set(it['category'] for it in items)})
