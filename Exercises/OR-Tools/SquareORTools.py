from ortools.sat.python import cp_model

def Osquare():
    model = cp_model.CpModel()

    List = [ model.NewIntVar(1, 9, 'v'+str(x+1)) for x in range(9) ] 

    #Sum = model.NewIntVar(1, 27, "Sum")
    Sum = model.NewConstant(15)

    for i in range(3):
        model.Add( List[i*3] + List[i*3+1] + List[i*3+2] == Sum )    # Rows
        model.Add( List[i] + List[3+i] + List[6+i] == Sum )          # Cols
    model.Add( List[0] + List[4] + List[8] == Sum )          # Diag \
    model.Add( List[6] + List[4] + List[2] == Sum )          # Diag /

    model.AddAllDifferent(List)

    # Remove Symmetries
    model.Add( List[0] < List[2] )
    model.Add( List[2] < List[6] )

    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        for var in List:
            print('%s = %i' % (var, solver.Value(var)), end = '   ')
    print(solver._CpSolver__solution)

Osquare()
    