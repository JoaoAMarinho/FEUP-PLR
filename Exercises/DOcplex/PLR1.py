from docplex.cp.model import CpoModel

def seq():
    model = CpoModel()
    lis = model.integer_var_list(5,1,9,"list")
    model.add(model.all_diff(lis))

    model.add((lis[2] == 1) | (lis[2] == 2))

    for i in range(len(lis)-1):
        model.add(((model.abs(lis[i] - lis[i+1]) % 2) == 1))

    solution = model.solve()
    while solution:
        solution.print_solution()
        solution = model.solve()
