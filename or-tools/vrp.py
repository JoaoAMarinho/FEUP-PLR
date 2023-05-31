import math

class VRP : 
    def __init__(self):
        self.depots = []
        self.clients = []
        return

    def add_depot(self,depot):
        self.depots.append(depot)

    def add_depot_coords(self, depot_index, x, y):
        self.depots[depot_index].add_coords(x, y)

    def add_time_window(self, depot_index, w_start, w_end):
        self.depots[depot_index].add_time_window(w_start, w_end)

    def add_client(self, client):
        self.clients.append(client)

    def get_distance_matrix(self):
        matrix = []
        for loc1 in self.depots + self.clients:
            line = []
            for loc2 in self.depots + self.clients:
                line.append(round(math.sqrt((loc1.x - loc2.x)**2 + (loc1.y - loc2.y)**2)))
            matrix.append(line)
        return matrix
    
    def get_demands(self):
        return [0] * self.num_depots + [x.demand for x in self.clients]
    
    def create_data_model(self):
        data = {}
        data['max_route_length'] = self.depots[0].max_duration
        data["distance_matrix"] = self.get_distance_matrix()
        data['num_vehicles'] = self.num_depots*self.num_vehicles
        data['demands'] = self.get_demands()
        data['vehicle_capacities'] = [x.max_load for x in self.depots] * self.num_vehicles
        data['starts'] = [i for i in range(self.num_depots)] * self.num_vehicles
        data['ends'] = data['starts']

        if self.type != 2:
            data["time_windows"] = [
                (x.start, x.end) for x in self.depots + self.clients
            ]

        return data