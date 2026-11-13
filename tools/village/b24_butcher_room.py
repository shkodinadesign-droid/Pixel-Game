# Мясная лавка: комната rm_butcher_shop (копия пола и стен rm_joshua_shop), мебель из
# art_incoming/butcher_v1/butcher_sheet_v1.png (масштаб 0.3, как мебель магазина Джошуа), вход в деревне у двери лавки,
# выход в комнате, продавец Джо за прилавком. Мебель без коллизий — как в магазине Джошуа.
import sys,os,re,uuid,shutil
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
from b06_nature_convert import down,kmeans,crop
SRC,P=sys.argv[1],sys.argv[2]; S=0.3
w,h,p=png.read(SRC); img=[[c[:3]+(255,) if c[3]>=200 else (0,0,0,0) for c in r] for r in p]
ITEMS={'counter':(29,28,457,422),'meat_case':(504,95,1045,432),'dairy_case':(1078,95,1520,432),'banner':(70,456,232,680),
       'meat_rack':(281,464,516,677),'cheese_table':(571,499,782,681),'milk_can':(845,501,984,680),'egg_crate':(1056,545,1240,676),
       'cream_barrel':(1312,511,1446,678),'spice_cabinet':(89,701,398,995),'shelf_herbs':(468,753,678,975),'shelf_garlic':(754,754,927,970),
       'shelf_pepper':(1013,755,1184,966),'shelf_lavender':(1270,743,1448,971)}
new=[]
for k,(x0,y0,x1,y1) in ITEMS.items():
    im=crop([r[x0:x1+1] for r in img[y0:y1+1]])
    s=down(im,len(im[0]),len(im),S); s=crop([[c[:3]+(255,) if c[3]>=128 else (0,0,0,0) for c in r] for r in s])
    cent=kmeans([c[:3] for r in s for c in r if c[3]],24); near=lambda px:min(cent,key=lambda c:sum((c[i]-px[i])**2 for i in range(3)))
    s=[[near(c)+(255,) if c[3] else c for c in r] for r in s]
    sn,on=f'spr_butcher_{k}',f'obj_butcher_{k}'
    if not os.path.exists(f'{P}/sprites/{sn}'):
        gm_res.sprite(P,sn,s,(0,0),(0,0,len(s[0])-1,len(s)-1),folder=('Room_hall_furniture','folders/Sprites/Room_hall_furniture.yy')); new.append(sn)
    if not os.path.exists(f'{P}/objects/{on}'): gm_res.obj(P,on,sn,None,solid=False); new.append(on)
    print(sn,len(s[0]),'x',len(s))
# вход / выход — копии объектов магазина Джошуа
def clone(src,dst,repl):
    if os.path.exists(f'{P}/objects/{dst}'): return
    shutil.copytree(f'{P}/objects/{src}',f'{P}/objects/{dst}')
    os.rename(f'{P}/objects/{dst}/{src}.yy',f'{P}/objects/{dst}/{dst}.yy')
    for f in os.listdir(f'{P}/objects/{dst}'):
        fp=f'{P}/objects/{dst}/{f}'; t=open(fp).read().replace(src,dst)
        for a,b in repl: t=t.replace(a,b)
        open(fp,'w').write(t)
    new.append(dst)
clone('obj_joshua_shop_entrance','obj_butcher_entrance',[('room_goto(rm_joshua_shop);','room_goto(rm_butcher_shop);'),
      ('if (point_distance(x, y, foot_cx, foot_y) < 160) {','if (point_distance(x, y, foot_cx, foot_y) < 64\n    // рядом с Иваном у лавки клавиша E — разговор с ним (задание с морковью), а не вход\n    && !(instance_exists(obj_ivan_npc) && point_distance(obj_ivan_npc.x, obj_ivan_npc.y, p.x, p.y) < 80)) {'),
      ('if (point_distance(x, y, _foot_cx, _foot_y) < 96) {','if (point_distance(x, y, _foot_cx, _foot_y) < 64) {')])
clone('obj_joshua_shop_exit','obj_butcher_exit',[])
# продавец Джо — пока со спрайтом-заглушкой spr_Miley (как у Джошуа), смотрит вниз
if not os.path.exists(f'{P}/objects/obj_joe_npc'):
    gm_res.obj(P,'obj_joe_npc','spr_Miley',None,events={(3,0,'Step_0.gml'):'// Продавец мясной лавки Джо (стоит за прилавком). Спрайт — временная заглушка.\nimage_speed = 0;\n'},solid=False); new.append('obj_joe_npc')
# комната — копия rm_joshua_shop без экземпляров
R='rm_butcher_shop'; rd=f'{P}/rooms/{R}'
if not os.path.exists(rd):
    shutil.copytree(f'{P}/rooms/rm_joshua_shop',rd); os.rename(f'{rd}/rm_joshua_shop.yy',f'{rd}/{R}.yy')
    t=open(f'{rd}/{R}.yy').read().replace('rm_joshua_shop',R)
    t=re.sub(r'\n        \{"\$GMRInstance":.*?\},(?=\n)','',t)                       # все экземпляры
    t=re.sub(r'"instanceCreationOrder":\[.*?\],','"instanceCreationOrder":[],',t,flags=re.S)
    open(f'{rd}/{R}.yy','w').write(t)
    cc=open(f'{rd}/RoomCreationCode.gml').read().replace('rm_joshua_shop',R); open(f'{rd}/RoomCreationCode.gml','w').write(cc)
    TPL='{"$GMRInstance":"v4","%Name":"NAME","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"NAME","objectId":{"name":"OBJ","path":"objects/OBJ/OBJ.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":@X@,"y":@Y@,},'
    # раскладка по образу магазина Джошуа: прилавок слева с продавцом, у стены шкаф и полочки, две витрины в ряд,
    # под ними сыр/бидон/яйца/бочонок, у левой стены — стойка с вывеской и рама с колбасами, выход внизу слева
    LAYOUT=[('furniture','obj_butcher_counter',0,300),('furniture','obj_window',32,192),('furniture','obj_butcher_spice_cabinet',176,200),
            ('furniture','obj_butcher_shelf_herbs',300,186),('furniture','obj_butcher_shelf_garlic',392,186),('furniture','obj_butcher_shelf_pepper',540,186),('furniture','obj_butcher_shelf_lavender',624,186),
            ('furniture','obj_butcher_meat_case',270,352),('furniture','obj_butcher_dairy_case',500,352),
            ('furniture','obj_butcher_cheese_table',290,520),('furniture','obj_butcher_milk_can',380,524),('furniture','obj_butcher_egg_crate',512,540),('furniture','obj_butcher_cream_barrel',600,526),
            ('furniture','obj_butcher_banner',8,512),('furniture','obj_butcher_meat_rack',0,600),
            ('jo','obj_joe_npc',40,322),('exi','obj_butcher_exit',64,704)]
    t=open(f'{rd}/{R}.yy').read(); order=[]
    for i,(lay,o,x,y) in enumerate(LAYOUT):
        nm=f'inst_BUTCHER_{i:02d}'; line=TPL.replace('NAME',nm).replace('OBJ',o).replace("@X@",f"{float(x)}").replace("@Y@",f"{float(y)}")
        m=re.search(r'\{"\$GMRInstanceLayer":"","%Name":"'+lay+r'",[^\n]*"instances":\[',t); assert m,lay
        t=t[:m.end()]+'\n        '+line+t[m.end():]; order.append(nm)
    t=t.replace('"instanceCreationOrder":[],','"instanceCreationOrder":[\n'+''.join(f'    {{"name":"{n}","path":"rooms/{R}/{R}.yy",}},\n' for n in order)+'  ],')
    open(f'{rd}/{R}.yy','w').write(t)
    # yyp: ресурс комнаты и порядок комнат
    yp=f'{P}/max_farm_demo.yyp'; s=open(yp).read()
    s=s.replace('    {"id":{"name":"rm_joshua_shop","path":"rooms/rm_joshua_shop/rm_joshua_shop.yy",},},','    {"id":{"name":"rm_joshua_shop","path":"rooms/rm_joshua_shop/rm_joshua_shop.yy",},},\n    {"id":{"name":"'+R+'","path":"rooms/'+R+'/'+R+'.yy",},},',1)
    s=s.replace('    {"roomId":{"name":"rm_joshua_shop","path":"rooms/rm_joshua_shop/rm_joshua_shop.yy",},},','    {"roomId":{"name":"rm_joshua_shop","path":"rooms/rm_joshua_shop/rm_joshua_shop.yy",},},\n    {"roomId":{"name":"'+R+'","path":"rooms/'+R+'/'+R+'.yy",},},',1)
    open(yp,'w').write(s)
    # вход в деревне — у двери лавки (дверь справа от витрины, низ двери ~y 270)
    vp=f'{P}/rooms/rm_village/rm_village.yy'; v=open(vp).read()
    if 'inst_BUTCHER_ENTRANCE' not in v:
        line=TPL.replace('NAME','inst_BUTCHER_ENTRANCE').replace('OBJ','obj_butcher_entrance').replace("@X@","1386.0").replace("@Y@","288.0")
        m=re.search(r'\{"\$GMRInstanceLayer":"","%Name":"enter",[^\n]*"instances":\[',v); assert m
        v=v[:m.end()]+'\n        '+line+v[m.end():]
        v=v.replace('"instanceCreationOrder":[','"instanceCreationOrder":[\n    {"name":"inst_BUTCHER_ENTRANCE","path":"rooms/rm_village/rm_village.yy",},',1)
        open(vp,'w').write(v)
gm_res.add_to_yyp(P,[n for n in new if n.startswith(('spr_','obj_'))]); print('новых ресурсов',len(new))
