# fibonaci recursion function

from my_colors import *

number_of_recursions = 0

def fibonacci_loop(n):
    # loop
    a = 0
    b = 1
    for i in range(n):
        a, b = b, a + b
    return a

def fibonacci_recurent(n):
    # recursion
    global number_of_recursions
    number_of_recursions += 1
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci_recurent(n-1) + fibonacci_recurent(n-2)
    
if __name__ == '__main__':
    n = 10
    print(Green + "fibonaci_loop("+Blue + str(n) +NC + "): \t", Blue, fibonacci_loop(n), NC)
    print(Green + "fibonaci_recursion("+Blue + str(n) +NC +"): ", Blue, fibonacci_recurent(n), NC)
    print(Green + "number of recursions: \t", Blue, number_of_recursions, NC)