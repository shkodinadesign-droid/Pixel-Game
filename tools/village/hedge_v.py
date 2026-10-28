import sys,os;sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)));import png
w,h,p=png.read(sys.argv[1]); OUT=sys.argv[2]
cols=sorted({c[:3] for row in p for c in row if c[3]},key=lambda c:sum(c))
DARK=cols[0]+(255,); DARK2=cols[1]+(255,)
def clump(x0,x1,y0,y1,flip=False):
    r=[row[x0:x1] for row in p[y0:y1]]
    if flip: r=[list(reversed(x)) for x in r]
    cw,ch=x1-x0,y1-y0; cx,cy=(cw-1)/2,(ch-1)/2+2
    out=[[c if c[3] and ((x-cx)/(cw/2))**2+((y-cy)/(ch/2+1))**2<=1 else (0,0,0,0) for x,c in enumerate(row)] for y,row in enumerate(r)]
    # тёмная кромка по краю силуэта (как у исходного куста)
    res=[list(row) for row in out]
    for y in range(ch):
        for x in range(cw):
            if out[y][x][3]:
                edge=any(not(0<=x+dx<cw and 0<=y+dy<ch) or not out[y+dy][x+dx][3] for dx,dy in((1,0),(-1,0),(0,1)))
                if edge and sum(out[y][x][:3])>sum(DARK2[:3]): res[y][x]=DARK2 if y<ch//2 else DARK
    return res
A=clump(14,44,0,32); Bc=clump(38,67,0,32,True)
W=32; steps=[(A,0,1),(Bc,18,2),(A,36,1),(Bc,54,2)]
H=54+32
img=[[(0,0,0,0)]*W for _ in range(H)]
for (cl,oy,ox) in steps:
    for y,row in enumerate(cl):
        for x,c in enumerate(row):
            if c[3] and 0<=ox+x<W: img[oy+y][ox+x]=c
fl=[row[8:16] for row in p[17:25]]
for (fx,fy) in((4,28),(19,60)):
    for y,row in enumerate(fl):
        for x,c in enumerate(row):
            if c[3] and (c[0]>200 or c[1]>170) and 0<=fx+x<W: img[fy+y][fx+x]=c
ys=[y for y in range(H) if any(c[3] for c in img[y])]; xs=[x for x in range(W) if any(img[y][x][3] for y in range(H))]
img=[row[min(xs):max(xs)+1] for row in img[min(ys):max(ys)+1]]
png.write(OUT,len(img[0]),len(img),img); print(len(img[0]),len(img))
