
#number = 25
#range(X) means from 0 to the number X - 1 or, mathematically,  ([0,X)) 

#range is a list operator
#range(3) -> create this list: [0,1,2]
#X = range(5) is the same as X = [0,1,2,3,4]
#for i in _____ means for index, starting at 0, and until the end, go through the list.

List = ['fff','ggg','hhh','jjj']
for i in List:
    print(i)





val = 0

for i in range(11):
    if i % 2 == 0 and i != 0:
        #the number is even
        for j in range(11):
            if j % 2 == 0:
                #the number is even
                None
            if j % 2 == 1 and j != 0:
                #the number is odd
                val = j + i
                print(f'{i} + {j} = {val}')

    else:
        #the number is odd
        None







'''
for counter in range(number):
    print(counter)

while counter < number:
    if number % counter == 0:
        print(f'{counter}\n')
    counter = counter + 1

The modulo operator is a mathematical operation.

It says, give me the remainder after I divide.


e.g. 4 / 2 has a remainder of 0--so 4 % 2 = 0

10 / 5 = 2. 2 is a whole number, so 10 % 5 = 0

This patter continues, and you can generalize.


if X % Y = 0, then X is divisible by Y.

If X is some number, and Y is 2:

X % 2 is either 0 or 1.


If X % 2 is 0, then X IS EVEN.

X % 2 is 1, then X IS ODD.

'''
