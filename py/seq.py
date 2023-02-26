def last(s):
    return s[-1]

def others(s):
    return s[:-1]

def add_item(s v):
    s[len(s)] = v
    return s

def nilp(s):
    return len(s) == 0
