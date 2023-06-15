:- use_module(library(clpfd)).

% a)

seq_number(Numbers):-
  Numbers = [A,B,C,D,E],
  all_distinct(Numbers),
  domain([A,B,D,E], 1, 9),
  C in 1..2,
  odd_diff(Numbers),
  labeling([], Numbers).

odd_diff([_]).
odd_diff([A,B|T]):-
  (A - B) mod 2 #= 1,
  odd_diff([B|T]).

% b)


seq_number2(N, Numbers):-
  N mod 3 =:= 0,
  length(Numbers, N),
  domain(Numbers, 1, 9),
  Vars = [Um, Dois, Tres, Quatro, Cinco, Seis, Sete, Oito, Nove],
  domain(Vars, 0, 3),
  global_cardinality(Numbers, [1-Um, 2-Dois, 3-Tres, 4-Quatro, 5-Cinco, 6-Seis, 7-Sete, 8-Oito, 9-Nove]),
  odd_diff(Numbers),
  Middle is (N+1) div 2,
  element(Middle, Numbers, X),
  element(1, Numbers, First),
  element(N, Numbers, Last),
  X #> First, X #> Last,
  labeling([], Numbers).

