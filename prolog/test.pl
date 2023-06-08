:-use_module(library(file_systems)).
:-use_module(library(random)).

:- [solver].


/*
* Return a list of all files in the given directory:
* get_files(+Directory, -Files)
*/
get_files(Directory, Files) :-
  findall(File, file_member_of_directory(Directory, _, File), Files).


/*
* Random variable ordering:
* random_variable_ordering(ListOfVars, Var, Rest)
*/
random_variable_ordering(ListOfVars, Var, Rest):-
  random_select(Var, ListOfVars, Rest).

/*
* Random value selection:
* random_value_selection(Var, Rest, BB0, BB1)
*/
random_value_selection(Var, Rest, BB0, BB1):-
  fd_set(Var, Set), fdset_to_list(Set, List),
  random_member(Value, List),
  ( first_bound(BB0, BB1), Var #= Value ;
  later_bound(BB0, BB1), Var #\= Value ).


/*
* Return a list of all possible combinations of the following parameters:
* get_test_combinations(-Test_Combinations)
*/
get_test_combinations(Test_Combinations):-
  Variable_Ordering = [leftmost, ffc],  % Other values: [min, max, ff, anti_first_fail, occurrence, max_regret, impact, dom_w_deg, variable(random_variable_ordering)],
  Value_Selection = [step, bisect],     % Other values: [enum , median, middle, value(random_value_selection)],
  Value_Ordering = [up, down],
  Time_Limits = [30000, 60000, 300000, 600000, 1200000], % 30 sec, 1 min, 5 min, 10 min, 20 min

  %get_files('../data/mdvrp', MD_Files),
  %get_files('../data/vrptw', TW_Files),
  %get_files('../data/mdvrptw', MDTW_Files),
  %append(MD_Files, TW_Files, Files),
  %append(Files, MDTW_Files, All_Files),
  All_Files = ['../data/vrptw/c100','../data/vrptw/c101','../data/vrptw/c102', '../data/vrptw/c103',
               '../data/vrptw/c104', '../data/vrptw/c105'],

  findall([F, X, Y, Z, W], 
    (
      member(F, All_Files),
      member(X, Variable_Ordering),
      member(Y, Value_Selection),
      member(Z, Value_Ordering),
      member(W, Time_Limits)
    ), Test_Combinations).


print_solution([_, _, time_out]):-
  write('Flag: '), write(time_out), nl,
  print_labeling_time.
print_solution([Routes, Total_Time, Flag]):-
  print_labeling_time,
  write('Flag: '), write(Flag), nl,
  write('Routes: '), write(Routes), nl,
  write('Total Time: '), write(Total_Time), nl.

print_labeling_time:-
  statistics(total_runtime,[_,T]),
  TS is ((T//10)*10)/1000, nl,
  write('Labeling Time: '), write(TS), write('s'), nl.


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
    open('./results/test_vrptw.txt', append, File_Stream),
    set_output(File_Stream),
    write(File), write(':'), nl,
    print_solution(Solution),
    print_configuration(Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit),
    close(File_Stream),
    write(File), nl, write('Time: '), write(Time_Limit), nl, nl
  ).


test_default:-
  get_files('../data/test', Files),
  %Files = ['../data/test/c000'],
  (
    foreach(File, Files) do
    solve_problem(File, leftmost, step, up, 30000, Solution),
    print_solution(Solution)
  ).
