:- [main].

/*
* Return a list of all possible combinations of the following parameters:
* get_test_combinations(-Test_Combinations)
*/
get_test_combinations(Test_Combinations) :-
  Variable_Ordering = [leftmost, min, max, ff, anti_first_fail, occurrence, ffc, max_regret, impact, dom_w_deg], % We can add random ordering
  Value_Selection = [step, enum, bisect, median, middle],  % We can add random selection
  Value_Ordering = [up, down],
  Time_Limits = [30000, 60000, 120000, 240000, 480000, 960000],
  % We can add restart search scheme

  findall([X, Y, Z, W], 
    (
      member(X, Variable_Ordering),
      member(Y, Value_Selection),
      member(Z, Value_Ordering),
      member(W, Time_Limits)
    ), Test_Combinations).


print_time(Msg):-
  statistics(total_runtime,[_,T]),
  TS is ((T//10)*10)/1000, nl,
  write(Msg),
  write(TS),
  write('s'), nl, nl.


print_solution(Solution):-
  Solution = [Routes, Total_Time, Flag],
  write('Flag: '), write(Flag), nl,
  write('Routes: '), write(Routes), nl,
  write('Total Time: '), write(Total_Time), nl, nl.


print_configuration(Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit):-
  write('Variable Ordering: '), write(Variable_Ordering), nl,
  write('Value Selection: '), write(Value_Selection), nl,
  write('Value Ordering: '), write(Value_Ordering), nl,
  write('Time Limit: '), write(Time_Limit), nl, nl.


test:-
  get_test_combinations(Test_Combinations),
  (
    foreach([Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit], Test_Combinations), count(I,1,N) do
    solve_problem(Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit, Solution),
    open('./results/test.txt', append, File_Stream),
    set_output(File_Stream),
    write(I), write(':'), nl,
    print_time('Labeling Time: '),
    %statistics,
    %fd_statistics,
    print_solution(Solution),
    print_configuration(Variable_Ordering, Value_Selection, Value_Ordering, Time_Limit),
    close(File_Stream)
  ).