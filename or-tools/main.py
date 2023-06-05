from file_parser import parse_problem
from solver import solve
from ortools.constraint_solver import routing_enums_pb2
import sys
import json

DATA_PATH = "../data/"
RESULT_PATH = "results/"
PROBLEM_FOLDER = ["mdvrp/", "mdvrptw/", "vrptw/"]
FILES = [[
    "pr01",
    "pr02",
    "pr03",
    "pr04",
    "pr05",
    "pr06",
    "pr07",
    "pr08",
    "pr09",
    "pr10"
], [
    "pr01",
    "pr02",
    "pr03",
    "pr04",
    "pr05",
    "pr06",
    "pr07",
    "pr08",
    "pr09",
    "pr10",
], [
    "c100",
    "c101",
    "c102",
    "c103",
    "c104",
    "c105",
    "c106",
    "c107",
    "c108",
    "c109"
]]

SEARCH_PARAMS = {
    "cheap-arc"  : routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC, 
    "most-const" : routing_enums_pb2.FirstSolutionStrategy.PATH_MOST_CONSTRAINED_ARC,
    "cheap-ins"  : routing_enums_pb2.FirstSolutionStrategy.LOCAL_CHEAPEST_INSERTION,
    "best"       : routing_enums_pb2.FirstSolutionStrategy.BEST_INSERTION,
    "glob-cheap"      : routing_enums_pb2.FirstSolutionStrategy.GLOBAL_CHEAPEST_ARC,
    "auto"       : routing_enums_pb2.FirstSolutionStrategy.AUTOMATIC
}

 
def main(problem, file, fs):
    vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[problem] + file)
    result = solve(vrp, fs)
    return result
    


if __name__ == "__main__":
    for i in range(3): #Problem
        for file in FILES[i]: #FILE
            file_data = {}
            for fs in SEARCH_PARAMS:
                file_data[fs] = main(i, file, SEARCH_PARAMS[fs])
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "w") as outfile:
                json.dump(file_data, outfile, indent=2)