from vrp import VRP

def parse_problem(file):
    vrp = VRP()

    with open(file) as infile:
        first_line = infile.readline().split(' ')
        print(first_line)
        vrp.num_vehicles = int(first_line[1])
        vrp.num_customers = int(first_line[2])
        vrp.num_depots = int(first_line[3])
        
    return vrp
