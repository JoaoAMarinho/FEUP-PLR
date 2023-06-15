:- use_module(library(clpfd)).
:- use_module(library(lists)).

% 1.a sum_equals_product(+Sup, -A, -B, -C)

sum_equals_product(Sup, A, B, C):-
    domain([A, B, C], 0, Sup),
    all_distinct([A,B,C]),
    A + B + C #= A * B * C,
    labeling([], [A, B, C]).

% 1.b three_squares(+Sup, -A, -B, -C)

three_squares(Sup, A, B, C):-
    domain([A, B, C], 1, Sup),
    all_distinct([A,B,C]),
    A #=< B,
    B #=< C,
    A + B + C #= X * X,
    A * B + C #= Y * Y, 
    A * C + B #= Q * Q,
    C * B + A #= U * U,
    labeling([], [A, B, C]).

% 1.c solve_digits(-A, -B)

solve_digits(A, B):-
    L = [A1, A2, A3, B1, B2, B3],
    domain(L, 1, 9),
    all_distinct(L),
    B3 * 2 #= A1,
    A1 #> A2,
    A2 #> A3,
    B1 #> B2,
    B2 #> B3,
    A1 + A2 + A3 #= B1 + B2 + B3,
    A1 * A2 * A3 + 12 #= B1 * B2 * B3,
    A #= A1 + A2 * 10 + A3 * 100, 
    B #= B1 + B2 * 10 + B3 * 100, 
    labeling([], [A, B]).

% 2.a magic_square_3x3(-Matrix)

magic_square_3x3(Square):-
    magic_square(Square, 3).


% 2.b magic_square(-Matrix, +N).

create_rows([], _, _).
create_rows([H|T], Length, Sum):-
    length(H, Length),
    sum(H, #=, Sum),
    create_rows(T, Length, Sum).

diagonal1([], [], _).
diagonal1([H|T], [E|R], N):-
    N1 is N + 1,
    element(N, H, E),
    diagonal1(T, R, N1).

diagonal2([], [], _).
diagonal2([H|T], [E|R], N):-
    N1 is N - 1,
    element(N, H, E),
    diagonal2(T, R, N1).

magic_square(Square, N):-
    Limit is N*N,
    Sum is (Limit+1)*N//2,
    
    % Setup Matrix
    length(Square, N),
    create_rows(Square, N, Sum),

    % Matrix Var Constraints 
    append(Square, ListSquare),
    domain(ListSquare, 1, Limit),
    all_distinct(ListSquare),

    % Cols Constraints
    transpose(Square, TransposeSquare),
    create_rows(TransposeSquare, N, Sum),

    % Diagonals Constraints
    diagonal1(Square, Diagonal1, 1),
    diagonal2(Square, Diagonal2, N),
    sum(Diagonal1, #=, Sum),
    sum(Diagonal2, #=, Sum),
    labeling([], ListSquare).

% 4. n_queens(-Positions, +N)

compare_pairs(_, [], _, _).
compare_pairs(V1, [V2|T], N, N1):-
    abs(N1-N) #\= abs(V1-V2),
    N2 is N1 + 1,
    compare_pairs(V1, T, N, N2).

no_same_diagonals([], _).
no_same_diagonals([V1|T], N):-
    N1 is N + 1,
    compare_pairs(V1, T, N, N1),
    no_same_diagonals(T, N).

n_queens(Positions, N):-
    length(Positions, N),
    domain(Positions, 1, N),
    all_distinct(Positions),
    no_same_diagonals(Positions, 1),
    labeling([], Positions).

% 5. crypto(1)

sum_quotient(X, Y, Aux, Res, Quo):-
    X + Y + Aux #= Quo * 10 + Res.  

crypto(1, L1, L2, L3):-
    L1 = [0,S,E,N,D],
    L2 = [0,M,O,R,E],
    L3 = [M,O,N,E,Y],
    L  = [S,E,N,D,M,O,R,Y],
    all_distinct(L),
    M #\= 0, S #\= 0,
    domain(L, 0, 9),
    sum_quotient(D, E, 0, Y, Q1),
    sum_quotient(N, R, Q1, E, Q2),
    sum_quotient(E, O, Q2, N, Q3),
    sum_quotient(S, M, Q3, O, Q4),
    sum_quotient(0, 0, Q4, M, _),
    labeling([], L).

% 7. purchase_invoice(-R)

purchase_invoice(R):-
    D1 * 1000 + 670 + D2 #= 72 * R,
    domain([D1, D2], 0, 9),
    D1 #\= 0,
    labeling([], [R]).

% 8. grocery(-P)

get_multiple_10([], []).
get_multiple_10([H|T], [B|R]):-
    _X * 10 #= H #<=> B,
    get_last_digit(T, R).

grocery(P):-
    P = [Spaghetti, Carrots, Potatos, Onions],
    domain(P, 1, 700),
    Spaghetti #> Carrots,
    Carrots #> Potatos,
    Potatos #> Onions,
    711000000 #= Potatos * Carrots * Onions * Spaghetti,
    sum(P, #=, 711),
    get_multiple_10(P, M),
    sum(M, #>=, 2),
    labeling([], P).

% 9. cellar(-Total)

cellar(Total):-
    187 * 1200 #= Total * 340,
    labeling([], [Total]).

% 10. detergent(-People)

detergent(People):-
    sum([Liquid, Powder, Both, None], #=, People),
    People in 1..1000,
    People #= (Liquid + None) * 3,
    2 * People #= (Powder + None) * 7,
    Both #= 427,
    People #= 5 * None,
    labeling([], [People]).

% 11. zebra_puzzle(-Solution)

zebra_puzzle(Nationalities):-
    Nationalities = [English, Spanish, Ukrainian, Norwegian, Portuguese],
    Colors = [Red, Yellow, Blue, Green, White],
    Drinks = [Water, Tea, Milk, Oj, Coffee],
    Cigarettes = [Malboro, Chesterfields, LukyStrike, Winston, SGLights],
    Pets = [Dog, Fox, Horse, Iguana, Zebra],
    domain(Nationalities, 1, 5), domain(Colors, 1, 5), domain(Drinks, 1, 5), domain(Cigarettes, 1, 5), domain(Pets, 1, 5),
    all_distinct(Nationalities), all_distinct(Colors), all_distinct(Drinks), all_distinct(Cigarettes), all_distinct(Pets),
    English #= Red,
    Spanish #= Dog,
    Norwegian #= 1,
    Yellow #= Malboro,
    Chesterfields #= Fox + 1 #\/ Chesterfields #= Fox - 1,
    Blue #= 2,
    Winston #= Iguana,
    LukyStrike #= Oj,
    Ukrainian #= Tea,
    Portuguese #= SGLights,
    Malboro #= Horse + 1 #\/ Malboro #= Horse - 1,
    Green #= Coffee,
    Green #= White + 1,
    Milk #= 3,
    labeling([], Nationalities).

