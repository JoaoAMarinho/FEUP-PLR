/*
* Get durations from a list of nodes:
* get_service_times(+All_Nodes, -Service_Times)
*/
get_service_times([], []).
get_service_times([node(_, _, _, Service_Time, _, _)|Rest], [Service_Time|Service_Times]):-
  get_service_times(Rest, Service_Times).

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
* Calculate distances matrix for all nodes:
* calculate_distances_matrix(+All_Nodes, -DistancesMatrix)
*/
calculate_distances_matrix(All_Nodes, Distances):-
  calculate_distances_matrix(All_Nodes, All_Nodes, Distances).

calculate_distances_matrix([], _, []).
calculate_distances_matrix([Node|Nodes], All_Nodes, [Distances_Line|Distances_Rest]):-
  calculate_distances_line(Node, All_Nodes, Distances_Line),
  calculate_distances_matrix(Nodes, All_Nodes, Distances_Rest).

/*
* Calculate distances line:
* calculate_distances_line(+Node, +All_Nodes, -Distances_Line)
*/
calculate_distances_line(_, [], []).
calculate_distances_line(Node1, [Node2|Nodes], [Distance|Distances]):-
  Node1 = node(_, X1, Y1, _, _, _),
  Node2 = node(_, X2, Y2, _, _, _),
  Distance is round((sqrt((X1-X2)^2 + (Y1-Y2)^2))/2),
  calculate_distances_line(Node1, Nodes, Distances).
