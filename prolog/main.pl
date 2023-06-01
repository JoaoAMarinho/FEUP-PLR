:- use_module(library(clpfd)).
:- use_module(library(lists)).

:- [file_parser].


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


/*
* Build list of vehicle routes:
* build_routes(-Routes, +N_Routes)
*/
build_routes([], _).
build_routes([Route|Routes], N_Routes):-
  length(Route, N_Routes),
  all_distinct(Route),
  subcircuit(Route),
  build_routes(Routes, N_Routes).


/*
* Build materialized matrixes from routes:
* buid_materialized_matrixes(+Routes, +N_Depots, -Materialized_Depots, -Materialized_Customers, -Materialized_Routes)
*/
buid_materialized_matrixes([], _, [], [], []).
buid_materialized_matrixes([Route|Routes], N_Depots, [Materialized_Depot|Materialized_Depots], [Materialized_Customer|Materialized_Customers], [Materialized_Route|Materialized_Routes]):-
  buid_materialized_matrixes_aux(Route, 1, N_Depots, Left_Depot, Materialized_Depot, Materialized_Customer, Materialized_Route),
  sum(Materialized_Depot, #=, Left_Depot),
  sum(Materialized_Customer, #=, N_Visited_Customers),
  N_Visited_Customers #> 0 #<=> Left_Depot,
  buid_materialized_matrixes(Routes, N_Depots, Materialized_Depots, Materialized_Customers, Materialized_Routes).

/*
* Build materialized matrix row from route:
* buid_materialized_matrixes_aux(+Route, +Index, +N_Depots, +Left_Depot, -Materialized_Depot, -Materialized_Customer, -Materialized_Route)
*/
buid_materialized_matrixes_aux([], _, 0, _, [], [], []).
buid_materialized_matrixes_aux([Customer|Customers], Index, 0, Left_Depot, [], [Materialized_Route|Materialized_Customers], [Materialized_Route|Materialized_Routes]):-
  Customer #\= Index #<=> Materialized_Customer,
  Materialized_Route #= Materialized_Customer * Left_Depot,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Customers, New_Index, 0, Left_Depot, [], Materialized_Customers, Materialized_Routes).

buid_materialized_matrixes_aux([Depot|Depots], Index, N_Depots, Left_Depot, [Materialized_Route|Materialized_Depots], Materialized_Customers, [Materialized_Route|Materialized_Routes]):-
  Depot #\= Index #<=> Materialized_Depot,
  Materialized_Route #= Materialized_Depot * Left_Depot,
  New_Depots is N_Depots - 1,
  New_Index is Index + 1,
  buid_materialized_matrixes_aux(Depots, New_Index, New_Depots, Left_Depot, Materialized_Depots, Materialized_Customers, Materialized_Routes).


/*
* Apply time constraints and get total times:
* time_constraints(+Problem_Type, +Routes, +Materialized_Routes, +Distances, +Service_Times, +Open_Times, +Close_Times, -Start_Times, -Wait_Times, -Total_Times)
*/
time_constraints(_, [], [], _, _, _, _, [], [], []).
time_constraints(Problem_Type, [Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, Open_Times, Close_Times, [Start_Time|Start_Times], [Wait_Time|Wait_Times], [Total_Time|Total_Times]):-
  get_start_time(Problem_Type, Start_Time),
  time_constraints_aux(Problem_Type, Route, Materialized_Route, 1, Distances, Service_Times, Open_Times, Close_Times, Start_Time, Wait_Time, Total_Time),
  time_constraints(Problem_Type, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, Start_Times, Wait_Times, Total_Times).

/*
* Get start time for a route:
* get_start_time(+Problem_Type, -Start_Time)
*/
get_start_time(mdvrp, 0).
get_start_time(vrptw, 0).
get_start_time(mdvrptw, 0):-
  Start_Time #>= 0.

/*
* Apply time constraints for a single route and get total time:
* time_constraints_aux(+Problem_Type, +Route, +Materialized_Route, Index, +Distances, +Service_Times, +Open_Times, +Close_Times, +Acc_Time, -Wait_Times, -Total_Time)
*/
time_constraints_aux(_, [], [], _, _, _, _, _, Acc_Time, [], Acc_Time).
time_constraints_aux(Problem_Type, [Route|Routes], [Materialized_Route|Materialized_Routes], Index, Distances, Service_Times, Open_Times, Close_Times, Acc_Time, [Wait_Time|Wait_Times], Total_Time):-
  New_Index is Index + 1,  
  element(Route, Service_Times, Service_Time),
  element(Route, Open_Times, Open_Time),
  element(Route, Close_Times, Close_Time),
  nth1(Index, Distances, Distances_Line),
  element(Route, Distances_Line, Distance),

  time_window_constraint(Problem_Type, Acc_Time, Distance, Open_Time, Close_Time, Wait_Time),

  New_Acc_Time #= Acc_Time + (Distance + Service_Time + Wait_Time) * Materialized_Route,
  time_constraints_aux(Problem_Type, Routes, Materialized_Routes, New_Index, Distances, Service_Times, Open_Times, Close_Times, New_Acc_Time, Wait_Times, Total_Time).

/*
* Apply time window constraint to extract a wait time:
* time_window_constraint(+Problem_Type, +Acc_Time, +Distance, +Open_Time, +Close_Time, -Wait_Time)
*/
time_window_constraint(mdvrp, _, _, _, _, _, 0):- !.
time_window_constraint(_, Acc_Time, Distance, Open_Time, Close_Time, Wait_Time):-
  Wait_Time #>= 0,
  Wait_Time #< 10000,
  Acc_Time + Distance + Wait_Time #=< Close_Time,
  Acc_Time + Distance + Wait_Time #>= Open_Time.

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


main(Routes, Total_Time):-
  parse_file(Problem_Type, N_Vehicles, N_Customers, N_Depots, Depots_Info, Depots, Customers),
  append(Depots, Customers, All_Nodes),
  get_service_times(All_Nodes, Service_Times),
  get_time_windows(Problem_Type, All_Nodes, Open_Times, Close_Times),

  calculate_distances_matrix(All_Nodes, Distances),
  
  length(All_Nodes, N_Routes),
  N_Total_Vehicles is N_Vehicles * N_Depots,

  length(Routes, N_Total_Vehicles),
  build_routes(Routes, N_Routes),
  lex_chain(Routes),
  buid_materialized_matrixes(Routes, N_Depots, Materialized_Depots, Materialized_Customers, Materialized_Routes),

  transpose(Materialized_Depots, Transp_Materialized_Depots),
  transpose(Materialized_Customers, Transp_Materialized_Customers),

  length(Left_Vehicles, N_Depots), domain(Left_Vehicles, 0, N_Vehicles),
  sum_constraint(Transp_Materialized_Depots, Left_Vehicles),
  sum_constraint(Transp_Materialized_Customers, 1),

  time_constraints(Problem_Type, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, Start_Times, Wait_Times, Total_Times),
  sum(Total_Times, #=, Total_Time),

  append(Routes, Flat_Routes),
  append(Wait_Times, Flat_Wait_Times),
  append(Flat_Routes, Flat_Wait_Times, Vars),

  labeling([minimize(Total_Time), time_out(30000, Flag)], Vars),
  write(Distances), nl,
  write(Flag), nl,
  calculate_time(Routes, Distances, Service_Times, Wait_Times, Time), write(Time).

calculate_time([], _, _, [], 0).
calculate_time([Route|Routes], Distances, Service_Times, [Wait_Time|Wait_Times], Time):-
  calculate_time_aux(Route, Distances, Service_Times, Wait_Time, 0, Route_Time, 1),
  calculate_time(Routes, Distances, Service_Times, Wait_Times, Rest_Time),
  Time is Route_Time + Rest_Time.

calculate_time_aux([], _, _, _, Acc_Time, Acc_Time, _).
calculate_time_aux([Node|Nodes], Distances, Service_Times, Wait_Time, Acc_Time, Time, Index):-
  New_Index is Index + 1,
  nth1(Node, Service_Times, Service_Time),
  nth1(Index, Distances, Distances_Line),
  nth1(Node, Distances_Line, Distance),
  nth1(Index, Wait_Time, Wait_Time_Node),
  get_multiplicator(Index, Node, Multiplicator),
  New_Acc_Time is Acc_Time + (Distance + Service_Time + Wait_Time_Node) * Multiplicator,
  calculate_time_aux(Nodes, Distances, Service_Times, Wait_Time, New_Acc_Time, Time, New_Index).

get_multiplicator(X, X, 0):- !.
get_multiplicator(_, _, 1).