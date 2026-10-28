import json,re
def load(p):
    t=open(p,encoding='utf-8').read()
    t=re.sub(r',(\s*[}\]])',r'\1',t)
    return json.loads(t)
