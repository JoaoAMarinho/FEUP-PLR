from ortools.sat.python import cp_model
from ortools.sat.python.cp_model import VarArraySolutionPrinter

class CLP1:
    def __init__(self):
        self.solver = cp_model.CpSolver()

    def getModel(self):
        return cp_model.CpModel()

    def solve(self, model, vars):
        solution_printer = VarArraySolutionPrinter(vars)
        self.solver.SearchForAllSolutions(model, solution_printer)
        print(f"\nStatus: {self.solver.StatusName()}")

    def ex1(self):
        model = self.getModel()
        sup = int(input("Insert upper bound: "))
        a = model.NewIntVar(0, sup, 'a')
        b = model.NewIntVar(0, sup, 'b')
        c = model.NewIntVar(0, sup, 'c')

        sum_ = model.NewIntVar(0, 3*sup, 'sum')
        model.Add(sum_ == sum([a,b,c]))
        
        x = model.NewIntVar(0, 1000, 'x')
        model.AddMultiplicationEquality(x, [a, b])
        model.AddMultiplicationEquality(sum_, [x, c])
        self.solve(model, [a, b, c])

    def ex4(self):
        model = self.getModel()
        N = int(input("Insert n: "))

        vars = [ model.NewIntVar(1, N, f"v{x}") for x in range(N) ]
        model.AddAllDifferent(vars)

        for i in range(N-1):
            for j in range(i+1, N):
                absolute = model.NewIntVar(0, N, f"abs({i}-{j})")
                model.AddAbsEquality(absolute, vars[i] - vars[j])
                model.Add(absolute != abs(j-i))

        self.solve(model, vars)


def __main__():
    clp = CLP1()
    problem = int(input("Insert problem number: "))

    match problem:
        case 1:
            clp.ex1()
        case 4:
            clp.ex4()
        case _:
            print("No such problem")

if __name__ == "__main__":
    __main__()
