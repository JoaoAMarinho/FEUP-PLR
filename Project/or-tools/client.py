class Client:
    def __init__(self, x, y, duration, demand):
        self.x = x
        self.y = y
        self.duration = duration
        self.demand = demand

    def add_time_window(self, start, end):
        self.start = start
        self.end = end