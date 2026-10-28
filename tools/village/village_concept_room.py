# Сборка rm_village по концепту. Всегда стартует с резервной копии комнаты (до этой задачи) — можно перезапускать.
import sys,os,re,json,hashlib
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import gmtiles
P,BACKUP,V2,LAYOUT=sys.argv[1:5]
s=open(BACKUP).read()
L=json.load(open(LAYOUT))
inst_re=r'\n        \{"\$GMRInstance":"v4","%Name":"(\w+)".*?"y":-?[\d.]+,\},'
# 1. удалить экземпляры (старый декор и невидимые «пустышки» без спрайта)
for m in list(re.finditer(inst_re,s)):
    pass
def drop(name):
    global s
    s,n=re.subn(r'\n        \{"\$GMRInstance":"v4","%Name":"'+name+r'".*?"y":-?[\d.]+,\},','',s); assert n==1,name
    s,n=re.subn(r'\n    \{"name":"'+name+r'","path":"rooms/rm_village/rm_village.yy",\},','',s); assert n==1,name
for n in L['drop']: drop(n)
# 2. сдвинуть сохраняемые экземпляры
for n,(x,y) in L['move'].items():
    m=re.search(r'\{"\$GMRInstance":"v4","%Name":"'+n+r'".*?"x":(-?[\d.]+),"y":(-?[\d.]+),\}',s); assert m,n
    seg=m.group(0); seg2=re.sub(r'"x":-?[\d.]+,"y":-?[\d.]+,\}$',f'"x":{float(x)},"y":{float(y)},}}',seg)
    s=s.replace(seg,seg2)
# 3. новый слой декора
def iname(i,o,x,y): return 'inst_VC'+hashlib.md5(f'{i}{o}{x}{y}'.encode()).hexdigest()[:6].upper()
rows=[];names=[]
for i,(o,x,y) in enumerate(L['place']):
    nm=iname(i,o,x,y); names.append(nm)
    rows.append(f'        {{"$GMRInstance":"v4","%Name":"{nm}","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"{nm}","objectId":{{"name":"{o}","path":"objects/{o}/{o}.yy",}},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":{float(x)},"y":{float(y)},}},')
assert len(set(names))==len(names)
layer=('    {"$GMRInstanceLayer":"","%Name":"village_concept","depth":220,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[\n'
       +'\n'.join(rows)+'\n      ],"layers":[],"name":"village_concept","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},\n')
a='    {"$GMRInstanceLayer":"","%Name":"layer_trees"'; assert a in s; s=s.replace(a,layer+a,1)
co=s.index('"instanceCreationOrder":['); end=s.index('\n  ],',co)
s=s[:end]+''.join(f'\n    {{"name":"{n}","path":"rooms/rm_village/rm_village.yy",}},' for n in names)+s[end:]
# 4. земля: новый тайловый слой, ground_v1 скрыть (данные сохраняются)
g=json.load(open(f'{V2}/ground.json'))['grid']
flat=[v for row in g for v in row]
data=gmtiles.encode(flat)
tl=('    {"$GMRTileLayer":"","%Name":"ground_concept","depth":640,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"ground_concept","properties":[],"resourceType":"GMRTileLayer","resourceVersion":"2.0","tiles":{"SerialiseHeight":23,"SerialiseWidth":50,"TileCompressedData":['
    +','.join(str(v) for v in data)+',],"TileDataFormat":1,},"tilesetId":{"name":"tls_village_plaza_curb_v3","path":"tilesets/tls_village_plaza_curb_v3/tls_village_plaza_curb_v3.yy",},"userdefinedDepth":false,"visible":true,"x":0,"y":0,},\n')
a='    {"$GMRTileLayer":"","%Name":"ground_v1"'; assert a in s; s=s.replace(a,tl+a,1)
i=s.index(a); j=s.index('"visible":true,"x":0,"y":0,}',i); k=s.index('"tilesetId"',i)
assert j>k; s=s[:j]+'"visible":false,"x":0,"y":0,}'+s[j+len('"visible":true,"x":0,"y":0,}'):]
open(f'{P}/rooms/rm_village/rm_village.yy','w').write(s)
print('удалено',len(L['drop']),'сдвинуто',len(L['move']),'добавлено',len(names))
