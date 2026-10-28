# Чтение/запись TileCompressedData (TileDataFormat 1) комнат GameMaker
def decode(arr,n):
    out=[];i=0
    while i<len(arr) and len(out)<n:
        c=arr[i]; i+=1
        if c<0: out+= [arr[i]]*(-c); i+=1
        else: out+=arr[i:i+c]; i+=c
    assert len(out)==n,(len(out),n); return out
def encode(vals):
    out=[];i=0;n=len(vals)
    while i<n:
        j=i
        while j+1<n and vals[j+1]==vals[i] and j-i<0x7fffffff: j+=1
        run=j-i+1
        if run>=2: out+=[-run,vals[i]]; i=j+1
        else:
            k=i; lit=[]
            while k<n and not (k+1<n and vals[k+1]==vals[k]): lit.append(vals[k]); k+=1
            if not lit: lit=[vals[k]]; k+=1
            out+=[len(lit)]+lit; i=k
    return out
EMPTY=-2147483648
def idx(v): return None if v in(EMPTY,0) and v==EMPTY else (v & 0x7FFFF)
