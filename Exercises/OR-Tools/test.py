from ortools.sat.python import cp_model

def sum_equals_product(sup):
    model = cp_model.CpModel()

    # Define variables
    a = model.NewIntVar(0, sup, 'A')
    b = model.NewIntVar(0, sup, 'B')
    c = model.NewIntVar(0, sup, 'C')

    # Define constraints
    model.AddAllDifferent([a, b, c])  # Ensure A, B, and C are distinct
    model.Add(a + b + c == a * b * c)  # Constraint: sum equals product

    # Create a solver and solve the model
    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    # Check if a solution was found
    if status == cp_model.FEASIBLE:
        return solver.Value(a), solver.Value(b), solver.Value(c)
    else:
        return None
  
print(sum_equals_product(10))
