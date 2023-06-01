:- use_module(library(clpfd)).
:- use_module(library(lists)).

:- [file_parser].


/*
* Get durations from a list of nodes:
* get_service_times(+AllNodes, -Service_Times)
*/
get_service_times([], []).
get_service_times([node(_, _, _, ST, _)|Rest], [ST|Service_Times]):-
  get_service_times(Rest, Service_Times).

/*
* Get time windows from a list of nodes:
* get_time_windows(+Problem_Type, +AllNodes, -Open_Times, -Close_Times)
*/
get_time_windows(_,[], [], []).
get_time_windows(mdvrp, [_|Rest], [0|Open_Times], [0|Close_Times]):-
  get_time_windows(mdvrp, Rest, Open_Times, Close_Times).
get_time_windows(Problem_Type, [node(_, _, _, _, Open-Close)|Rest], [Open|Open_Times], [Close|Close_Times]):-
  get_time_windows(Problem_Type, Rest, Open_Times, Close_Times).


/*
* Calculate distances matrix:
* calculate_distances_matrix(+AllNodes, -DistancesMatrix)
*/
calculate_distances_matrix(AllNodes, Distances):-
  calculate_distances_matrix(AllNodes, AllNodes, Distances).

calculate_distances_matrix([], _, []).
calculate_distances_matrix([Node|T], AllNodes, [DLine|DRest]):-
  calculate_distances_line(Node, AllNodes, DLine),
  calculate_distances_matrix(T, AllNodes, DRest).  

/*
* Calculate distances line:
* calculate_distances_line(+Node, +AllNodes, -DistancesLine)
*/
calculate_distances_line(_, [], []).
calculate_distances_line(Node1, [Node2|T], [Distance|Distances]):-
  Node1 = node(_ID1, X1, Y1, _Dur1, _Window1),
  Node2 = node(_ID2, X2, Y2, _Dur2, _Window2),
  Distance is integer(sqrt((X1-X2)^2 + (Y1-Y2)^2)),
  calculate_distances_line(Node1, T, Distances).


/*
* Build list of vehicle routes:
* build_routes(-Routes, +N_Routes)
*/
build_routes([], _).
build_routes([Route|Rest], N_Routes):-
  length(Route, N_Routes),
  all_distinct(Route),
  subcircuit(Route),
  build_routes(Rest, N_Routes).


/*
* Build materialized matrixes from routes:
* buid_materialized_matrixes(+Routes, +N_Depots, -MaterializedDepots, -MaterializedCustomers, -MaterializedRoutes)
*/
buid_materialized_matrixes([], _, [], [], []).
buid_materialized_matrixes([Route|Rest], N_Depots, [MaterializedDepot|MaterializedDepots], [MaterializedCustomer|MaterializedCustomers], [MaterializedRoute|MaterializedRoutes]):-
  buid_materialized_matrixes_aux(Route, 1, N_Depots, LeftDepot, MaterializedDepot, MaterializedCustomer, MaterializedRoute),
  sum(MaterializedDepot, #=, LeftDepot),
  sum(MaterializedCustomer, #=, VisitedCustomers),
  VisitedCustomers #> 0 #<=> LeftDepot,
  buid_materialized_matrixes(Rest, N_Depots, MaterializedDepots, MaterializedCustomers, MaterializedRoutes).

/*
* Build materialized matrix row from route:
* buid_materialized_matrixes_aux(+Route, +Index, +N_Depots, +LeftDepot, -MaterializedDepot, -MaterializedCustomer, -MaterializedRoute)
*/
buid_materialized_matrixes_aux([], _, 0, _, [], [], []).
buid_materialized_matrixes_aux([Customer|Rest], Index, 0, LeftDepot, [], [MaterializedRoute|MaterializedCustomers], [MaterializedRoute|MaterializedRoutes]):-
  Customer #\= Index #<=> MaterializedCustomer,
  MaterializedRoute #= MaterializedCustomer * LeftDepot,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Rest, New_Index, 0, LeftDepot, [], MaterializedCustomers, MaterializedRoutes).

buid_materialized_matrixes_aux([Depot|Rest], Index, N_Depots, LeftDepot, [MaterializedRoute|MaterializedDepots], MaterializedCustomers, [MaterializedRoute|MaterializedRoutes]):-
  Depot #\= Index #<=> MaterializedDepot,
  MaterializedRoute #= MaterializedDepot * LeftDepot,
  New_Depots is N_Depots - 1,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Rest, New_Index, New_Depots, LeftDepot, MaterializedDepots, MaterializedCustomers, MaterializedRoutes).


/*
* Apply time constraints and get total times:
* time_constraints(+Problem_Type, +Routes, +MaterializedRoutes, +Distances, +Service_Times, +Open_Times, +Close_Times, -TotalTimes)
*/
time_constraints(_, [], [], _, _, _, _, []).
time_constraints(Problem_Type, [Route|Routes], [MaterializedRoute|MaterializedRoutes], Distances, Service_Times, Open_Times, Close_Times, [Time|TotalTimes]):-
  time_constraints_aux(Problem_Type, Route, MaterializedRoute, 1, Distances, Service_Times, Open_Times, Close_Times, 0, Time),
  time_constraints(Problem_Type, Routes, MaterializedRoutes, Distances, Service_Times, Open_Times, Close_Times, TotalTimes).

/*
* Apply time constraints for a single route and get total time:
* time_constraints_aux(+Problem_Type, +Route, +MaterializedRoute, Index, +Distances, +Service_Times, +Open_Times, +Close_Times, +Acc, -TotalTime)
*/
time_constraints_aux(_, [], [], _, _, _, _, _, Acc, Acc).
time_constraints_aux(Problem_Type, [Node|Route], [MaterializedNode|MaterializedRoute], Index, Distances, Service_Times, Open_Times, Close_Times, Acc, TotalTime):-
  New_Index is Index + 1,  
  element(Node, Service_Times, ST),
  element(Node, Open_Times, Open),
  element(Node, Close_Times, Close),
  nth1(Index, Distances, DistancesLine),
  element(Node, DistancesLine, Distance),

  can_go_to_next_node(Problem_Type, Acc, Distance, Open, Close, WaitTime, CanGoToNextNode),

  Multiplier #= CanGoToNextNode * MaterializedNode,
  Time #= Acc + (Distance + ST + WaitTime) * Multiplier,
  time_constraints_aux(Problem_Type, Route, MaterializedRoute, New_Index, Distances, Service_Times, Open_Times, Close_Times, Time, TotalTime).

/*
* can_go_to_next_node(+Problem_Type, +Acc, +Distance, +Open, +Close, -WaitTime, -CanGoToNextNode)
*/
can_go_to_next_node(mdvrp, _, _, _, _, 0, 1):- !.
can_go_to_next_node(_, Acc, Distance, Open, Close, WaitTime, CanGoToNextNode):-
  WaitTime #>= 0,
  Acc + Distance #=< Close #<=> CanGoToNextNode,
  Acc + Distance + WaitTime #>= Open #<=> CanGoToNextNode.


/*
* Applies a sum constraint to each row of a matrix:
* sum_constraint(+List, +N)
*/
sum_constraint([], _).
sum_constraint([List|Rest], [V|T]):-
  sum(List, #=, V),
  sum_constraint(Rest, T).
sum_constraint([List|Rest], N):-
  sum(List, #=, N),
  sum_constraint(Rest, N).


main(Routes, TotalTime):-
  parse_file(Problem_Type, N_Vehicles, N_Customers, N_Depots, Depots_Info, Depots, Customers),
  append(Depots, Customers, AllNodes),
  get_service_times(AllNodes, Service_Times),
  get_time_windows(Problem_Type, AllNodes, Open_Times, Close_Times),

  calculate_distances_matrix(AllNodes, Distances),
  
  length(AllNodes, N_Routes),
  TotalVehicles is N_Vehicles * N_Depots,

  length(Routes, TotalVehicles),
  build_routes(Routes, N_Routes),
  buid_materialized_matrixes(Routes, N_Depots, MaterializedDepots, MaterializedCustomers, MaterializedRoutes),

  transpose(MaterializedDepots, TransposedMaterializedDepots),
  transpose(MaterializedCustomers, TransposedMaterializedCustomers),

  length(LeftVehicles, N_Depots), domain(LeftVehicles, 0, N_Vehicles),
  sum_constraint(TransposedMaterializedDepots, LeftVehicles),
  sum_constraint(TransposedMaterializedCustomers, 1),

  time_constraints(Problem_Type, Routes, MaterializedRoutes, Distances, Service_Times, Open_Times, Close_Times, TotalTimes),

  append(Routes, FlatRoutes),
  sum(TotalTimes, #=, TotalTime),

  labeling([minimize(TotalTime)], FlatRoutes).

  %write(Routes), nl,
  %write(TotalTime), nl,
  %write(Distances).

vehicle_routes([], []).
vehicle_routes([Route|Rest], [Vehicle_Route|Vehicles]):-
  vehicle_route(Route, 1, Vehicle_Route),
  vehicle_routes(Rest, Vehicles).

vehicle_route([], _, []).
vehicle_route([Pos|Rest], Index, Res):-
  Pos = Index,
  New_Index is Index + 1,
  vehicle_route(Rest, New_Index, Res).
vehicle_route([Pos|Rest], Index, [Pos|Res]):-
  Pos \= Index,
  New_Index is Index + 1,
  vehicle_route(Rest, New_Index, Res).