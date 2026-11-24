# Временные иконки сюжетных предметов для хотбара (30x30, левый верх): ключ от тайной комнаты и старая фотография.
# Автор нарисует свои — тогда просто заменить PNG в спрайтах (или поправить этот скрипт).
import os, sys
from PIL import Image, ImageDraw, ImageFilter
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'village')); import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
N = 30
OUT = (74, 44, 18, 255); GOLD = (226, 172, 58, 255); LIGHT = (255, 228, 128, 255); DARK = (170, 118, 34, 255)

def outlined(fill_mask, color_img):
    """Обвести силуэт тёмным контуром в 1 пиксель."""
    edge = fill_mask.filter(ImageFilter.MaxFilter(3))
    out = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    out.paste(Image.new('RGBA', (N, N), OUT), (0, 0), edge)
    out.alpha_composite(color_img)
    return out

def key_icon():
    m = Image.new('L', (N, N), 0); d = ImageDraw.Draw(m)
    d.ellipse((3, 8, 15, 20), fill=255)               # головка-кольцо
    d.rectangle((14, 13, 27, 15), fill=255)           # стержень
    d.rectangle((21, 15, 23, 20), fill=255)           # бородка
    d.rectangle((25, 15, 27, 18), fill=255)
    d.ellipse((6, 11, 12, 17), fill=0)                # дырка в кольце
    c = Image.new('RGBA', (N, N), (0, 0, 0, 0)); c.paste(Image.new('RGBA', (N, N), GOLD), (0, 0), m)
    cd = ImageDraw.Draw(c)
    cd.arc((3, 8, 15, 20), 180, 290, fill=LIGHT)      # блик на кольце
    cd.line((15, 13, 26, 13), fill=LIGHT)             # блик на стержне
    cd.line((15, 15, 20, 15), fill=DARK)
    cd.point((4, 13), fill=LIGHT)
    hole = Image.new('L', (N, N), 0); ImageDraw.Draw(hole).ellipse((6, 11, 12, 17), fill=255)
    img = outlined(m, c)
    # внутренний контур дырки
    ring = hole.filter(ImageFilter.MaxFilter(3)); inner = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    inner.paste(Image.new('RGBA', (N, N), OUT), (0, 0), Image.composite(ring, Image.new('L', (N, N), 0), m))
    img.alpha_composite(inner)
    img.paste((0, 0, 0, 0), (0, 0), hole)
    return img

def photo_icon():
    src = Image.open(os.path.join(HERE, '..', 'art_src', 'photo_sonya_maggie.png')).convert('RGBA')
    thumb = src.crop((40, 40, src.width - 40, src.height - 40)).resize((22, 16), Image.LANCZOS)
    card = Image.new('RGBA', (26, 20), (240, 228, 200, 255)); card.alpha_composite(thumb, (2, 2))
    ImageDraw.Draw(card).rectangle((0, 0, 25, 19), outline=(120, 92, 60, 255))
    img = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    img.alpha_composite(card, ((N - card.width) // 2, (N - card.height) // 2))
    return img

for name, im in [('spr_item_secret_key', key_icon()), ('spr_item_old_photo', photo_icon())]:
    px = im.load(); rows = [[px[x, y] for x in range(N)] for y in range(N)]
    gm_anim.sprite(P, name, [rows], (0, 0), (0, 0, N - 1, N - 1), 0, folder=('characters', 'folders/Sprites/characters.yy'))
    if len(sys.argv) > 1: im.resize((N * 8, N * 8), Image.NEAREST).save(os.path.join(sys.argv[1], name + '.png'))
print('ok')
