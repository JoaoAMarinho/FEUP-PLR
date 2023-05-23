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
    
    def create_data_model(self):
        data = {}
        data['max_route_length'] = self.depots[0].max_duration
        data["distance_matrix"] = self.get_distance_matrix()
        data['num_vehicles'] = self.num_depots*self.num_vehicles
        data['starts'] = [i for i in range(self.num_depots)] * self.num_vehicles
        data['ends'] = data['starts']

        return data