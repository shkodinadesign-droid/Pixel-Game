# Раскладка rm_village по концепту. Точка у деревьев и нового декора — основание (низ по центру);
# у заборов, скамейки, кустов, камня, цветов, травы — левый верхний угол (как у их спрайтов).
import json,sys
OUT=sys.argv[1]
DROP=['inst_55D93BF2','inst_3B33AEC2','inst_3A67705D','inst_48E11718','inst_673D84E0','inst_665DF7C0','inst_6C29E3A',
 'inst_42CC0AAF','inst_1248C7DF','inst_7E585721','inst_6062D41E','inst_3E44911C','inst_1040FD80','inst_39E082A2',
 'inst_5524C43B','inst_4675662D',
 'inst_E65A1E90','inst_0636B9B0','inst_6E260C75','inst_2F9B34BA','inst_1B2C7F79','inst_3575CF3C','inst_C9963E02','inst_16D90AB7',
 'inst_45619DDC','inst_5CED0E80','inst_5AC4FA1','inst_65015CA6','inst_1DF23A85','inst_456D3C0E','inst_61597B8B',
 'inst_31554428','inst_266BDD5B','inst_539FE7C2','inst_3699402A','inst_223523B8','inst_793872A5','inst_2026CACA',
 'inst_1C64AFA0','inst_4F06F5C0','inst_24C6022F','inst_58AB53F7','inst_607A7E79','inst_5C571D34','inst_3725637A',
 'inst_6D80ECBE','inst_ECC0012','inst_4BEF6C47','inst_4E5E320B','inst_7E2EC2BF','inst_47A5C8C6','inst_7BCC6493',
 'inst_787C9C9','inst_70D83BA2']
MOVE={'inst_JOSHUA_SHOP':(832,128),'inst_94745A7':(960,320),   # магазин и вход (то же смещение 128,192)
      'inst_IVAN_NPC':(1432,334),'inst_7EA76492':(1460,316),
      'inst_MEAT_SHOP':(1360,286)}   # лавка Ивана над правой дорогой, дверью к дороге
pl=[]
def add(o,x,y): pl.append((o,int(x),int(y)))
OAK,MAP,PINE,APP,PEAR='obj_tree_oak','obj_tree_maple','obj_tree_pine','obj_tree_apple','obj_tree_pear'
B1,B2,HG='obj_village_bush','obj_village_bush_2','obj_village_hedge'
DA,LU,YE,GR='obj_village_flower_daisy','obj_village_flower_lupine','obj_village_flower_yellow','obj_village_grass'
# ---------- площадь и магазин ----------
add('obj_village_lamp',686,282)          # 1: слева от магазина у дорожки
add('obj_village_lamp',876,414)          # 2: нижняя центральная часть площади
add('obj_village_lamp',1133,301)         # 3: справа от магазина
add('obj_village_lamp',1173,472)         # 4: справа у скамейки
add('obj_village_notice_board',757,267)  # информационный стенд слева от магазина
add('obj_village_planter_square',790,299)
add('obj_village_barrel',817,303)        # бочка слева
add('obj_village_planter_square',846,352)   # ящики с цветами у фасада
add('obj_village_planter_square',1045,352)
add('obj_village_crate',1070,340)        # ящики справа
add('obj_village_crates',1080,265)
add('obj_village_planter_long',1082,297)
add('obj_village_sign_aframe',1109,304)  # отдельно стоящая вывеска справа
add('obj_village_hedge_v',1168,350)      # узкая вертикальная изгородь у правого края мощения
add('obj_village_bench',1070,418)
add('obj_village_flower_bed',1100,452)   # густая зелень за скамейкой
add(HG,1176,448)
# кусты за стендом и магазином (слева)
add(B1,700,198); add(B2,752,186); add(HG,812,246)
# кусты за ящиками (справа)
add(B2,1052,196); add(B1,1098,206); add(B1,1150,150)
# большая клумба слева на площади: дерево + кусты + цветы
add(MAP,748,381)
add(B1,770,360); add(HG,788,446)
add(LU,712,352); add(DA,722,388); add(YE,792,366); add(DA,800,410); add(DA,748,412)
add(DA,1046,404); add(DA,1150,420); add(DA,1150,96)
# ---------- деревья: верхнее обрамление ----------
add(OAK,568,205); add(MAP,437,172); add(B2,494,214); add(PINE,661,218); add(MAP,352,276)
add(OAK,363,110); add(MAP,625,80); add(OAK,740,152); add(MAP,836,142)
add(OAK,1076,158); add(PINE,1136,196); add(APP,1229,276)
add(MAP,960,70); # правая верхняя часть (вне кадра концепта)
add(OAK,1530,150); add(MAP,1590,250)
add(MAP,1450,60)
# забор справа вверху
for x in (1166,1230,1294,1358): add('obj_village_fence',x,30)
add('obj_village_fence_post',1422,30)
# левая часть (вне кадра концепта)
add(PINE,40,110); add(MAP,170,64); add(OAK,240,250)
# ---------- левая зелёная зона: заборы вдоль дороги, изгородь ----------
for x in range(0,576,64): add('obj_village_fence',x,327); add('obj_village_fence',x,477)
add('obj_village_fence_post',576,327); add('obj_village_fence_post',576,477)
for i,x in enumerate((2,58,120,176,234,290,344,398,452)): add(B1 if i%2 else B2,x,426 if i%3 else 428)
add(HG,555,478)
add('obj_village_rock',584,200)
# цветы и трава слева (по концепту)
for o,x,y in [(DA,350,160),(DA,380,156),(LU,398,162),(LU,378,100),(YE,462,205),(LU,488,266),(LU,356,268),
              (DA,614,276),(DA,640,222),(GR,444,142),(GR,474,158),(GR,548,226),(GR,586,170),(GR,541,278),(GR,372,296),
              (DA,520,438),(DA,600,446),(YE,500,452),
              (DA,30,180),(LU,140,170),(GR,200,190),(YE,260,120),(GR,90,40),(DA,200,286),(GR,20,260),(LU,300,280)]:
    add(o,x,y)
# ---------- нижняя часть ----------
add(PINE,612,566)
add(B2,356,532); add(MAP,430,650); add(OAK,560,700); add(B1,250,540); add(PINE,40,620)
add(B1,700,556); add(MAP,780,668); add(OAK,920,700); add(B2,980,560); add(PINE,1190,650)
add(MAP,1260,690); add(OAK,1390,720); add(PINE,1520,680); add(B1,1560,560)
for o,x,y in [(LU,650,560),(DA,676,568),(DA,560,548),(GR,700,520),(GR,1040,548),(DA,1240,552),(GR,1440,548)]: add(o,x,y)
# ---------- правая часть: зелень за скамейкой, у выхода в лес ----------
add(B1,1186,360); add(PEAR,1300,440); add(B2,1360,392); add(HG,1240,470)
for o,x,y in [(DA,1200,432),(DA,1230,400),(YE,1330,456),(GR,1390,456),(LU,1250,370)]: add(o,x,y)
add(MAP,1584,335); add(B2,1536,288)
add(B1,1540,456); add(DA,1520,520)
json.dump({'drop':DROP,'move':MOVE,'place':pl},open(OUT,'w'),indent=0)
print(len(pl),'объектов')
