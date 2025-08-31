# broken_example.py
def add(a, b)   # <-- Missing colon will cause a SyntaxError
    return a + b

if __name__ == "__main__":
    print(add(2, 2))