# Sečti n čísel

def sum(n: int) -> int:
    s = 0
    for i in range(n+1):
        s += i
    return s

if __name__ == '__main__':
    n = 10
    print("n: \t", n)
    print("sum:\t", sum(n))