import sys
import re


def P(_str):
    _str=_str.lower()
    _str="".join(_str.split())
    _map = [0]*128
    count = 0
    for i in range(len(_str)):
        _map[ord(_str[i])]+=1
        if  _map[ord(_str[i])] % 2 == 0:
            count-=1
        else:
            count+=1
    if count <= 1:
        return True
    return False


print(P("abbca"))

