class Depot:
    def __init__(self, max_duration, max_load):
        self.max_duration = max_duration
        self.max_load = max_load
    
    def add_coords(self,x,y):
        self.x = x
        self.y = y