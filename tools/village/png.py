import zlib,struct
def read(p):
    d=open(p,'rb').read(); assert d[:8]==b'\x89PNG\r\n\x1a\n'
    i=8; idat=b''; plte=None; trns=None
    while i<len(d):
        n,=struct.unpack('>I',d[i:i+4]); t=d[i+4:i+8]; c=d[i+8:i+8+n]; i+=12+n
        if t==b'IHDR': w,h,bd,ct,_,_,il=struct.unpack('>IIBBBBB',c)
        elif t==b'IDAT': idat+=c
        elif t==b'PLTE': plte=[tuple(c[j:j+3]) for j in range(0,len(c),3)]
        elif t==b'tRNS': trns=c
    assert bd==8 and il==0,(bd,il,p)
    ch={6:4,2:3,0:1,4:2,3:1}[ct]; raw=zlib.decompress(idat); s=w*ch; out=[]; prev=bytearray(s); k=0
    for y in range(h):
        f=raw[k]; line=bytearray(raw[k+1:k+1+s]); k+=1+s
        for x in range(s):
            a=line[x-ch] if x>=ch else 0; b=prev[x]; cc=prev[x-ch] if x>=ch else 0
            if f==1: line[x]=(line[x]+a)&255
            elif f==2: line[x]=(line[x]+b)&255
            elif f==3: line[x]=(line[x]+(a+b)//2)&255
            elif f==4:
                pp=a+b-cc; pa,pb,pc=abs(pp-a),abs(pp-b),abs(pp-cc)
                line[x]=(line[x]+(a if pa<=pb and pa<=pc else b if pb<=pc else cc))&255
        prev=line
        row=[]
        for x in range(w):
            px=line[x*ch:(x+1)*ch]
            if ct==6: row.append(tuple(px))
            elif ct==2: row.append(tuple(px)+(255,))
            elif ct==0: row.append((px[0],)*3+(255,))
            elif ct==4: row.append((px[0],)*3+(px[1],))
            elif ct==3: idx=px[0]; row.append(plte[idx]+((trns[idx] if trns and idx<len(trns) else 255),))
        out.append(row)
    return w,h,out
def write(p,w,h,px):
    raw=b''.join(b'\x00'+bytes(v for c in row for v in c) for row in px)
    def ch(t,c): return struct.pack('>I',len(c))+t+c+struct.pack('>I',zlib.crc32(t+c)&0xffffffff)
    open(p,'wb').write(b'\x89PNG\r\n\x1a\n'+ch(b'IHDR',struct.pack('>IIBBBBB',w,h,8,6,0,0,0))+ch(b'IDAT',zlib.compress(raw,9))+ch(b'IEND',b''))
