
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
* Apply time constraints and get total times:
* time_constraints(+Problem_Type, +N_Depots, +Routes, +Materialized_Routes, +Distances, +Service_Times, +Open_Times, +Close_Times, +Leave_Times, -Total_Times)
*/
time_constraints(_, _, [], [], _, _, _, _, [], []).
time_constraints(Problem_Type, N_Depots, [Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, Open_Times, Close_Times, [Leave_Time|Leave_Times], [Total_Time|Total_Times]):-
  sum(Materialized_Route, #=, Total_Visited),
  (Total_Visited #= 0 #/\ Total_Time #= 0) #\/ (Total_Visited #\= 0),
  time_constraints_aux(Problem_Type, N_Depots, Route, Materialized_Route, Distances, Service_Times, Open_Times, Close_Times, 1, Leave_Time, Total_Time),
  time_constraints(Problem_Type, N_Depots, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, Leave_Times, Total_Times).

/*
* Apply time constraints for each route:
* time_constraints_aux(+Problem_Type, +N_Depots, +Route, +Materialized_Route, +Distances, +Service_Times, +Open_Times, +Close_Times, +Index, -Leave_Time, -Total_Time)
*/
time_constraints_aux(_, _, [], [], _, _, _, _, _, _, _).
time_constraints_aux(mdvrp, N_Depots, [Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, _, _, Index, Leave_Times, Total_Time):-
  nth1(Index, Distances, Distances_Line),
  element(Route, Distances_Line, Distance),
  element(Route, Service_Times, Service_Time),
  nth1(Index, Leave_Times, Leave_Time),
  element(Route, Leave_Times, Next_Leave_Time),

  Arrive_Time #= Leave_Time + Distance,

  (Materialized_Route #= 0 #/\ Leave_Time #= 0)   #\/      % not part of the route 
  (Next_Leave_Time #= Arrive_Time + Service_Time) #\/      % compute leave time of next node
  (Route #=< N_Depots #/\ Total_Time #= Arrive_Time),      % calculate total time

  New_Index is Index + 1,
  time_constraints_aux(mdvrp, N_Depots, Routes, Materialized_Routes, Distances, Service_Times, _, _, New_Index, Leave_Times, Total_Time).

time_constraints_aux(Problem_Type, N_Depots, [Route|Routes], [Materialized_Route|Materialized_Routes], Distances, Service_Times, Open_Times, Close_Times, Index, Leave_Times, Total_Time):-
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
    Close_Time #>= Arrive_Time #/\                             % must arrive before close time
    Next_Leave_Time #= Next_Start_Work + Service_Time       % compute leave time of next node

  ) #\/ (Route #=< N_Depots #/\ Total_Time #= Arrive_Time), % calculate total time

  New_Index is Index + 1,
  time_constraints_aux(Problem_Type, N_Depots, Routes, Materialized_Routes, Distances, Service_Times, Open_Times, Close_Times, New_Index, Leave_Times, Total_Time).
