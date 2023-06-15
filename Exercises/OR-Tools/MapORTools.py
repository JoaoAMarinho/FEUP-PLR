from timeit import default_timer as timer
from ortools.sat.python import cp_model


def Omap():
    start = timer()

    model = cp_model.CpModel()
    
    NStates = 7
    StateNames = ["WA", "NT", "SA", "Q", "NSW", "V", "T"]
    StateAdjacencies = [ (1,2), (1,3), (2,3), (2,4), (3,4), (3,5), (3,6), (4,5), (5,6) ]
    MaxColors = 5

    StateColors = [ model.NewIntVar(1, MaxColors, 'State'+str(i)) for i in range(NStates) ]
    
    for a, b in StateAdjacencies:
        model.Add(StateColors[a-1] != StateColors[b-1])

    model.Minimize( max(StateColors) )

    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    end = timer()
    print(end - start)
	
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        for i in range(NStates):
            print('%s = %i' % (StateNames[i], solver.Value(StateColors[i])), end = '   ')
    #print(solver._CpSolver__solution)


