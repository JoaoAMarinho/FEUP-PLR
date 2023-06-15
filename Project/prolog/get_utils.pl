/*
* Get durations from a list of nodes:
* get_service_times(+All_Nodes, -Service_Times)
*/
get_service_times([], []).
get_service_times([node(_, _, _, Service_Time, _, _)|Rest], [Service_Time|Service_Times]):-
  get_service_times(Rest, Service_Times).


/*
* Get demands from a list of nodes:
* get_demands(+All_Nodes, -Demands)
*/
get_demands([], []).
get_demands([node(_, _, _, _, Demand, _)|Rest], [Demand|Demands]):-
  get_demands(Rest, Demands).


/*
* Get time windows from a list of nodes:
* get_time_windows(+Problem_Type, +All_Nodes, -Open_Times, -Close_Times)
*/
get_time_windows(_,[], [], []).
get_time_windows(mdvrp, [_|Rest], [0|Open_Times], [0|Close_Times]):-
  get_time_windows(mdvrp, Rest, Open_Times, Close_Times).
get_time_windows(Problem_Type, [node(_, _, _, _, _, Open-Close)|Rest], [Open|Open_Times], [Close|Close_Times]):-
  get_time_windows(Problem_Type, Rest, Open_Times, Close_Times).


/*
* Get max values from depot info list:
* get_depot_max_values(+Depots_Info, -Max_Duration, -Max_Demand)
*/
get_depot_max_values(Depots_Info, Max_Duration, Max_Demand):-
  get_depot_values(Depots_Info, Durations, Demands),
  maximum(Max_Duration, Durations),
  maximum(Max_Demand, Demands).

/*
* Get list of durations and demands from depot info list:
* get_depot_values(+Depots_Info, -Durations, -Demands)
*/
get_depot_values([], [], []).
get_depot_values([depot_info(Duration, Demand)|Rest], [Duration|Durations], [Demand|Demands]):-
  get_depot_values(Rest, Durations, Demands).


/*
* Get max route time according to problem type:
* get_max_route_time(+Problem_Type, +Max_Duration, +Max_Close_Time, -Max_Route_Time)
*/
get_max_route_time(mdvrp, Max_Route_Time, _, Max_Route_Time).
get_max_route_time(_, _, Max_Route_Time, Max_Route_Time).


/*
* Wrapper for calculating distances matrix:
* get_distances_matrix(+All_Nodes, -Distances_Matrix)
*/
get_distances_matrix(All_Nodes, Distances_Matrix):-
  get_distances_matrix(All_Nodes, All_Nodes, Distances_Matrix).

/*
* Calculate distances matrix for all nodes:
* get_distances_matrix(+Nodes, +All_Nodes, -Distances_Matrix)
*/
get_distances_matrix([], _, []).
get_distances_matrix([Node|Nodes], All_Nodes, [Distances_Line|Distances_Rest]):-
  get_distances_line(Node, All_Nodes, Distances_Line),
  get_distances_matrix(Nodes, All_Nodes, Distances_Rest).

/*
* Calculate distances line:
* get_distances_line(+Node, +All_Nodes, -Distances_Line)
*/
get_distances_line(_, [], []).
get_distances_line(Node1, [Node2|Nodes], [Distance|Distances]):-
  Node1 = node(_, X1, Y1, _, _, _),
  Node2 = node(_, X2, Y2, _, _, _),
  Distance is round((sqrt((X1-X2)^2 + (Y1-Y2)^2))/2),
  get_distances_line(Node1, Nodes, Distances).
