from docplex.cp.model import CpoModel

def Csquare():
    SIZE = 3

    model = CpoModel()
    Square = model.integer_var_list(SIZE * SIZE, 1, SIZE * SIZE, "Squares")
    
    #Sum = model.integer_var(1, SIZE * SIZE * SIZE, "Sum")

    Sum = model.integer_var(15, 15, "Sum")

    for i in range(SIZE):
        model.add( Square[i*3] + Square[i*3+1] + Square[i*3+2] == Sum )     # Line i
        model.add( Square[i] + Square[3+i] + Square[6+i] == Sum )           # Column i
    model.add( Square[0] + Square[4] + Square[8] == Sum )                     # Diagonal \
    model.add( Square[6] + Square[4] + Square[2] == Sum )                     # Diagonal /

    model.add(model.all_diff(Square))

    model.add( Square[0] < Square[2] )
    model.add( Square[2] < Square[6] )

    solution = model.solve()
    
    if solution:
        solution.print_solution()
    