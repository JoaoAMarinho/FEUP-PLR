from vrp import VRP
from depot import Depot
from client import Client

def parse_problem(file):
    vrp = VRP()

    with open(file) as infile:
        first_line = infile.readline().split(' ')
        vrp.type = int(first_line[0])
        vrp.num_vehicles = int(first_line[1])
        vrp.num_clients = int(first_line[2])
        vrp.num_depots = int(first_line[3])
        
        for _ in range(vrp.num_depots):
            line = infile.readline().split(' ')
            depot = Depot(int(line[0]), int(line[1]))
            vrp.add_depot(depot)
        
        if vrp.type == 4:
            depot_line = infile.readline().split(' ')
            depot_line = list(filter(lambda e: e != '', depot_line))
            x = float(depot_line[1])
            y = float(depot_line[2])
            w_start = int(depot_line[-2])
            w_end = int(depot_line[-1])
            vrp.add_time_window(0, w_start, w_end)
            vrp.add_depot_coords(0, x, y)

        for _ in range(vrp.num_clients):
            #Ignoring frequency and possible combinations does not make sense
            client_line = infile.readline().split(' ') 
            client_line = list(filter(lambda e: e != '', client_line))

            x = float(client_line[1])
            y = float(client_line[2])
            duration = int(float((client_line[3])))
            demand = int(float((client_line[4])))

            client = Client(x,y,duration,demand)
            
            if vrp.type != 2:
                w_start = int(client_line[-2])
                w_end = int(client_line[-1])
                client.add_time_window(w_start, w_end)

            vrp.add_client(client)

        if vrp.type != 4:
            for i in range(vrp.num_depots):
                depot_line = infile.readline().split(' ')
                depot_line = list(filter(lambda e: e != '', depot_line))
                x = float(depot_line[1])
                y = float(depot_line[2])
                if vrp.type != 2:
                    w_start = int(depot_line[-2])
                    w_end = int(depot_line[-1])
                    vrp.add_time_window(i, w_start, w_end)
                vrp.add_depot_coords(i, x, y)


    return vrp
