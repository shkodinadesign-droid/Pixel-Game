# Разворот зелёной тетради «Меч героя» (рисунок автора, 11-27) -> спрайт spr_green_notebook_sword 820x502.
# Источник уже обрезан (без кнопки «Дальше») и уменьшен: tools/art_src/green_notebook_sword.png
# Запуск (GameMaker закрыт): python3 tools/characters/green_notebook_sword.py
import os, sys
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.join(HERE, '..', 'village'))
import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
im = Image.open(os.path.join(HERE, '..', 'art_src', 'green_notebook_sword.png')).convert('RGBA')
W, H = im.size
px = list(im.getdata()); rows = [px[y * W:(y + 1) * W] for y in range(H)]
gm_anim.sprite(P, 'spr_green_notebook_sword', [rows], (0, 0), (0, 0, W - 1, H - 1), 1, folder=('forest', 'folders/Sprites/forest.yy'))
print('ok', W, H)
