# Голубая версия окна для холодильника: spr_fridge_bg (из spr_storage_bg) и ячейки/бейдж/крестик spr_ui_fridge_*
# (из spr_ui_inventory_slot_*, spr_ui_count_badge, spr_ui_close_*). Перекраска: оттенок каждого пикселя -> голубой
# (202°), насыщенность x0.75, яркость без изменений — светлая бумага становится бледно-голубой, коричневые контуры — тёмно-синими.
import sys,os,colorsys
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__))); import png,gm_res
P=sys.argv[1]
def load(n):
    d=f'{P}/sprites/{n}'; f=[x for x in os.listdir(d) if x.endswith('.png')][0]; w,h,p=png.read(f'{d}/{f}'); return [list(r) for r in p]
def blue(img):
    out=[]
    for r in img:
        row=[]
        for c in r:
            if not c[3]: row.append(c); continue
            h,s,v=colorsys.rgb_to_hsv(c[0]/255,c[1]/255,c[2]/255)
            if s>0.7 and h<0.1 and v>0.8: row.append(c); continue   # красные/оранжевые акценты (закладка) — как есть
            R,G,B=colorsys.hsv_to_rgb(0.56,s*0.75,v); row.append((round(R*255),round(G*255),round(B*255),c[3]))
        out.append(row)
    return out
JOBS=[('spr_storage_bg','spr_fridge_bg'),('spr_ui_inventory_slot_empty','spr_ui_fridge_slot_empty'),('spr_ui_inventory_slot_item','spr_ui_fridge_slot_item'),
      ('spr_ui_inventory_slot_hover','spr_ui_fridge_slot_hover'),('spr_ui_inventory_slot_selected','spr_ui_fridge_slot_selected'),
      ('spr_ui_count_badge','spr_ui_fridge_count_badge'),('spr_ui_close_normal','spr_ui_fridge_close_normal'),('spr_ui_close_hover','spr_ui_fridge_close_hover')]
names=[]
for src,dst in JOBS:
    im=blue(load(src)); w,h=len(im[0]),len(im)
    if os.path.exists(f'{P}/sprites/{dst}'):
        for root,_,fs in os.walk(f'{P}/sprites/{dst}'):
            for x in fs:
                if x.endswith('.png'): png.write(f'{root}/{x}',w,h,im)
    else:
        gm_res.sprite(P,dst,im,(0,0),(0,0,w-1,h-1),folder=('Ui','folders/Sprites/Ui.yy')); names.append(dst)
gm_res.add_to_yyp(P,names); print('готово',len(JOBS))
