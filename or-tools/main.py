from file_parser import parse_problem
 
def main():
    #MDVRPTW
    mdvrptw = parse_problem("../data/mdvrptw/pr01")
    print(mdvrptw.get_distance_matrix())
    print("\n\n")
    #VRPTW
    vrptw = parse_problem("../data/vrptw/c101")
    print(vrptw.get_distance_matrix())
    print("\n\n")
    #MDVPR
    mdvrp = parse_problem("../data/mdvrp/pr01")
    print(mdvrp.get_distance_matrix())
    print("\n\n")
    return


if __name__ == "__main__":
    main()