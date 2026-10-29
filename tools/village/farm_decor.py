# Декор rm_farm: добавляет слой farm_decor в текущую комнату (существующие экземпляры не трогает).
import sys,json
P=sys.argv[1]
PL=[ # объект, x, y   (village/village2/village3 — низ по центру; цветы/трава 32x32 — левый верхний угол)
 # у сарая — хозяйственная группа
 ('obj_village_crates',266,272),('obj_village_crate',234,282),
 # у пекарни — у левой стены
 ('obj_village_barrel',815,272),('obj_village_crate',842,274),
 ('obj_village_flower_daisy',1156,256),('obj_village_flower_yellow',1170,262),
 # у дома бабушки
 ('obj_village_lamp',528,284),                                   # фонарь у дорожки к дому
 ('obj_village_flower_daisy',390,242),('obj_village_flower_yellow',406,248),
 ('obj_village_hedge',700,264),('obj_village_flower_daisy',672,246),
 # огород — только снаружи забора
 ('obj_village3_hedge_small',36,470),('obj_village_hedge',120,682),
 ('obj_village_flower_lupine',30,548),('obj_village_flower_daisy',176,640),('obj_village_flower_yellow',300,642),
 ('obj_village_grass',250,664),('obj_village_grass',560,644),('obj_village_grass',770,628),('obj_village_grass',950,640),
]
f=f'{P}/rooms/rm_farm/rm_farm.yy'; r=open(f).read()
assert '"%Name":"farm_decor"' not in r
rows=[];names=[]
for n,(o,x,y) in enumerate(PL):
    nm=f'inst_FARMDECOR_{n:02d}'; assert nm not in r; names.append(nm)
    rows.append(f'        {{"$GMRInstance":"v4","%Name":"{nm}","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"{nm}","objectId":{{"name":"{o}","path":"objects/{o}/{o}.yy",}},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":{float(x)},"y":{float(y)},}},')
layer=('    {"$GMRInstanceLayer":"","%Name":"farm_decor","depth":950,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[\n'
       +'\n'.join(rows)+'\n      ],"layers":[],"name":"farm_decor","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},\n')
a='    {"$GMRInstanceLayer":"","%Name":"Max"'; assert a in r; r=r.replace(a,layer+a,1)
co=r.index('"instanceCreationOrder":['); e=r.index('\n  ],',co)
r=r[:e]+''.join(f'\n    {{"name":"{n}","path":"rooms/rm_farm/rm_farm.yy",}},' for n in names)+r[e:]
open(f,'w').write(r); print('добавлено',len(PL))
