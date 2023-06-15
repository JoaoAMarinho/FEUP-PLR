from docplex.cp.model import CpoModel

def tresQuads(n):
    model = CpoModel()
    a = model.integer_var(1, n, "A")
    b = model.integer_var(1, n, "B")
    c = model.integer_var(1, n, "C")

    model.add(a < b)
    model.add(b < c)

    x = model.integer_var(1, 3*n, "X")
    xs = model.integer_var(1, 3*n, "XS")
    model.add(xs == x*x)
    y = model.integer_var(1, n*n+n, "y")
    ys = model.integer_var(1, n*n+n, "yS")
    model.add(ys == y*y)
    w = model.integer_var(1, n*n+n, "w")
    ws = model.integer_var(1, n*n+n, "wS")
    model.add(ws == w*w)
    z = model.integer_var(1, n*n+n, "z")
    zs = model.integer_var(1, n*n+n, "zS")
    model.add(zs == z*z)

    model.add(xs == a + b + c)
    model.add(ys == a * b + c)
    model.add(ws == a * c + b)
    model.add(zs == c * b + a)

    solution = model.solve()
    if solution:
        solution.print_solution()


def golomb(n, maxVal):
    model = CpoModel()
    vars = model.integer_var_list(n, 0, maxVal, "vars")

    diffs = []
    for i in range(n):
        for j in range(i+1,n):
            model.add(vars[i] < vars[j])
            diff = model.integer_var(1, maxVal, f"diff{i}{j}")
            model.add(diff == vars[j] - vars[i])
            diffs.append(diff)

    model.add(model.all_diff(diffs))
    solution = model.solve()

    if solution:
        solution.print_solution()

def golomb_opt(n,maxVal):
    model = CpoModel()
    vars = model.integer_var_list(n, 0, maxVal, "vars")

    diffs = []
    for i in range(n):
        for j in range(i+1,n):
            model.add(vars[i] < vars[j])
            diff = model.integer_var(1, maxVal, f"diff{i}{j}")
            model.add(diff == vars[j] - vars[i])
            diffs.append(diff)

    model.add(model.all_diff(diffs))
    model.add(model.minimize(vars[n-1]))
    solution = model.solve()
    if solution:
        solution.print_solution()


def boats(limit):
    n = len(limit)
    model = CpoModel()
    order = model.integer_var_list(n, 1, n, "order")
    model.add(model.all_diff(order))

    pen_list = []
    for i in range(n):
        model.add(order[i] <= limit[i])
        pen = model.integer_var(-n, n, f"pen{i}")
        model.add(pen == ((order[i]-1 - i) > 0) * (order[i]-1 - i))
        pen_list.append(pen)

    model.add(model.minimize(sum(pen_list)))
    solution = model.solve()
    if solution:
        solution.print_solution()
