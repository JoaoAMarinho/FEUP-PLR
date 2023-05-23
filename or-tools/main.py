from file_parser import parse_problem
from solver import solve
import sys
import json

DATA_PATH = "../data/"
RESULT_PATH = "results/"
PROBLEM_FOLDER = ["mdvrp/", "mdvrptw/", "vrptw/"]

 
def main(problem, file):
    #MDVRPTW
    mdvrptw = parse_problem("../data/mdvrptw/pr01")
    #VRPTW
    vrptw = parse_problem("../data/vrptw/c101")
    #MDVPR
    mdvrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[problem] + file)
    result = solve(mdvrp)
    with open(RESULT_PATH + PROBLEM_FOLDER[problem] + file, "w") as outfile:
        json.dump(result, outfile, indent=2)
    


if __name__ == "__main__":
    main(int(sys.argv[1]), sys.argv[2])