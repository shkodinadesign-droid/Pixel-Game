# Временные портреты для диалогов пещеры (200x200, как spr_max_portrait): Хранитель меча и глиняный Страж.
# Рисуются в 50x50 и увеличиваются x4. Автор нарисует свои — заменить PNG в spr_keeper_portrait / spr_clay_guardian_portrait.
import os, sys
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'village')); import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
OUT = (30, 24, 40, 255)

def keeper():
    im = Image.new('RGBA', (50, 50), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    ROBE, ROBE_D, HAT, HAT_D, STAR = (54, 78, 160, 255), (38, 56, 120, 255), (44, 52, 130, 255), (30, 36, 96, 255), (240, 214, 110, 255)
    SKIN, BEARD = (232, 190, 160, 255), (236, 236, 240, 255)
    d.rounded_rectangle((8, 38, 41, 52), 6, fill=ROBE, outline=OUT); d.rectangle((9, 46, 40, 49), fill=ROBE_D)
    d.ellipse((15, 17, 34, 36), fill=SKIN, outline=OUT)                          # лицо
    d.polygon([(16, 29), (33, 29), (30, 44), (24, 47), (19, 44)], fill=BEARD, outline=OUT)   # длинная борода
    d.ellipse((17, 21, 23, 27), fill=(255, 255, 255, 255), outline=OUT)          # широко раскрытые глаза
    d.ellipse((26, 20, 32, 26), fill=(255, 255, 255, 255), outline=OUT)
    d.rectangle((20, 23, 21, 24), fill=OUT); d.rectangle((28, 22, 29, 23), fill=OUT)
    d.line((17, 19, 22, 18), fill=BEARD); d.line((27, 17, 32, 18), fill=BEARD)    # брови
    d.polygon([(8, 20), (42, 17), (36, 14), (14, 16)], fill=HAT, outline=OUT)     # поля шляпы (наклон головы)
    d.polygon([(14, 16), (36, 14), (29, 0), (27, 0)], fill=HAT, outline=OUT)      # высокая конусная шляпа
    for x, y in [(22, 10), (28, 6), (25, 13)]: d.point((x, y), fill=STAR)
    d.line((44, 8, 44, 50), fill=(110, 76, 44, 255), width=2); d.ellipse((42, 5, 47, 10), fill=(150, 200, 230, 255), outline=OUT)   # посох
    return im

def clay():
    im = Image.new('RGBA', (50, 50), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    CL, CL_D, CL_L = (156, 104, 72, 255), (120, 78, 54, 255), (184, 132, 96, 255)
    d.ellipse((4, 6, 46, 50), fill=CL, outline=OUT)
    d.ellipse((10, 10, 26, 22), fill=CL_L)
    for a in [(12, 30, 18, 36), (30, 34, 36, 40), (22, 40, 27, 44)]: d.line(a, fill=CL_D)   # трещины
    for x, y in [(9, 26), (38, 20), (33, 44), (15, 42)]: d.rectangle((x, y, x + 1, y + 1), fill=(120, 116, 112, 255))  # камешки
    d.ellipse((14, 20, 22, 28), fill=(250, 240, 220, 255), outline=OUT); d.ellipse((28, 20, 36, 28), fill=(250, 240, 220, 255), outline=OUT)
    d.rectangle((17, 23, 19, 25), fill=OUT); d.rectangle((31, 23, 33, 25), fill=OUT)
    d.line((14, 18, 22, 20), fill=CL_D, width=2); d.line((28, 20, 36, 18), fill=CL_D, width=2)   # нахмуренные брови
    d.line((20, 36, 30, 36), fill=CL_D, width=2)
    return im

for name, im in [('spr_keeper_portrait', keeper()), ('spr_clay_guardian_portrait', clay())]:
    big = im.resize((200, 200), Image.NEAREST); px = big.load()
    gm_anim.sprite(P, name, [[[px[x, y] for x in range(200)] for y in range(200)]], (0, 0), (0, 0, 199, 199), 0,
                   folder=('characters', 'folders/Sprites/characters.yy'))
    if len(sys.argv) > 1: big.save(os.path.join(sys.argv[1], name + '.png'))
print('ok')
