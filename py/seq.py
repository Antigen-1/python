def last(s):
    return s[-1]

def others(s):
    return s[:-1]

def add_item(s v):
    s[len(s)] = v
    return s

# though the python sequence protocol does support several datatypes,
# the nil variable is used only to build new sequences.
nil = []

