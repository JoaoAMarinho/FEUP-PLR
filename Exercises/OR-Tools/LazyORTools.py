from timeit import default_timer as timer
from ortools.sat.python import cp_model


def Ohouses(NHouses):
    start = timer()

    model = cp_model.CpModel()
    
    houses = [ model.NewIntVar(1, NHouses, 'h'+str(i)) for i in range(1,NHouses+1) ]

    model.AddAllDifferent(houses)
    model.AddElement(NHouses-1, houses, 6)

    travelTime = []
    for i in range(NHouses-1):
        tempVar = model.NewIntVar(-NHouses, NHouses, 'o'+str(i))
        model.Add( tempVar == houses[i+1]-houses[i] )
        travelTime.append( model.NewIntVar(1, NHouses, 'd'+str(i)) )
        model.AddAbsEquality( travelTime[-1], tempVar )
    dist = model.NewIntVar(0, NHouses*NHouses, "Dist")
    model.Add( dist == sum(travelTime) )
    model.Maximize( dist )

    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    end = timer()
    print(end - start)
	
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        print( "Distance: %s" % solver.Value(dist) )
        for var in houses:
            print('%s = %i' % (var, solver.Value(var)), end = '   ')
    #print(solver._CpSolver__solution)


