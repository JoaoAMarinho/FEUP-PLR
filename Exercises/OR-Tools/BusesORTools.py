from ortools.sat.python import cp_model

def Obuses():
    model = cp_model.CpModel()

    # Groups (Weights)
    NGroups = 5
    Weights = [5, 5, 7, 4, 3]

    # Buses (MaxLoads)
    NBuses = 4
    MaxLoads = [11, 14, 10, 20]
    
    Loads = [model.NewIntVar(0, MaxLoads[i], "Loads"+str(i)) for i in range(NBuses)]

    # Attribution (0-1 Matrix)
    Attribution = [ [model.NewIntVar(0, 1, "Attr"+str(i)+str(j) ) for i in range(NBuses)] for j in range(NGroups)]
    # Groups are exactly on one Bus
    for i in range(NGroups):
        model.Add( 1 == sum(Attribution[i][j] for j in range(NBuses)) )

    # Max Loads on Buses
    for i in range(NBuses):
        model.Add( Loads[i] == sum(Attribution[j][i]*Weights[j] for j in range(NGroups) ) )
    
    # Used Buses (Non-zero)
    Zeros = model.NewIntVar(1, NBuses, "Zeros")
    add_count_eq(Loads, 0, Zeros, model)

    model.Maximize( Zeros )

    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        print( "Zeros: %s" % solver.Value(Zeros) )
        for i in range(NGroups):
            for j in range(NBuses):
                print('%s = %i' % (Attribution[i][j], solver.Value(Attribution[i][j])), end = '\t\t')
            print(Weights[i])
        for i in range(NBuses):
            print('%s = %i' % (Loads[i], solver.Value(Loads[i])), end = '\t\t')


def add_count_eq(vars, value, count, model):
    boolvars = []
    for var in vars:
        boolvar = model.NewBoolVar('')
        model.Add(var == value).OnlyEnforceIf(boolvar)
        model.Add(var != value).OnlyEnforceIf(boolvar.Not())
        boolvars.append(boolvar)
    model.Add(count == sum(boolvars))