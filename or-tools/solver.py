from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp

def print_solution(data, manager, routing, solution):
    """Prints solution on console."""
    print(f'Objective: {solution.ObjectiveValue()}')
    max_route_distance = 0
    total_route_distance = 0 
    for vehicle_id in range(data['num_vehicles']):
        index = routing.Start(vehicle_id)
        plan_output = 'Route for vehicle {}:\n'.format(vehicle_id)
        route_load = 0 
        route_distance = 0
        while not routing.IsEnd(index):
            plan_output += ' {} -> '.format(manager.IndexToNode(index))
            route_load += data['demands'][manager.IndexToNode(index)]
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(
                previous_index, index, vehicle_id)
        plan_output += '{}\n'.format(manager.IndexToNode(index))
        plan_output += 'Distance of the route: {}m\n'.format(route_distance)
        plan_output += 'Load of the route: {}/{}\n'.format(route_load, data['vehicle_capacities'][vehicle_id])
        print(plan_output)
        total_route_distance += route_distance
        max_route_distance = max(route_distance, max_route_distance)
    print('Maximum of the route distances: {}m\nTotal route distance {}'.format(max_route_distance, total_route_distance))

def print_solution_time(data, manager, routing, solution):
    """Prints solution on console."""
    print(f'Objective: {solution.ObjectiveValue()}')
    time_dimension = routing.GetDimensionOrDie('Distance')
    total_time = 0
    for vehicle_id in range(data['num_vehicles']):
        route_load = 0 
        index = routing.Start(vehicle_id)
        plan_output = 'Route for vehicle {}:\n'.format(vehicle_id)
        while not routing.IsEnd(index):
            time_var = time_dimension.CumulVar(index)
            route_load += data['demands'][manager.IndexToNode(index)]
            plan_output += '{0} Time({1},{2}) -> '.format(
                manager.IndexToNode(index), solution.Min(time_var),
                solution.Max(time_var))
            index = solution.Value(routing.NextVar(index))
        time_var = time_dimension.CumulVar(index)
        plan_output += '{0} Time({1},{2})\n'.format(manager.IndexToNode(index),
                                                    solution.Min(time_var),
                                                    solution.Max(time_var))
        plan_output += 'Time of the route: {}min\n'.format(
            solution.Min(time_var))
        plan_output += 'Load of the route: {}/{}\n'.format(route_load, data['vehicle_capacities'][vehicle_id])
        print(plan_output)
        total_time += solution.Min(time_var)
    print('Total time of all routes: {}min'.format(total_time))

def solve(vrp):
    """Simple Vehicles Routing Problem."""
    """Entry point of the program."""
    # Instantiate the data problem.
    # [START data]
    data = vrp.create_data_model()
    # [END data]

    # Create the routing index manager.
    # [START index_manager]
    manager = pywrapcp.RoutingIndexManager(len(data['distance_matrix']),
                                           data['num_vehicles'], data['starts'],
                                           data['ends'])
    print(data['num_vehicles'], data['starts'], data['ends'])
    print(data['max_route_length'])
    # [END index_manager]
    # Create Routing Model.
    routing = pywrapcp.RoutingModel(manager)

    # Create and register a transit callback.
    # [START transit_callback]

    def distance_callback(from_index, to_index):
        """Returns the distance between the two nodes."""
        # Convert from routing variable Index to distance matrix NodeIndex.
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)

        return data['distance_matrix'][from_node][to_node]//2 + data["service_time"][from_node]

    transit_callback_index = routing.RegisterTransitCallback(distance_callback)
    # [END transit_callback]

    # Define cost of each arc.
    # [START arc_cost]
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)
    # [END arc_cost]

    # Add Distance constraint.
    # [START distance_constraint]
    max_length = data['max_route_length'] if vrp.type == 2 else data['time_windows'][0][1] #window close of depot
    dimension_name = 'Distance'
    routing.AddDimension(
        transit_callback_index,
        max_length,  # allow slack time of max_length
        max_length, 
        False,  # start cumul to zero
        dimension_name)
    # [END distance_constraint]

    # Capacitated
    def demand_callback(from_index):
        """Returns the demand of the node."""
        # Convert from routing variable Index to demands NodeIndex.
        from_node = manager.IndexToNode(from_index)
        return data['demands'][from_node]

    demand_callback_index = routing.RegisterUnaryTransitCallback(demand_callback)
    routing.AddDimensionWithVehicleCapacity(
        demand_callback_index,
        0,  # null capacity slack
        data['vehicle_capacities'],  # vehicle maximum capacities
        True,  # start cumul to zero
        'Capacity')

    if vrp.type != 2:
        time_dimension = routing.GetDimensionOrDie(dimension_name)
        # Add time window constraints for each location except depot.
        for location_idx, time_window in enumerate(data['time_windows']):
            if location_idx in data['starts']:
                continue
            index = manager.NodeToIndex(location_idx)
            time_dimension.CumulVar(index).SetRange(time_window[0], time_window[1])
        # Add time window constraints for each vehicle start node.
        for vehicle_id in range(data['num_vehicles']):
            index = routing.Start(vehicle_id)
            time_dimension.CumulVar(index).SetRange(
                data['time_windows'][data['starts'][vehicle_id]][0],
                data['time_windows'][data['starts'][vehicle_id]][1])

        # Instantiate route start and end times to produce feasible times.
        for i in range(data['num_vehicles']):
            routing.AddVariableMinimizedByFinalizer(
                time_dimension.CumulVar(routing.Start(i)))
            routing.AddVariableMinimizedByFinalizer(
                time_dimension.CumulVar(routing.End(i)))


    # Setting first solution heuristic.
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC)

    routing.CloseModelWithParameters(search_parameters)

    collector = routing.solver().AllSolutionCollector()
    collector.AddObjective(routing.CostVar())
    routing.AddSearchMonitor(collector)

    # Solve the problem.
    solution = routing.SolveWithParameters(search_parameters)

    # Print solution on console.
    if solution:
        if vrp.type == 2:
            print_solution(data, manager, routing, solution)
        else:
            print_solution_time(data, manager, routing, solution)
    else:
        print("NO SOLUTION")

    result = {}
    result["time"] = []
    result["cost"] = []
    for i in range(collector.SolutionCount()):
        result["time"].append(collector.WallTime(i))
        result["cost"].append(collector.Solution(i).ObjectiveValue())
    
    return result
