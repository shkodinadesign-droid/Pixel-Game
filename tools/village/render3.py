# Рендер комнаты: спрайты с origin/масштабом, сортировка по низу (как depth=-bbox_bottom),
# плоды поверх своего дерева, иконки «якорей» фруктов (их Draw), невидимые блокеры пропущены.
import sys,os,re
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png, yy, gmtiles
P,room,OUT,SC=sys.argv[1],sys.argv[2],sys.argv[3],float(sys.argv[4])
crop=[int(v) for v in sys.argv[5].split(',')] if len(sys.argv)>5 else None
d=yy.load(f'{P}/rooms/{room}/{room}.yy'); W,H=d['roomSettings']['Width'],d['roomSettings']['Height']
cache={}
def objspr(o):
    t=yy.load(f'{P}/objects/{o}/{o}.yy'); return t['spriteId']['name'] if t.get('spriteId') else None, t.get('visible',True)
def objinfo(o):
    t=yy.load(f'{P}/objects/{o}/{o}.yy'); m=t.get('spriteMaskId'); par=t.get('parentObjectId')
    return (m['name'] if m else None),(par['name'] if par else None)
def is_solid(o):
    while o:
        if o=='obj_solid': return True
        o=objinfo(o)[1]
    return False
BB={}
def sprbb(s):
    if s not in BB:
        t=yy.load(f'{P}/sprites/{s}/{s}.yy'); q=t['sequence']; BB[s]=(t['bbox_left'],t['bbox_top'],t['bbox_right'],t['bbox_bottom'],q['xorigin'],q['yorigin'])
    return BB[s]
def spr(s):
    if s not in cache:
        t=yy.load(f'{P}/sprites/{s}/{s}.yy'); f=t['frames'][0]['name']
        w,h,p=png.read(f'{P}/sprites/{s}/{f}.png'); seq=t['sequence']
        cache[s]=(w,h,p,seq['xorigin'],seq['yorigin'],t['bbox_bottom'])
    return cache[s]
SKIP={'obj_forest_blocker','obj_camera','obj_ui_inventory','obj_ui_hp','obj_ui_coins_hud','obj_day_controller','obj_game_controller','obj_spawn_controller'}
items=[]
def walk(ls):
    for L in ls:
        if L.get('visible') is False: continue
        for i in L.get('instances') or []:
            o=i['objectId']['name']
            if o in SKIP: continue
            s,vis=objspr(o)
            sx,sy=i['scaleX'],i['scaleY']
            if o=='obj_pear_on_tree': sx=sy=27/24
            if s and vis:
                m=objinfo(o)[0] or s
                l_,t_,r_,b_,mox,moy=sprbb(m)
                bottom=i['y']+(b_-moy)*sy
                items.append([bottom,0,o,s,i['x'],i['y'],sx,sy])
            if False:   # якоря больше не рисуют иконки
                ic='spr_apple_icon' if o=='obj_apple_tree_fruit' else 'spr_pear_icon'
                for dx,dy in((-20,-80),(8,-100),(32,-78)): items.append([i['y'],0,o+'_icon',ic,i['x']+dx,i['y']+dy,1,1])
        walk(L.get('layers',[]))
walk(d['layers'])
def walk_ivan(ls):
    for L in ls:
        for i in L.get('instances') or []:
            if i['objectId']['name']=='obj_ivan_npc': items.append([i['y'],0,'IVAN',None,i['x'],i['y'],1,1])
        walk_ivan(L.get('layers',[]))
walk_ivan(d['layers'])
if os.environ.get('MAX'):
    mx,my=[int(v) for v in os.environ['MAX'].split(',')]; items.append([my+47,0,'MAX','spr_max_idle_down',mx,my,1,1])
trees=[it for it in items if it[2] in('obj_tree_apple','obj_tree_pear')]
for it in items:
    if it[2] in('obj_apple_on_tree','obj_pear_on_tree'):
        for t in trees:
            w,h,p,ox,oy,bb=spr(t[3]); l,tp=t[4]-ox,t[5]-oy
            if l<=it[4]<=l+w and tp<=it[5]<=tp+h: it[0]=t[0]; it[1]=1
items.sort(key=lambda it:(it[0],it[1]))
x0,y0,x1,y1=crop if crop else (0,0,W,H)
cw,ch=int((x1-x0)*SC),int((y1-y0)*SC)
img=[[tuple(int(v) for v in os.environ.get('BG','88,128,64').split(','))+(255,)]*cw for _ in range(ch)]; img=[list(r) for r in img]
SH={'obj_tree_pine':'spr_tree_shadow_small','obj_tree_pear':'spr_tree_shadow_small','obj_tree_maple':'spr_tree_shadow_medium','obj_tree_apple':'spr_tree_shadow_medium','obj_tree_oak':'spr_tree_shadow_large'}
def blit(s,x,y,sx,sy):
    w,h,p,ox,oy,bb=spr(s); lx,ty=x-ox*sx,y-oy*sy
    for cy in range(max(0,int((ty-y0)*SC)),min(ch,int((ty+h*sy-y0)*SC)+1)):
        py=int(((cy/SC+y0)-ty)/sy)
        if not 0<=py<h: continue
        for cx in range(max(0,int((lx-x0)*SC)),min(cw,int((lx+w*sx-x0)*SC)+1)):
            px=int(((cx/SC+x0)-lx)/sx)
            if 0<=px<w:
                r,g,b,a=p[py][px]
                if a==255 or (a>100 and not s.startswith('spr_tree_shadow')): img[cy][cx]=(r,g,b,255)
                elif a>0: o=img[cy][cx]; img[cy][cx]=tuple(round((v*a+ov*(255-a))/255) for v,ov in zip((r,g,b),o[:3]))+(255,)
def draw_tiles():
    tl=[]
    def w2(ls):
        for L in ls:
            if L['resourceType']=='GMRTileLayer' and L.get('visible',True) and L['%Name'] not in os.environ.get('HIDE','').split(','): tl.append(L)
            if L['resourceType']=='GMRBackgroundLayer' and not L.get('spriteId'):
                c=L['colour']; col=(c&255,(c>>8)&255,(c>>16)&255,255)
                for yy_ in range(ch):
                    for xx in range(cw): img[yy_][xx]=col
            w2(L.get('layers',[]))
    w2(d['layers'])
    for L in sorted(tl,key=lambda L:-L['depth']):
        ts=yy.load(f"{P}/tilesets/{L['tilesetId']['name']}/{L['tilesetId']['name']}.yy")
        s=ts['spriteId']['name']; w,h,p,_,_,_=spr(s); tw,th=ts['tileWidth'],ts['tileHeight']
        ox,oy,hs,vs=ts['tilexoff'],ts['tileyoff'],ts['tilehsep'],ts['tilevsep']; cols=(w-ox+hs)//(tw+hs)
        td=L['tiles']; TW,TH=td['SerialiseWidth'],td['SerialiseHeight']; v=gmtiles.decode(td['TileCompressedData'],TW*TH)
        for ty_ in range(TH):
            for tx in range(TW):
                val=v[ty_*TW+tx]
                if val==gmtiles.EMPTY: continue
                k=val&0x7FFFF
                if k==0: continue
                mir=(val>>28)&1; flp=(val>>29)&1
                sx0=ox+(k%cols)*(tw+hs); sy0=oy+(k//cols)*(th+vs)
                for py in range(th):
                    for px in range(tw):
                        X=tx*tw+px; Y=ty_*th+py
                        cx,cy=int((X-x0)*SC),int((Y-y0)*SC)
                        if not(0<=cx<cw and 0<=cy<ch): continue
                        qx=tw-1-px if mir else px; qy=th-1-py if flp else py
                        r,g,b,a=p[sy0+qy][sx0+qx]
                        if a>100: img[cy][cx]=(r,g,b,255)
if os.environ.get('TILES'):
    draw_tiles() if SC==1 else None
for _,_,o,s,x,y,sx,sy in items:
    if o=='IVAN':
        for yy_ in range(int(y-48),int(y)+1):
            for xx in range(int(x-16),int(x+16)+1):
                if 0<=yy_-y0<ch and 0<=xx-x0<cw: img[yy_-y0][xx-x0]=(180,60,60,255)
        for yy_ in range(int(y-68),int(y-47)):
            for xx in range(int(x-10),int(x+11)):
                if (xx-x)**2+(yy_-(y-58))**2<=100 and 0<=yy_-y0<ch and 0<=xx-x0<cw: img[yy_-y0][xx-x0]=(220,180,140,255)
        continue
    if o in SH: blit(SH[o],x,y,1,1)
    blit(s,x,y,sx,sy); continue
    w,h,p,ox,oy,bb=spr(s); lx,ty=x-ox*sx,y-oy*sy
    for cy in range(max(0,int((ty-y0)*SC)),min(ch,int((ty+h*sy-y0)*SC)+1)):
        py=int(((cy/SC+y0)-ty)/sy)
        if not 0<=py<h: continue
        for cx in range(max(0,int((lx-x0)*SC)),min(cw,int((lx+w*sx-x0)*SC)+1)):
            px=int(((cx/SC+x0)-lx)/sx)
            if 0<=px<w and p[py][px][3]>100: img[cy][cx]=p[py][px][:3]+(255,)
if os.environ.get('MASKS'):
    for _,_,o,s,x,y,sx,sy in items:
        if o in('IVAN','MAX') or not is_solid(o): continue
        m=objinfo(o)[0] or s
        t=yy.load(f'{P}/sprites/{m}/{m}.yy'); q=t['sequence']; ox,oy=q['xorigin'],q['yorigin']
        X0,X1=int((x+(t['bbox_left']-ox)*sx-x0)*SC),int((x+(t['bbox_right']+1-ox)*sx-x0)*SC)
        Y0,Y1=int((y+(t['bbox_top']-oy)*sy-y0)*SC),int((y+(t['bbox_bottom']+1-oy)*sy-y0)*SC)
        for cx in range(max(0,X0),min(cw,X1+1)):
            for cy in(Y0,Y1):
                if 0<=cy<ch: img[cy][cx]=(255,0,0,255)
        for cy in range(max(0,Y0),min(ch,Y1+1)):
            for cx in(X0,X1):
                if 0<=cx<cw: img[cy][cx]=(255,0,0,255)
png.write(OUT,cw,ch,img); print(room,len(items))
