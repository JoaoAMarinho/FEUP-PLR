import json
import matplotlib.pyplot as plt

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

BEST = [[
    "cheap-arc",
    "cheap-arc",
    "most-const",
    "auto",
    "cheap-arc",
    "cheap-arc",
    "auto",
    "cheap-ins",
    "cheap-arc",
    "cheap-arc"
], [
    "most-const",
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
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins"
]]

SEARCH_PARAMS = [
    "cheap-arc",   
    "most-const",
    "cheap-ins", 
    "best" ,  
    "auto"
]

if __name__ == "__main__":
    for i in range(3): #Problem
        for file in FILES[i]: #FILE
            file_best = {}
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            for param in SEARCH_PARAMS:
                n = len(file_data[param]["time"])
                if n > 0:
                    file_best[param] = {}
                    file_best[param]["cost"] = file_data[param]["cost"][n-1]
                    file_best[param]["time"] = file_data[param]["time"][n-1]
                plt.plot(file_data[param]["time"], file_data[param]["cost"], label=param)

            print(PROBLEM_FOLDER[i] + file + "\n\n")
            for j in file_best:
                print(f"{j} C: {file_best[j]['cost']} T: {file_best[j]['time']}")
            
            plt.title("Convergence Graph per parameter " + PROBLEM_FOLDER[i] + file)
            plt.legend()
            plt.savefig("plot/" + PROBLEM_FOLDER[i] + file + ".pdf")
            plt.clf()
