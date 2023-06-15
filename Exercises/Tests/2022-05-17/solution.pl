:- use_module(library(clpfd)).

ex1(A,B,C):-
  domain([A, B, C], 1,10),
  A + B #> 16,
  A + C #< 12,
  B + C #< 10.

tresQuads(N, [A,B,C]):-
  domain([A,B,C], 1, N),
  all_distinct([A,B,C]),
  X #> 1, Y #> 1, Z #> 1, W #> 1,
  A + B + C #= X * X,
  A * B + C #= Y * Y,
  A * C + B #= Z * Z,
  B * C + A #= W * W,
  A #> B, B #> C,
  labeling([], [A,B,C]). 

ex4(N, MaxVal, Sol):-
  length(Sol, N),
  domain(Sol, 0, MaxVal),
  all_distinct(Sol),
  different_differences(Sol, L),
  all_distinct(L),
  labeling([], Sol).

different_differences([_], []):- !.
different_differences([A|T], L):-
  calculate_differences(A, T, L1),
  different_differences(T, L2),
  append(L1, L2, L).

calculate_differences(_, [], []).
calculate_differences(A, [B|T], [D|L]):-
  A #< B,
  D #= B - A,
  calculate_differences(A, T, L).

boats(Limits, Order, Penalty):-
  length(Limits, N),
  length(Order, N),
  all_distinct(Order),
  apply_limits(Limits, Order, 1, Penalties),
  sum(Penalties, #=, Penalty),
  labeling([minimize(Penalty)], Order).

apply_limits([], [], _, []).
apply_limits([Limit|T], [H|T2], Index, [Penalty1|T3]):-
  H in 1..Limit,
  Penalty #= H - Index,
  Penalty #> 0 #<=> Scalar,
  Penalty1 #= Penalty * Scalar,
  Index1 is Index + 1,
  apply_limits(T, T2, Index1, T3).

% Não entendi a 5, 6