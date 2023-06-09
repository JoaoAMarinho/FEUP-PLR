/*
* Order routes by depot and order routes inside each depot:
* depot_constraints(+Routes, +Materialized_Routes, +N_Vehicles, +N_Depots, +Depot)
*/
depot_constraints(_, _, _, Depot, Depot).
depot_constraints(Routes, Materialized_Routes, N_Vehicles, N_Depots, Depot):-
  New_Depot is Depot + 1,
  depot_constraints_aux(Routes, Materialized_Routes, 0, N_Vehicles, N_Depots, New_Depot, Routes_Per_Depot),
  lex_chain(Routes_Per_Depot),
  depot_constraints(Routes, Materialized_Routes, N_Vehicles, N_Depots, New_Depot).

/*
* Iterate through each depot routes (equal to number of vehicles) and apply depot constraints:
* depot_constraints_aux(+Routes, +Materialized_Routes, +Vehicle_Index, +N_Vehicles, +N_Depots, +Depot, -Routes_Per_Depot)
*/
depot_constraints_aux(_, _, N_Vehicles, N_Vehicles, _, _, []).
depot_constraints_aux(Routes, Materialized_Routes, Vehicle_Index, N_Vehicles, N_Depots, Depot, [Route|Routes_Per_Depot]):-
  New_Vehicle_Index is Vehicle_Index + 1,
  Index is N_Vehicles * (Depot-1) + New_Vehicle_Index,
  nth1(Index, Routes, Route),
  nth1(Index, Materialized_Routes, Materialized_Route),
  depot_constraints_apply(Route, Materialized_Route, Depot, N_Depots),
  depot_constraints_aux(Routes, Materialized_Routes, New_Vehicle_Index, N_Vehicles, N_Depots, Depot, Routes_Per_Depot).

/*
* Imposing leaving depot constraint:
* depot_constraints_apply(+Route, +Materialized_Route, +Depot, +Depot_It)
*/
depot_constraints_apply(_, _, _, 0):- !.
depot_constraints_apply(Route, Materialized_Route, Depot, Depot):- !,
  element(Depot, Route, Next_Node),
  sum(Materialized_Route, #=, Total_Visited),
  Total_Visited #= 0 #\/ Next_Node #\= Depot,
  New_Depot_It is Depot - 1,
  depot_constraints_apply(Route, Materialized_Route, Depot, New_Depot_It).
depot_constraints_apply(Route, Materialized_Route, Depot, Depot_It):-
  element(Depot_It, Route, Depot_It),
  New_Depot_It is Depot_It - 1,
  depot_constraints_apply(Route, Materialized_Route, Depot, New_Depot_It).


/*
* Wrapper for applying customer constraints:
* customer_constraints(+Materialized_Customers)
*/
customer_constraints(Materialized_Customers):-
  transpose(Materialized_Customers, Transp_Materialized_Customers),
  customer_constraints_apply(Transp_Materialized_Customers).

/*
* Apply customer constraints, each customer can only be visited once:
* customer_constraints_apply(+Materialized_Customers)
*/
customer_constraints_apply([]).
customer_constraints_apply([Materialized_Customer|Materialized_Customers]):-
  sum(Materialized_Customer, #=, 1),
  customer_constraints_apply(Materialized_Customers).


/*
* Demand constraints:
* demand_constraints(+Materialized_Routes, +Demands, +Max_Demand)
*/
demand_constraints([], _, _).
demand_constraints([Materialized_Route|Materialized_Routes], Demands, Max_Demand):-
  scalar_product(Demands, Materialized_Route, #=<, Max_Demand),
  demand_constraints(Materialized_Routes, Demands, Max_Demand).


/*
* Apply time window constraints:
* time_constraints(+Problem_Type, +N_Depots, +Routes, +Materialized_Routes, +Distances, +Service_Times, +Open_Times, +Close_Times, +Leave_Times)
*/
time_window_constraints(_, _, [], [], _, _, _, _, []).
time_window_constraints(mdvrp, _, _, _, _, _, _, _, _):- !.
time_window_constraints(Problem_Type, N_Depots, [Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, Open_Times, Close_Times, [Route_Leave_Times|Leave_Times]):-
  time_window_constraints_aux(N_Depots, Route, Materialized_Route, Distances, Service_Times, Open_Times, Close_Times, 1, Route_Leave_Times),
  time_window_constraints(Problem_Type, N_Depots, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, Leave_Times).

/*
* Apply time window constraints for each route:
* time_window_constraints_aux(+N_Depots, +Route, +Materialized_Route, +Distances, +Service_Times, +Open_Times, +Close_Times, +Index, +Leave_Times)
*/
time_window_constraints_aux(_, [], [], _, _, _, _, _, _).
time_window_constraints_aux(N_Depots, [Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, Open_Times, Close_Times, Index, Leave_Times):-
  nth1(Index, Distances, Distances_Line),
  element(Route, Distances_Line, Distance),
  element(Route, Service_Times, Service_Time),
  element(Route, Open_Times, Open_Time),
  element(Route, Close_Times, Close_Time),
  nth1(Index, Leave_Times, Leave_Time),
  element(Route, Leave_Times, Next_Leave_Time),

  Arrive_Time #= Leave_Time + Distance,
  maximum(Next_Start_Work, [Arrive_Time, Open_Time]),

  (Materialized_Route #= 0 #/\ Leave_Time #= 0) #\/         % not part of the route 
  (                                 
    Close_Time #>= Arrive_Time #/\                          % must arrive before close time
    Next_Leave_Time #= Next_Start_Work + Service_Time       % compute leave time of next node

  ) #\/ (Route #=< N_Depots),                               % so that the depot is not updated twice

  New_Index is Index + 1,
  time_window_constraints_aux(N_Depots, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, New_Index, Leave_Times).


/*
* Apply total time constraints and compute total time for each route:
* total_time_constraints(+Routes, +Materialized_Routes, +Max_Route_Time, +Distances, +Service_Times, +Total_Times)
*/
total_time_constraints([], [], _, _, _, []).
total_time_constraints([Route|Routes], [Materialized_Route|Materialized_Routes], Max_Route_Time, Distances, Service_Times, [Total_Time|Total_Times]):-
  sum(Materialized_Route, #=, Total_Visited),
  (Total_Visited #= 0 #/\ Total_Time #= 0) #\/ (Total_Visited #\= 0),
  total_time_constraints_aux(Route, Materialized_Route, Distances, Service_Times, 1, Total_Time),
  Total_Time #=< Max_Route_Time,
  total_time_constraints(Routes, Materialized_Routes, Max_Route_Time, Distances, Service_Times, Total_Times).

/*
* Compute route total time:
* total_time_constraints_aux(+Route, +Materialized_Routes, +Distances, +Service_Times, +Index, -Total_Time)
*/
total_time_constraints_aux([], [], _, _, _, 0).
total_time_constraints_aux([Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, Index, Next_Total_Time):-
  nth1(Index, Distances, Distances_Line),
  element(Route, Distances_Line, Distance),
  element(Route, Service_Times, Service_Time),
  
  New_Index is Index + 1,
  total_time_constraints_aux(Routes, Materialized_Routes, Distances, Service_Times, New_Index, Total_Time),
  Next_Total_Time #= Total_Time + (Distance + Service_Time) * Materialized_Route.
