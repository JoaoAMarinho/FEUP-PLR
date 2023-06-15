from docplex.cp.model import CpoModel

def Chouses(NHouses):
    model = CpoModel()

    houses = model.integer_var_list(NHouses, 1, NHouses, "Houses")
    
    model.add(model.all_diff(houses))
    model.add(houses[NHouses-1] == 6)
    
    distances = model.integer_var_list(NHouses-1, 1, NHouses, "Distances")
    for i in range(0, NHouses-1):
        model.add( distances[i] == model.abs( houses[i+1] - houses[i] ) )
    dist = model.integer_var(0, NHouses * NHouses, "Dist")
    model.add( dist == model.sum(distances) )

    model.add( model.search_phase(varchooser=model.select_smallest(model.domain_size()) , valuechooser=model.select_smallest(model.value()) ) )

    model.add( model.maximize(dist) )

    solution = model.solve(TimeLimit=120)
    
    if solution:
        solution.print_solution()

Chouses(6)
