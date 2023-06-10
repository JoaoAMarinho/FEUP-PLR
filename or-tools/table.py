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
    "pr00",
    "pr01",
    "pr02",
    "pr03",
    "pr04",
    "pr05",
    "pr06",
    "pr07",
    "pr08",
    "pr09",
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

SEARCH_PARAMS = [
    "cheap-arc",   
    "most-const",
    "cheap-ins", 
    "auto"
]

for i in range(3): #Problem
    print("\n\n\n\n")
    for file in FILES[i]: #FILE
        print("\multirow{4}{*}{" + file  +"} ")
        with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
            file_data = json.load(outfile)
        for param in SEARCH_PARAMS:
            time = "-" if len(file_data[param]['cost']) == 0 else str(file_data[param]['time'][-1])
            cost = "-" if len(file_data[param]['cost']) == 0 else str(file_data[param]['cost'][-1])
            print(" & " + param + " & "+cost+" & " + time+  "\\\\\cline{2-4}")
        print("\hline")