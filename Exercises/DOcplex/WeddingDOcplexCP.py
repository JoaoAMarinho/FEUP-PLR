from docplex.cp.model import CpoModel


def Ctable():
    # Adam 1
    # Bernadette 2
    # Christina 3
    # Dina 4
    # Emmet 5
    # Francis 6

    TableSize = 6
    Adjacents = [ [1, 2], [3, 5] ]
    Distants = [ [5, 6], [1, 5] ]

    model = CpoModel()

    PersonSeat = model.integer_var_list(TableSize, 1, TableSize, "PersonSeat")
    model.add(model.all_diff(PersonSeat))

    distances = []
    for pair in Adjacents:
        distances.append(model.integer_var(domain=(-TableSize+1, -1, 1, TableSize-1), name="d"+str(pair[0])+str(pair[1])  ))
        model.add( PersonSeat[ pair[0]-1 ] - PersonSeat[ pair[1]-1 ] == distances[-1] )
    for pair in Distants:
        model.add(PersonSeat[ pair[0]-1 ] - PersonSeat[ pair[1]-1 ] != 1)
        model.add(PersonSeat[ pair[0]-1 ] - PersonSeat[ pair[1]-1 ] != -1)
        model.add(PersonSeat[ pair[0]-1 ] - PersonSeat[ pair[1]-1 ] != TableSize-1)
        model.add(PersonSeat[ pair[0]-1 ] - PersonSeat[ pair[1]-1 ] != -TableSize+1)
    
    model.add( PersonSeat[0] == 1)
    model.add( PersonSeat[1] == 2)

    solution = model.solve(TimeLimit=120)
    
    if solution:
        solution.print_solution()

