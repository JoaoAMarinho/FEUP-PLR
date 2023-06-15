from docplex.cp.model import CpoModel

def Cmap():
    model = CpoModel()

    NStates = 7
    StateNames = ["WA", "NT", "SA", "Q", "NSW", "V", "T"]
    StateAdjacencies = [ (1,2), (1,3), (2,3), (2,4), (3,4), (3,5), (3,6), (4,5), (5,6) ]
    MaxColors = 5

    StateColors = model.integer_var_list(NStates, 1, MaxColors, "StateColors")

    for a, b in StateAdjacencies:
        model.add(StateColors[a-1] != StateColors[b-1])
        
    AllColors = list( range(1, MaxColors+1) )
    ColorCounts = model.integer_var_list(MaxColors, 0, NStates, "ColorCounts")
    model.add(model.distribute(ColorCounts, StateColors, AllColors))
    model.add( model.maximize(model.count(ColorCounts, 0)) )

    solution = model.solve(TimeLimit=120)
    
    if solution:
        solution.print_solution()
