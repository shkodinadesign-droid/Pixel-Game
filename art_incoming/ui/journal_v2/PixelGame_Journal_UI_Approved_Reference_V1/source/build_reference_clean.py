from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
from collections import deque
import numpy as np,zipfile
root=Path('/mnt/data/PixelGame_Journal_UI_Approved_Reference_V1')
src=Path('/mnt/data/пиксельное_меню_книга_для_уютной_игры.png')
im=Image.open(src).convert('RGBA')
import shutil; shutil.copy2(src,root/'REFERENCE_APPROVED_ORIGINAL_1672x941.png')
a=np.array(im,dtype=np.uint8)
H,W=a.shape[:2]
# outer white area background pixels, flood fill from corners; stops at dark cover
c=a[:,:,:3].astype(np.int16)
mask=(np.min(c,axis=2)>206)&((np.max(c,axis=2)-np.min(c,axis=2))<20)
# flood fill from borders (conservative)
seen=np.zeros((H,W),bool)
q=deque()
for x in range(W):
    if mask[0,x] and not seen[0,x]: seen[0,x]=True;q.append((0,x))
    if mask[H-1,x] and not seen[H-1,x]: seen[H-1,x]=True;q.append((H-1,x))
for y in range(H):
    if mask[y,0] and not seen[y,0]: seen[y,0]=True;q.append((y,0))
    if mask[y,W-1] and not seen[y,W-1]: seen[y,W-1]=True;q.append((y,W-1))
while q:
    y,x=q.popleft()
    for ny,nx in ((y+1,x),(y-1,x),(y,x+1),(y,x-1)):
        if 0<=ny<H and 0<=nx<W and mask[ny,nx] and not seen[ny,nx]:
            seen[ny,nx]=True;q.append((ny,nx))
a[seen,3]=0
# Remove tabs above existing book / rebuild central top cover/page sections
# We don't use antialias: cover top is flat-edged pixels resembling material in reference.
for x1,x2 in [(110,925)]:
    a[:55,x1:x2,3]=0
im=Image.fromarray(a)
d=ImageDraw.Draw(im)
# replace tab area on top of cover y55..102
d.rectangle((110,55,924,98),fill=(121,57,41,255))
d.rectangle((115,56,918,62),fill=(80,36,28,255))
d.rectangle((116,64,917,69),fill=(169,95,64,255))
# reconstruct book pages upper edge behind tabs
d.rectangle((115,99,815,107),fill=(252,222,170,255))
d.rectangle((836,99,925,107),fill=(252,222,170,255))
d.rectangle((120,101,814,104),fill=(226,184,131,255))
d.rectangle((839,101,925,104),fill=(226,184,131,255))
d.line([(816,98),(829,111),(837,99)],fill=(172,104,55,255),width=4)
# remove 4 left cards and right bottom 2 cards while preserving surrounding page and ornaments
d.rectangle((143,280,792,771),fill=(252,222,170,255))
d.rectangle((868,589,1528,775),fill=(252,222,170,255))
# add tiny subtle pixel texture to avoid sudden flat/smooth discontinuity; still sharp, no antialias
# Keep texture extremely restrained to avoid visual noise
for y in range(294,762,16):
    for x in range(166,771,23):
        if ((x*7+y*11)%19)==0:d.rectangle((x,y,x+1,y+1),fill=(248,215,163,255))
for y in range(610,758,16):
    for x in range(888,1492,23):
        if ((x*3+y*7)%21)==0:d.rectangle((x,y,x+1,y+1),fill=(248,215,163,255))
# remove visual residual card under page corner ? inspect later
im.save(root/'sprites/book/ui_journal_book_reference_clean_1672x941.png')
# contrasting preview of minimal and ref-based books
vis=Image.new('RGB',(1672,1990),(249,245,238))
b0=Image.open(root/'sprites/book/ui_journal_book_base_1672x941.png').convert('RGBA')
vis.paste(b0,(0,0),b0)
vis.paste(im,(0,1000),im)
vis.save(root/'PREVIEW_TWO_BOOK_BASES.png')
print('REFERENCE BASE',im.size,'BG alpha',im.getpixel((0,0)))
