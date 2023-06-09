import json
import matplotlib.pyplot as plt
from file_parser import parse_problem

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
    "most-const",
    "cheap-ins",
    "cheap-ins",
    "cheap-ins",
    "most-const",
    "cheap-ins",
    "cheap-ins",
    "auto",
    "cheap-arc"
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
                plt.plot(file_data[param]["time"], file_data[param]["cost"], label=param)
            
            plt.title("Convergence Graph per parameter " + PROBLEM_FOLDER[i] + file)
            plt.xlabel("Time (ms)")
            plt.ylabel("Cost")
            plt.legend()
            plt.savefig("plot/" + PROBLEM_FOLDER[i] + file + ".pdf")
            plt.clf()


    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append(vrp.num_depots + vrp.num_clients)
            time.append(file_data[BEST[i][id]]["time"][-1])
        plt.scatter(size, time)
        plt.xlabel("Clients + Depots")
        plt.ylabel("Time (ms)")
        plt.title("Time per Size " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "NODES.pdf")
        plt.clf()

    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append((vrp.num_clients + vrp.num_depots)/vrp.num_vehicles)
            time.append(file_data[BEST[i][id]]["time"][-1])
        size.sort()
        plt.scatter(size, time)
        plt.title("Time per (Client + Depot)/Vehicles ratio " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "RatioVehic.pdf")
        plt.clf()

    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append((vrp.num_clients / vrp.num_depots))
            time.append(file_data[BEST[i][id]]["time"][-1])
        size.sort()
        plt.scatter(size, time)
        plt.title("Time per Client/Depot ratio " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "Ratio.pdf")
        plt.clf()

    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append((vrp.num_clients + vrp.num_depots)/(vrp.num_vehicles + vrp.num_depots))
            time.append(file_data[BEST[i][id]]["time"][-1])
        size.sort()
        plt.scatter(size, time)
        plt.title("Time per Average Nodes visited per route " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "Avg.pdf")
        plt.clf()

    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append((vrp.num_clients + vrp.num_depots)/(vrp.num_vehicles + vrp.num_depots))
            time.append(file_data[BEST[i][id]]["time"][-1])
        size.sort()
        plt.scatter(size, time)
        plt.title("Time per Average Nodes visited per route " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "Avg.pdf")
        plt.clf()

    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append(vrp.num_depots)
            time.append(file_data[BEST[i][id]]["time"][-1])
        size.sort()
        plt.scatter(size, time)
        plt.title("Time per number of Depots " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "DEPS.pdf")
        plt.clf()

    for i in range(2): #Problem
        size = []
        time = []
        for id,file in enumerate(FILES[i]): #FILE
            with open(RESULT_PATH + PROBLEM_FOLDER[i] + file, "r") as outfile:
                file_data = json.load(outfile)
            vrp = parse_problem(DATA_PATH + PROBLEM_FOLDER[i] + file)
            size.append(file_data[BEST[i][id]]["cost"][-1] / (vrp.num_vehicles * vrp.num_depots))
            time.append(file_data[BEST[i][id]]["time"][-1])
        size.sort()
        plt.scatter(size, time)
        plt.title("Time per Avg Cost of Route " + PROBLEM_FOLDER[i][:-1])
        plt.savefig("plot/" + PROBLEM_FOLDER[i] + "SOL.pdf")
        plt.clf()
    

        
