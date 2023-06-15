% 1.a factorial(+N, ?F)

factorial(0, 1).
factorial(N, F) :- 
                N > 0,
                N1 is N - 1,
                factorial(N1, F1),
                F is N * F1.

% 1.b sumRec(+N, ?Sum)

sumRec(0, 0).
sumRec(N, Sum) :-
            N > 0,
            N1 is N-1,
            sumRec(N1, Sum1),
            Sum is N + Sum1.

% 1.c fibonacci(+N, ?F)

fibonacci(0, 0).
fibonacci(1, 1).
fibonacci(N, F) :-
                N > 1,
                N1 is N-1,
                N2 is N-2,
                fibonacci(N1, F1),
                fibonacci(N2, F2),
                F is F1 + F2.

% Improved version returning the current and before fibonacci numbers

fibonacci2(N, F) :- fibonacci2(N, F, _F2).

fibonacci2(0, 0, 0).
fibonacci2(1, 1, 0).
fibonacci2(N, Res, Res2) :-
                N > 1,
                N1 is N-1,
                fibonacci2(N1, F1, F2),
                Res2 = F1,
                Res is F1 + F2.

% 1.d isPrime(+X)

isPrime(1).
isPrime(X):-
        X > 1,
        X1 is X - 1,
        isNotDivisible(X,X1).

isNotDivisible(_,1).
isNotDivisible(X,Y):-
                Rem is X mod Y,
                Rem \= 0,
                X1 is Y - 1,
                isNotDivisible(X,X1).

% 5.a list_size(+List, ?Size)

list_size(List, Size):- list_size(List, 0, Size).

list_size([], Size, Size).
list_size([_|List], Acc, Size):-
                Acc1 is Acc + 1,
                list_size(List, Acc1, Size).

% 5.b list_sum(+List, ?Sum)

list_sum(List, Sum):- list_sum(List, 0, Sum).

list_sum([], Sum, Sum).
list_sum([V|List], Acc, Sum):-
                Acc1 is Acc + V,
                list_sum(List, Acc1, Sum).

% 5.c list_prod(+List, ?Prod)

list_prod([], 0).
list_prod(List, Prod):- list_prod(List, 1, Prod).

list_prod([], Prod, Prod).
list_prod([V|List], Acc, Prod):-
                Acc1 is Acc * V,
                list_prod(List, Acc1, Prod).

% 5.d inner_product(+List1, +List2, ?Result)

inner_product([], [], 0).
inner_product(List1, List2, Prod):- inner_product(List1, List2, 0, Prod).

inner_product([], [], Prod, Prod).
inner_product([V1|List1], [V2|List2], Acc, Prod):-
                Acc1 is Acc + V1 * V2,
                inner_product(List1, List2, Acc1, Prod).

% 5.e count(+Elem, +List, ?N)

count(_, [], 0).
count(Elem, List, N):- count(Elem, List, 0, N).

count(_, [], N, N).

count(Elem, [X|List], Acc, N):- Elem \= X, count(Elem, List, Acc, N).
count(Elem, [Elem|List], Acc, N):-
                Acc1 is Acc + 1,
                count(Elem, List, Acc1, N).


% 6.a invert(+List1, ?List2)

invert(L1, L2):- invert(L1, L2, []).

invert([], L2, L2).
invert([V|L1], L2, Acc):-
                Acc1 = [V|Acc],
                invert(L1, L2, Acc1).

% 6.b del_one(+Elem, +List1, ?List2)

del_one(Elem, List1, List2):- del_one(Elem, List1, List2, []).

del_one(_, [], List2, List2).
del_one(Elem, [Elem|List1], List2, Acc):- !, append(Acc, List1, List2).
del_one(Elem, [V|List1], List2, Acc):-
        append(Acc, [V], Acc1),
        del_one(Elem, List1, List2, Acc1).

% 6.b del_one_improved(+Elem, +List1, ?List2)

del_one_improved(_, [], []).

del_one_improved(Elem, [Elem|List1], List1):- !.
del_one_improved(Elem, [V|List1], [V|List2]):-
        del_one_improved(Elem, List1, List2).

% 6.c del_all(+Elem, +List1, ?List2)

del_all(Elem, List1, List2):- del_all(Elem, List1, List2, []).

del_all(_, [], List2, List2).

del_all(Elem, [Elem|List1], List2, Acc):- !,
                del_all(Elem, List1, List2, Acc).
del_all(Elem, [V|List1], List2, Acc):-
        append(Acc, [V], Acc1),
        del_all(Elem, List1, List2, Acc1).

% 6.d del_all_list(+ListElems, +List1, ?List2)

del_all_list([], List2, List2).
del_all_list([V | ListElems], List1, List2):-
                del_all(V, List1, Acc),
                del_all_list(ListElems, Acc, List2).

% 6.e del_dups(+List1, ?List2)


% 6.f list_perm(+L1, +L2)


% 6.g replicate(+Amount, +Elem, ?List)


% 6.h intersperse(+Elem, +List1, ?List2)


% 6.i insert_elem(+Index, +List1, +Elem, ?List2)


% 6.j delete_elem(+Index, +List1, ?Elem, ?List2)


% 6.k replace(+List1, +Index, ?Old, +New, ?List2)


% 11 pascal(+N, ?Lines)

pascal(N, Lines):- pascal(N, Lines, 0, []).

pascal(N, [], V, _):- V is N + 1, !.
pascal(N, [Res | Lines], X, Acc):-
        find_pascal_line(Acc, Line),
        Res = [1 | Line],
        X1 is X + 1,
        pascal(N, Lines, X1, Res).

find_pascal_line([V1, V2 | L], [Sum | Res]):- !,
        Sum is V1 + V2,
        find_pascal_line([V2 | L], Res).

find_pascal_line([_V|_], [1]):- !.
find_pascal_line(_, []).






