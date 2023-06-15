from docplex.cp.model import CpoModel

def Cbuses():
    model = CpoModel()

    # Groups (Weights)
    NGroups = 5
    Weights = [5, 5, 7, 4, 3]
    

    # Buses (MaxLoads)
    NBuses = 4
    MaxLoads = [11, 14, 10, 20]
    MaxMaxLoad = max(MaxLoads)
    Loads = model.integer_var_list(NBuses, 0, MaxMaxLoad, "Loads")

    # Attribution (Packing)
    PackIDs = model.integer_var_list(NGroups, 1, NBuses, "PackIDs")

    # Used Buses (Non-zero)
    NonZero = model.integer_var(1, NBuses, "NonZero")

    for i in range(NBuses):
        model.add( Loads[i] <= MaxLoads[i] )    
    model.add(model.pack(Loads, PackIDs, Weights, NonZero))
    
    model.add( model.minimize(NonZero) )

    solution = model.solve(TimeLimit=120)
    
    if solution:
        solution.print_solution()

Cbuses()
