:- use_module(library(clpfd)).
:- use_module(library(lists)).

% 1. lazy_mailman(-C, -L)

lazy_mailman(C, L):-
  length(L, 10),
  domain(L, 1, 10),
  all_distinct(L),
  element(10, L, 6),
  sum_path(L, 0, C),
  labeling([maximize(C)], L).

sum_path([_], C, C).
sum_path([H1, H2|T], Acc, C):-
  Acc1 #= Acc + abs(H1 - H2),
  sum_path([H2|T], Acc1, C).

% 2. questions(+Valuations, +Times, +TotalTime, +MinGrade, -Right)

questions(Valuations, Times, TotalTime, MinGrade, Right):-
  length(Valuations, N),
  length(Right, N),
  domain(Right, 0, 1),
  scalar_product(Valuations, Right, #=, Grade),
  Grade #>= MinGrade,
  scalar_product(Times, Right, #=<, TotalTime),
  labeling([maximize(Grade)], Right).

% 3. loop(-Order, -Distance)

% coord(ID, Nome, X, Y).
coord(1, 'panel', 2, 4).
coord(2, 'sensor 1', 3, 3). coord(3, 'sensor 2', 6, 5).
coord(4, 'sensor 3', 5, 4). coord(5, 'sensor 4', 7, 7).

loop(Order, Distance):-
  length(Order, 5),
  domain(Order, 1, 5),
  all_distinct(Order),
  element(1, Order, 1),
  connections(Matrix, 1),
  append(Matrix, List),
  loop_constraint(List, Order, 0, Distance),
  labeling([minimize(Distance)], Order).

% Sum last connection distance
loop_constraint(List, [H], D, Distance):-
  Index #= (H-1) * 5 + 1,
  element(Index, List, D1),
  Distance #= D + D1.

% Recursively sum distance between two consecutive points
loop_constraint(List, [H1, H2|T], Acc, Distance):-
  Index #= (H1-1) * 5 + H2,
  element(Index, List, D),
  Acc1 #= Acc + D,
  loop_constraint(List, [H2|T], Acc1, Distance).

connections([], 6).
connections([L|T], I):-
  I1 is I + 1,
  distances(L, I, 1),
  connections(T, I1).

distances([], _, 6).
distances([D|T], I, J):-
  J1 is J + 1,
  coord(I, _, X1, Y1),
  coord(J, _, X2, Y2),
  D is round(sqrt((X1 - X2)^2 + (Y1 - Y2)^2)),
  distances(T, I, J1).

% 4. map_coloring(-Colors)
% Use nvalue

map_coloring(Colors):-
  Adjacent = [ 
    [1, 2], [1, 3], [2, 3], [2, 4], 
    [3, 4], [3, 5], [4, 5], [3, 6], [5, 6]
  ],
  length(Colors, 7),
  domain(Colors, 1, 5),
  map_constraint(Colors, Adjacent),
  maximum(Max, Colors),
  labeling([minimize(Max)], Colors).

map_constraint(_, []).
map_constraint(Colors, [[H1,H2]|T]):-
  map_constraint(Colors, T),
  element(H1, Colors, C1),
  element(H2, Colors, C2),
  C1 #\= C2.

% 5. bus_company(+Buses, +Groups, -Assignments)

bus_company(Buses, Groups, Assignments):-
  length(Groups, N),
  length(Assignments, N),
  length(Buses, M),
  domain(Assignments, 1, M),
  bus_bins(Buses, 1, Bins),
  group_items(Groups, Assignments, Items),
  bin_packing(Items, Bins),
  nvalue(X, Assignments),
  labeling([minimize(X)], Assignments).

bus_bins([], _, []).
bus_bins([H|T], ID, [bin(ID, Cap)|Bins]):-
  Cap in 0..H,
  ID1 is ID + 1,
  bus_bins(T, ID1, Bins).

group_items([], [], []).
group_items([H1|T1], [H2|T2], [item(H2, H1)|Items]):-
  group_items(T1, T2, Items).

% 6. golomb(+N, +Max, -Values)

golomb(N, Max, Values):-
  length(Values, N),
  domain(Values, 0, Max),
  all_distinct(Values),
  golomb_constraint(Values, [], Differences),
  all_distinct(Differences),
  labeling([], Values).

golomb_constraint([], Differences, Differences).
golomb_constraint([H|T], Acc, Differences):-
  get_differences(H, T, Acc, Acc1),
  golomb_constraint(T, Acc1, Differences).

get_differences(_, [], Acc, Acc).
get_differences(H, [H1|T], Acc, Differences):-
  H1 #> H,
  Diff #= abs(H - H1),
  get_differences(H, T, [Diff|Acc], Differences).

% 7. house_chores(-Chores)
% Chores = List with 1 for Steve, 2 for Stephanie and the index is the task
% Shopping Cooking Cleaning Vacuuming

get_chore_total_time([], [], []).
get_chore_total_time([H|T], [Steve|Times1], [Stephanie|Times2]):-
  get_chore_total_time(T, Times1, Times2),
  H #= 1 #<=> Steve,
  H #= 2 #<=> Stephanie.

house_chores(Chores):-
  Steve_time = [49, 72, 43, 31],
  Stephanie_time = [45, 78, 36, 29],
  length(Chores, 4),
  domain(Chores, 1, 2),
  global_cardinality(Chores, [1-2, 2-2]),
  get_chore_total_time(Chores, Steve_Chores, Stephanie_Chores),
  scalar_product(Steve_time, Steve_Chores, #=, T1),
  scalar_product(Stephanie_time, Stephanie_Chores, #=, T2),
  TotalTime #= T1 + T2,
  labeling(minimize(TotalTime), Chores).


% 8. movie_downloads(+Streaming_Services, +Movies_Duration, +Movies_Servers, -Schedule) Schedule = (Start_Time-End_Time-Server)
/*
Maximum of 3 movies at the same time

Example:

movie_downloads(5, [22,23,23,24,23,22], [[1,2,5],[1,2,5],[1,2,5],[1,3,4],[1,3,4],[1,3,4]], Schedule).
*/

movie_downloads(Streaming_Services, Movies_Duration, Movies_Servers, Tasks):-
  movie_tasks(Movies_Duration, Movies_Servers, Tasks, Servers, Ends),
  server_machines(1, Streaming_Services, Machines),
  maximum(End, Ends),
  cumulatives(Tasks, Machines),
  append(Servers, Ends, Vars),
  labeling([minimize(End)], Vars).

movie_tasks([], [], [], [], []).
movie_tasks([Duration|Durations], [Servers|List_Servers], [Task|Tasks], [Server|Servs], [End|Ends]):-
  list_to_fdset(Servers, FD_Set),
  Server in_set FD_Set,
  End #= Start + Duration,
  Start in 0..100,
  Task = task(Start, Duration, End, 1, Server),
  movie_tasks(Durations, List_Servers, Tasks, Servs, Ends).

server_machines(Total, Total, []).
server_machines(ID, Total, [Machine|Machines]):-
  Machine = machine(ID, 1),
  ID1 is ID + 1,
  server_machines(ID1, Total, Machines).

% 9.
