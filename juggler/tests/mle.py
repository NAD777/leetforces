# code or function for which memory
# has to be monitored
def app():
    lt = []
    for i in range(0, 100000):
        lt.append("A"*1000 + str(i))

# function call
app()

a, b = map(int, input().split())
print(a + b)
