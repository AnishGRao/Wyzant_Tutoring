import sys 
import re

String = "ababbc"
longestSubstr = ""
counter = 0
def divandconq(start,end,string,k):
    charCount = [0]*26
    for i in range(start,end):
        charCount[ord(string[i])-ord('a')]+=1
    for j in range(start,end):
        count = charCount[ord(string[j])-ord('a')]
        if count > 0 and count < k:
            left_dc = divandconq(start,j,string,k)
            right_dc = divandconq(j+1,end,string,k)
            return max(left_dc,right_dc)
    return end-start

def KRepeating(string, k):
    return divandconq(0,len(string), string, k)

def Repeat(string):
    start_idx = 0
    stop_idx = 0
    if len(string)==0:
        return "Empty String"
        exit
    Max_Occurence = 1
    for idx in range(len(string)-1):
        Temp_var = idx
        if idx+1 < len(String):
            while string[idx+1] == string [Temp_var]:
                if idx+1 < len(String):
                    idx+=1
                else:
                    break
                if idx+1 < len(String):
                    pass
                else:
                    break

        idx +=1
        if idx - Temp_var > Max_Occurence:
            Max_Occurence = idx - Temp_var
            start_idx=idx
            stop_idx = Temp_var
    return [Max_Occurence, stop_idx, start_idx]


#print(KRepeating(String, 2))
#Output = Repeat(String,2)
#print (Output[0])
#print  (String[Output[1]:Output[2]])











