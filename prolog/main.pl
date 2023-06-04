:- use_module(library(clpfd)).
:- use_module(library(lists)).

:- [file_parser].
:- [get_utils].
:- [specific_constraints].


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
* Build materialized matrix routes:
* build_materialized_routes(+Routes, +N_Depots, -Materialized_Customers, -Materialized_Routes)
*/
build_materialized_routes([], _, [], []).
build_materialized_routes([Route|Routes], N_Depots, [Materialized_Customer|Materialized_Customers], [Materialized_Route|Materialized_Routes]):-
  build_materialized_routes_aux(Route, 1, N_Depots, Materialized_Customer, Materialized_Route),
  build_materialized_routes(Routes, N_Depots, Materialized_Customers, Materialized_Routes).

/*
* Build materialized route list:
* build_materialized_routes_aux(+Route, +Index, +N_Depots, -Materialized_Customer, -Materialized_Route)
*/
build_materialized_routes_aux([], _, _, [], []).
build_materialized_routes_aux([Node|Nodes], Index, 0, [Materialized_Route|Materialized_Customers], [Materialized_Route|Materialized_Routes]):-
  Node #\= Index #<=> Materialized_Route,
  New_Index is Index + 1,
  build_materialized_routes_aux(Nodes, New_Index, 0, Materialized_Customers, Materialized_Routes).
build_materialized_routes_aux([Node|Nodes], Index, N_Depots, Materialized_Customers, [Materialized_Route|Materialized_Routes]):-
  Node #\= Index #<=> Materialized_Route,
  New_Index is Index + 1,
  New_N_Depots is N_Depots - 1,
  build_materialized_routes_aux(Nodes, New_Index, New_N_Depots, Materialized_Customers, Materialized_Routes).


/*
* Build list of leave times for each vehicle route:
* build_leave_times(+N_Depots, +N_Routes, +Max_Leave_Time, +Leave_Times)
*/
build_leave_times(_,_, _, []).
build_leave_times(N_Depots, N_Routes, Max_Leave_Time, [Leave_Time|Leave_Times]) :-
  length(Leave_Time, N_Routes),
  domain(Leave_Time, 0, Max_Leave_Time),
  build_leave_times_aux(Leave_Time, N_Depots),
  build_leave_times(N_Depots, N_Routes, Max_Leave_Time, Leave_Times).

/*
* Impose initial leave time for depots:
* build_leave_times_aux(+N_Depots, +Leave_Time)
*/
build_leave_times_aux(_, 0).
build_leave_times_aux(Leave_Time, N_Depots):-
  element(N_Depots, Leave_Time, 0),
  New_N_Depots is N_Depots - 1,
  build_leave_times_aux(Leave_Time, New_N_Depots).


main(Routes, Total_Time):-
  parse_file(Problem_Type, N_Vehicles, N_Depots, Depots_Info, Depots, Customers),
  append(Depots, Customers, All_Nodes),
  get_service_times(All_Nodes, Service_Times),
  get_time_windows(Problem_Type, All_Nodes, Open_Times, Close_Times),

  get_depot_max_duration(Depots_Info, Max_Duration),
  maximum(Max_Close_Time, Close_Times),
  get_max_leave_time(Problem_Type, Max_Duration, Max_Close_Time, Max_Leave_Time),

  calculate_distances_matrix(All_Nodes, Distances),
  
  length(All_Nodes, N_Routes),
  N_Total_Vehicles is N_Vehicles * N_Depots,
  length(Routes, N_Total_Vehicles),
  build_routes(Routes, N_Routes),

  build_materialized_routes(Routes, N_Depots, Materialized_Customers, Materialized_Routes),

  depot_constraints(Routes, Materialized_Routes, N_Vehicles, N_Depots, 0),
  customer_constraints(Materialized_Customers),

  length(Leave_Times, N_Total_Vehicles),
  build_leave_times(N_Depots, N_Routes, Max_Leave_Time, Leave_Times),

  time_constraints(Problem_Type, N_Depots, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, Leave_Times, Total_Times),
  sum(Total_Times, #=, Total_Time),

  append(Routes, Flat_Routes),
  append(Leave_Times, Flat_Leave_Times),
  append(Flat_Routes, Flat_Leave_Times, Vars), !,

  labeling([minimize(Total_Time), time_out(30000, Flag)], Vars),
  write(Flag), nl.