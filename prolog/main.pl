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
* buid_materialized_matrixes(+Routes, +N_Depots, +Service_Times, +Distances, -MaterializedDepots, -MaterializedCustomers, -TotalTimes)
*/
buid_materialized_matrixes([], _, _, _, [], [], []).
buid_materialized_matrixes([Route|Rest], N_Depots, Service_Times, Distances, [MaterializedDepot|MaterializedDepots], [MaterializedCustomer|MaterializedCustomers], [Times|TotalTimes]):-
  LeftDepot in 0..1,
  buid_materialized_matrixes_aux(Route, 1, N_Depots, Service_Times, Distances, LeftDepot, MaterializedDepot, MaterializedCustomer, Times),
  sum(MaterializedDepot, #=, LeftDepot),
  buid_materialized_matrixes(Rest, N_Depots, Service_Times, Distances, MaterializedDepots, MaterializedCustomers, TotalTimes).

/*
* Build materialized matrix row from route:
* buid_materialized_matrixes_aux(+Route, +Index, +N_Depots, +Service_Times, +Distances, +LeftDepot, -MaterializedDepot, -MaterializedCustomer, -TotalTimes)
*/
buid_materialized_matrixes_aux([], _, 0, _, _, _, [], [], []).
buid_materialized_matrixes_aux([Customer|Rest], Index, 0, Service_Times, Distances, LeftDepot, [], [MaterializedCustomer|MaterializedCustomers], [Time|TotalTimes]):-
  Customer #\= Index #<=> MaterializedCustomer,
  Multiplier #= MaterializedCustomer * LeftDepot,
  get_total_time(Index, Customer, Distances, Service_Times, Multiplier, Time),
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Rest, New_Index, 0, Service_Times, Distances, LeftDepot, [], MaterializedCustomers, TotalTimes).

buid_materialized_matrixes_aux([Depot|Rest], Index, N_Depots, Service_Times, Distances, LeftDepot, [MaterializedDepot|MaterializedDepots], MaterializedCustomers, [Time|TotalTimes]):-
  Depot #\= Index #<=> MaterializedDepot,
  Multiplier #= MaterializedDepot * LeftDepot,
  get_total_time(Index, Depot, Distances, Service_Times, Multiplier, Time),
  New_Depots is N_Depots - 1,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Rest, New_Index, New_Depots, Service_Times, Distances, LeftDepot, MaterializedDepots, MaterializedCustomers, TotalTimes).


/*
* Get total time between two nodes:
* get_total_time(+Index1, +Index2, +Distances, +Service_Times, +Multiplier, -TotalTime)
*/
get_total_time(Index1, Index2, Distances, Service_Times, Multiplier, TotalTime):-
  nth1(Index1, Distances, DistancesLine),
  element(Index2, DistancesLine, Distance),
  element(Index2, Service_Times, ST),
  TotalTime #= (Distance + ST) * Multiplier.


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

  calculate_distances_matrix(AllNodes, Distances),
  
  length(AllNodes, N_Routes),
  TotalVehicles is N_Vehicles * N_Depots,

  length(Routes, TotalVehicles),
  build_routes(Routes, N_Routes),
  buid_materialized_matrixes(Routes, N_Depots, Service_Times, Distances, MaterializedDepots, MaterializedCustomers, TotalTimes),

  transpose(MaterializedDepots, TransposedMaterializedDepots),
  transpose(MaterializedCustomers, TransposedMaterializedCustomers),

  length(LeftVehicles, N_Depots), domain(LeftVehicles, 0, N_Vehicles),
  sum_constraint(TransposedMaterializedDepots, LeftVehicles),
  sum_constraint(TransposedMaterializedCustomers, 1),
  
  append(Routes, FlatRoutes),
  append(TotalTimes, FlatTotalTimes),

  sum(FlatTotalTimes, #=, TotalTime),
  labeling([minimize(TotalTime)], FlatRoutes),
  write(Routes), nl,
  write(TotalTime), nl,
  write(Distances).

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