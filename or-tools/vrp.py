class VRP : 
    def __init__(self):
        self.vehicles = []
        self.depots = []
        self.clients = []
        return

    def add_depot(self,depot):
        self.depots.append(depot)

    def add_depot_coords(self, depot_index, x, y):
        self.depots[depot_index].add_coords(x, y)

    def add_client(self, client):
        self.clients.append(client)