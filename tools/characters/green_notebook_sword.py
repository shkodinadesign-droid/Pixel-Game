# Развороты зелёной тетради (рисунки автора, 11-27) -> спрайты GameMaker:
#   spr_green_notebook_sword  820x502  разворот 1: «Меч героя» + запись о Джо
#   spr_green_notebook_cave   920x481  разворот 2: поход к пещере + набросок скал, «Джо помнит поворот у расколотого камня»
# Источники уже обрезаны (без кнопки «Дальше») и уменьшены: tools/art_src/green_notebook_*.png
# Запуск (GameMaker закрыт): python3 tools/characters/green_notebook_sword.py
import os, sys
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.join(HERE, '..', 'village'))
import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
for src, name in [('green_notebook_sword.png', 'spr_green_notebook_sword'), ('green_notebook_cave.png', 'spr_green_notebook_cave')]:
    im = Image.open(os.path.join(HERE, '..', 'art_src', src)).convert('RGBA')
    W, H = im.size
    px = list(im.getdata()); rows = [px[y * W:(y + 1) * W] for y in range(H)]
    gm_anim.sprite(P, name, [rows], (0, 0), (0, 0, W - 1, H - 1), 1, folder=('forest', 'folders/Sprites/forest.yy'))
    print('ok', name, W, H)
