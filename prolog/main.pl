:- use_module(library(clpfd)).
:- use_module(library(lists)).

:- [file_parser].


/*
* Calculate distances matrix:
* calculate_distances_matrix(+Customers, +Customers, +Depots, -DistancesMatrix)
*/
calculate_distances_matrix([], _, _, []).
calculate_distances_matrix([Customer|T], Customers, Depots, [DLine|DRest]):-
  calculate_distances_line(Customer, Customers, Depots, DLine),
  calculate_distances_matrix(T, Customers, Depots, DRest).

/*
* Calculate distances line:
* calculate_distances_line(+Customer, +Customers, +Depots, -DistancesLine)
*/
calculate_distances_line(_, [], [], []).
calculate_distances_line(Customer1, [], [Depot|T], [D|Distances]):-
  Customer1 = customer(ID1, X1, Y1, _Dur1, _Window1),
  Depot = depot(ID2, X2, Y2),
  D is integer(sqrt((X1-X2)^2 + (Y1-Y2)^2)),
  calculate_distances_line(Customer1, [], T, Distances).
calculate_distances_line(Customer1, [Customer2|T], Depots, [D|Distances]):-
  Customer1 = customer(ID1, X1, Y1, _Dur1, _Window1),
  Customer2 = customer(ID2, X2, Y2, _Dur2, _Window2),
  D is integer(sqrt((X1-X2)^2 + (Y1-Y2)^2)),
  calculate_distances_line(Customer1, T, Depots, Distances).


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
* buid_materialized_matrixes(+Routes, +N_Depots, -MaterializedDepots, -MaterializedCustomers)
*/
buid_materialized_matrixes([], _, [], []).
buid_materialized_matrixes([Route|Rest], N_Depots, [MaterializedDepot|MaterializedDepots], [MaterializedCustomer|MaterializedCustomers]):-
  buid_materialized_matrixes_aux(Route, 1, N_Depots, MaterializedDepot, MaterializedCustomer),
  sum(MaterializedDepot, #=, 1),
  buid_materialized_matrixes(Rest, N_Depots, MaterializedDepots, MaterializedCustomers).

/*
* Build materialized matrix row from route:
* buid_materialized_matrixes_aux(+Route, +Index, +N_Depots, -MaterializedDepot, -MaterializedCustomer)
*/
buid_materialized_matrixes_aux([], _, 0, [], []).
buid_materialized_matrixes_aux([Customer|Rest], Index, 0, [], [MaterializedCustomer|MaterializedCustomers]):-
  Customer #\= Index #<=> MaterializedCustomer,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Rest, New_Index, 0, [], MaterializedCustomers).

buid_materialized_matrixes_aux([Depot|Rest], Index, N_Depots, [MaterializedDepot|MaterializedDepots], MaterializedCustomers):-
  Depot #\= Index #<=> MaterializedDepot,
  New_Depots is N_Depots - 1,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Rest, New_Index, New_Depots, MaterializedDepots, MaterializedCustomers).


/*
* Applies a sum constraint to each row of a matrix:
* sum_constraint(+List, +N)
*/
sum_constraint([], _).
sum_constraint([List|Rest], N):-
  sum(List, #=, N),
  sum_constraint(Rest, N).


main(Routes):-
  parse_file(Problem_Type, N_Vehicles, N_Customers, N_Depots, Depots_Info, Depots, Customers),
  calculate_distances_matrix(Customers, Customers, Depots, Distances),
  
  N_Routes is N_Customers + N_Depots,
  TotalVehicles is N_Vehicles * N_Depots,

  length(Routes, TotalVehicles),
  build_routes(Routes, N_Routes),
  
  buid_materialized_matrixes(Routes, N_Depots, MaterializedDepots, MaterializedCustomers),

  transpose(MaterializedDepots, TransposedMaterializedDepots),
  transpose(MaterializedCustomers, TransposedMaterializedCustomers),

  sum_constraint(TransposedMaterializedDepots, N_Vehicles),
  sum_constraint(TransposedMaterializedCustomers, 1),
  
  append(Routes, FlatRoutes),
  labeling([], FlatRoutes),
  write(Routes), nl,
  vehicle_routes(Routes, Solution).

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