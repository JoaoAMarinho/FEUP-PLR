:-use_module(library(file_systems)).

:- [main].


/*
* Return a list of all files in the given directory:
* get_files(+Directory, -Files)
*/
get_files(Directory, Files) :-
  findall(File, file_member_of_directory(Directory, _, File), Files).


/*
* Return a list of all possible combinations of the following parameters:
* get_test_combinations(-Test_Combinations)
*/
get_test_combinations(Test_Combinations):-
  Variable_Ordering = [leftmost, min, max, ff, anti_first_fail, occurrence, ffc, max_regret, impact, dom_w_deg], % We can add random ordering
  Value_Selection = [step, enum, bisect, median, middle],  % We can add random selection
  Value_Ordering = [up, down],
  Time_Limits = [30000, 60000, 300000, 600000, 1200000], % 30 sec, 1 min, 5 min, 10 min, 20 min
  % We can add restart search scheme

  get_files('../data/mdvrp', MD_Files),
  get_files('../data/vrptw', TW_Files),
  get_files('../data/mdvrptw', MDTW_Files),
  append(MD_Files, TW_Files, Files),
  append(Files, MDTW_Files, All_Files),

  findall([F, X, Y, Z, W], 
    (
      member(F, All_Files),
      member(X, Variable_Ordering),
      member(Y, Value_Selection),
      member(Z, Value_Ordering),
      member(W, Time_Limits)
    ), Test_Combinations).


print_solution(Solution):-
  statistics(total_runtime,[_,T]),
  TS is ((T//10)*10)/1000, nl,
  write('Labeling Time: '), write(TS), write('s'), nl,
  Solution = [Routes, Total_Time, Flag],
  write('Flag: '), write(Flag), nl,
  print_routes(Routes, Flag),
  write('Total Time: '), write(Total_Time), nl.

print_routes(_, time_out):- !.
print_routes(Routes, _):- write('Routes: '), write(Routes), nl.


print_configuration(Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit):-
  write('Variable Ordering: '), write(Variable_Ordering), nl,
  write('Value Selection: '), write(Value_Selection), nl,
  write('Value Ordering: '), write(Value_Ordering), nl,
  write('Time Limit: '), write(Time_Limit), nl, nl.


test:-
  get_test_combinations(Test_Combinations),
  (
    foreach([File, Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit], Test_Combinations) do
    solve_problem(File, Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit, Solution),
    open('./results/test.txt', append, File_Stream),
    set_output(File_Stream),
    write(File), write(':'), nl,
    print_solution(Solution),
    print_configuration(Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit),
    close(File_Stream)
  ).


test_default:-
  get_files('../data/test', Files),
  (
    foreach(File, Files) do
    solve_problem(File, leftmost, step, up, 30000, Solution),
    print_solution(Solution)
  ).
