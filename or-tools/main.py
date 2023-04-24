from file_parser import parse_problem 
 
def main():
    #MDVRPTW
    parse_problem("../data/mdvrptw/pr01")
    #VRPTW
    parse_problem("../data/vrptw/c101")
    #MDVPR
    parse_problem("../data/mdvrp/pr01")
    return


if __name__ == "__main__":
    main()