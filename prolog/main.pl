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

%%%THis is for mdvrp but is easy 
calc_time(_, [], _,Time, Time).
calc_time(mdvrp, [Route|RoutesT], DistanceMatrix, Accum, Time) :-
  calc_time_route(1, Route, DistanceMatrix, 0, TimeRoute),
  calc_time(mdvrp, RoutesT, DistanceMatrix, NewAccum, Time).

calc_time_route(_, [], _, Ret, Ret).
calc_time_route(Index, [Node|Route], DistanceMatrix, Accum, Ret) :-
  nth1(Index, DistanceMatrix, Distances_Line),
  element(Node, Distances_Line, Distance),
  NewAccum #= Accum + Distance,
  Index1 is Index + 1,
  calc_time_route(Index1, Route, DistanceMatrix, NewAccum, Ret).

%Not sure if the previous constraints worked -> these ones do if you want to replace
depot_constraints(_,_, _, N,N).
depot_constraints(Routes, MatRoutes, N_Vehicles, N_Depots, Depot) :-
  Depot1 is Depot + 1,
  depot_constraints_aux(Routes, MatRoutes,  0, N_Vehicles, N_Depots, Depot1, RoutesOfDepot),
  lex_chain(RoutesOfDepot),
  depot_constraints(Routes, MatRoutes, N_Vehicles, N_Depots, Depot1).

depot_constraints_aux(_,_, N_Vehicles, N_Vehicles, _, _ , []).
depot_constraints_aux(Routes, MatRoutes, VehicleIt, N_Vehicles, N_Depots, Depot, [Route | RoutesOfDepot]) :-
  VehicleIt1 is VehicleIt + 1,
  Iterator is VehicleIt1 * Depot,
  nth1(Iterator, Routes, Route),
  nth1(Iterator, MatRoutes, MatRoute),
  depot_constraints_apply(Route,MatRoute, N_Depots, Depot),
  depot_constraints_aux(Routes, MatRoutes, VehicleIt1, N_Vehicles, N_Depots, Depot, RoutesOfDepot).



depot_constraints_apply(_,_, 0, _).

depot_constraints_apply(Route,MatRoute, Depot, Depot) :- !,
  element(Depot, Route, FN),
  sum(MatRoute, #=, TV),
  FN #\= Depot #\/ TV #= 0,
  DepotIt1 is Depot - 1,
  depot_constraints_apply(Route, MatRoute, DepotIt1, Depot).

depot_constraints_apply(Route, MatRoute, DepotIt, Depot) :-
  element(DepotIt, Route, DV),
  DV #= DepotIt,
  DepotIt1 is DepotIt - 1,
  depot_constraints_apply(Route, MatRoute, DepotIt1, Depot).

client_constraints(_, N, N).

client_constraints(MatRoutes, N_Depots, Client) :-
  nth1(Client, MatRoutes, ClientRoute),
  sum(ClientRoute, #=, 1),
  Client1 is Client - 1,
  client_constraints(MatRoutes, N_Depots, Client1).

%Just re-did it because it was easier to do it than understande the previous hahahaha
build_mat_routes([], []).
build_mat_routes([Route |RouteT], [MatRoute | MatRouteT]) :-
  build_mat_line(Route,1, MatRoute),
  build_mat_routes(RouteT, MatRouteT).

build_mat_line([],_, []).
build_mat_line([N|Route], It, [B|MatT]) :-
  N #\= It #<=> B,
  It1 is It + 1,
  build_mat_line(Route, It1, MatT).

%NECESSARY FOR TW
%Create matrix that tells when it leaves.
create_end_times([],N_Routes, Max, N_Depots).
create_end_times([E|ET],N_Routes, Max, N_Depots) :-
  length(E, N_Routes),
  domain(E, 0, Max),
  depots_end(E, N_Depots),
  create_end_times(ET,N_Routes, Max, N_Depots).

%Make sure that depots leave at the begining??? maybe it is easier this way no??? not much of a change get rid of the max duration and just do it for the mdvrp
depots_end(_, 0).
depots_end(E, N_Depots) :-
  element(N_Depots, E, 0),
  Depots1 is N_Depots - 1,
  depots_end(E, Depots1).

%OUT FOR -> Calculates the Endtimes, the time of a route is then just the maximum end time plus the distance to the depot. must be careful with routes that do not leave plus how do i retrieve the index of the maximum???
%Maybe maximum not necessary iterate and if it points to depot then add distance
%I can actually calculate it Inside these functions on that part of the or where it finds the return actually nice lol
calc_time_tw([], [], _, _, _, _, _,_,[]).

calc_time_tw([R|RT], [MR|MRT], Distances, Service_Times, Open_Times, Close_Times,N_Depots, [ET|ETT], [TimeRoute|TimeTail]) :-
  calc_time_tw_route(R,MR, Distances, Service_Times, Open_Times, Close_Times,N_Depots, 1, ET, TimeRoute),
  sum(MR, #=,  MRSum),
  (MRSum #= 0 #/\ TimeRoute #= 0) #\/ (MRSum #\= 0),
  calc_time_tw(RT, MRT, Distances, Service_Times, Open_Times, Close_Times, N_Depots, ETT, TimeTail).

%INNER FOR
calc_time_tw_route([], [], _, _, _, _, _,_, _, _).
calc_time_tw_route([N|NT], [MN|MNT], Dist, ServTime, OpTime, ClTime, N_Depots, Index, ET, Time) :-
  nth1(Index, ET, NodeEndTime),
  nth1(Index, Dist, DistLine),
  element(N, DistLine, Distance),
  element(N, ClTime, NodeCloseTime),
  element(N, OpTime, NodeOpenTime),
  element(N, ET, NextNodeTime),
  element(N, ServTime, Service_Time),
  ToArrive #= NodeEndTime + Distance,
  maximum(NextNodeStartWork, [ToArrive, NodeOpenTime]),
  (MN #= 0 #/\ NodeEndTime #= 0) #\/ %not part of the route 
  (                                 
    NodeCloseTime #>= ToArrive #/\ % must arive before close
    NextNodeTime #= NextNodeStartWork + Service_Time  %compute leave time of nextnode

  ) #\/ (N #=< N_Depots #/\ Time #= NodeEndTime + Distance), %here we can calculate time T #= NodeEndTime + Distance
  Index1 is Index + 1,
  calc_time_tw_route(NT, MNT, Dist, ServTime, OpTime, ClTime,N_Depots, Index1, ET, Time).

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

  %buid_materialized_matrixes(Routes, N_Depots, Materialized_Depots, Materialized_Customers, Materialized_Routes),
  build_mat_routes(Routes, Materialized_Routes),
  depot_constraints(Routes, Materialized_Routes, N_Vehicles, N_Depots, 0),

  transpose(Materialized_Routes, Materialized_Routes_T),
  client_constraints(Materialized_Routes_T, N_Depots, N_Routes),

  %All problems
  %length(Left_Vehicles, N_Depots), domain(Left_Vehicles, 0, N_Vehicles),
  %sum_constraint(Transp_Materialized_Depots, Left_Vehicles),
  %sum_constraint(Transp_Materialized_Customers, 1),
  %This is okay now not sure if it was before

  %calc_time(Problem_Type, Routes,Distances, 0, Total_Time),
  %Create end times for list 
  length(End_Times, N_Total_Vehicles),
  %create_end_times(End_Times, MaxTime) <- what should be right now it is hardcoded
  create_end_times(End_Times,N_Routes, 1500, N_Depots),
  calc_time_tw(Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, N_Depots, End_Times, Total_Times),

  %time_constraints(Problem_Type, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, Start_Times, Wait_Times, Total_Times),

  sum(Total_Times, #=, Total_Time),

  append(Routes, Flat_Routes),
  append(End_Times, EndFlat),
  append(Flat_Routes, EndFlat, Vars),
  %append(Vars1, Total_Times, Vars),
  !,
  labeling([minimize(Total_Time)], Vars),
  write(End_Times), nl,
  write(Total_Times), nl.
  %calculate_time(Routes, Distances, Service_Times, Wait_Times, Time), write(Time).

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