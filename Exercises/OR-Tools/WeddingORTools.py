from ortools.sat.python import cp_model

def Otable():
    # Adam 1
    # Bernadette 2
    # Christina 3
    # Dina 4
    # Emmet 5
    # Francis 6

    TableSize = 6
    Adjacents = [ [1, 2], [3, 5] ]
    Distants = [ [5, 6], [1, 5] ]

    PersonSeat = [TableSize]
    
    model = cp_model.CpModel()

    for i in range(TableSize):
        PersonSeat.append( model.NewIntVar(1, TableSize, "p"+str(i+1)) )
    model.AddAllDifferent(PersonSeat[1:])
    
    distances = []
    for pair in Adjacents:
        distances.append(model.NewIntVarFromDomain(cp_model.Domain.FromValues([-TableSize+1, -1,1, TableSize-1]), "d"+str(pair[0])+str(pair[1])  ))
        model.Add( PersonSeat[ pair[0] ] - PersonSeat[ pair[1] ] == distances[-1] )
    for pair in Distants:
        model.Add(PersonSeat[ pair[0] ] - PersonSeat[ pair[1] ] != 1)
        model.Add(PersonSeat[ pair[0] ] - PersonSeat[ pair[1] ] != -1)
        model.Add(PersonSeat[ pair[0] ] - PersonSeat[ pair[1] ] != TableSize-1)
        model.Add(PersonSeat[ pair[0] ] - PersonSeat[ pair[1] ] != -TableSize+1)
    
    model.Add( PersonSeat[1] == 1)
    model.Add( PersonSeat[2] == 2)

    solver = cp_model.CpSolver()

    printer = VarArraySolutionPrinter(PersonSeat[1:])
    status = solver.SearchForAllSolutions(model, printer)

    status = solver.Solve(model)
    for var in PersonSeat[1:]:
        print('%s = %i' % (var, solver.Value(var)), end = '   ')
    print(solver._CpSolver__solution)

    

class VarArraySolutionPrinter(cp_model.CpSolverSolutionCallback):
    """Print intermediate solutions."""

    def __init__(self, variables):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self.__variables = variables
        self.__solution_count = 0

    def on_solution_callback(self):
        self.__solution_count += 1
        for v in self.__variables:
            print('%s=%i' % (v, self.Value(v)), end='  ')
        print()

    def solution_count(self):
        return self.__solution_count

