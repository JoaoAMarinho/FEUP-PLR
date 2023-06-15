:- use_module(library(clpfd)).
:- use_module(library(lists)).

% 1. guards_fort(-Solution)

guards_fort(L):-
    length(L, 12),
    L = [A, B, C, D, E, F, G, H, I, J, K, L],
    domain(L, 0, 12),
    sum(L, #=, 12),
    A + B + C + D #= 5,
    D + E + F + G #= 5,
    G + H + I + J #= 5,
    J + K + L + A #= 5,
    labeling([], L).

% 2. wed_tables(+Size, +Together, +Apart, -Solution)

wed_tables(Size, Together, Apart, L):-
    length(L, Size), domain(L, 1, Size),
    all_distinct(L), h_t(Together, L, Size), h_a(Apart, L, Size),
    labeling([], L).

h_t([], _, _).
h_t([H1-H2|T], L, Size):-
    element(H1, L, V1), element(H2, L, V2),
    abs(V1-V2) #= 1 #\/ abs(V1-V2) #= Size-1,
    h_t(T, L, Size).

h_a([], _, _).
h_a([H1-H2|T], L, Size):-
    element(H1, L, V1), element(H2, L, V2),
    abs(V1-V2) #\= 1 #/\ abs(V1-V2) #\= Size-1,
    h_a(T, L, Size).

% 3. car_line(Solution)

color(1, blue).
color(2, black).
color(3, green).
color(4, red).

translate([], []).
translate([H|T], [H1|T1]):-
    color(H, H1),
    translate(T, T1).

car_line(R):-
    length(L, 12), domain(L, 1, 4), global_cardinality(L, [1-3, 2-4, 3-2, 4-3]),
    element(1, L, F), element(12, L, Lst), F #= Lst,
    element(2, L, S), element(11, L, P), S #= P,
    element(5, L, 1),
    distinct_colors(L),
    exact_condition(L, []),
    labeling([], L), translate(L, R).

distinct_colors([_, _]).
distinct_colors([H1, H2, H3|T]):-
    all_distinct([H1, H2, H3]),
    distinct_colors([H2, H3|T]).

exact_condition([_, _, _], L):-
    sum(L, #=, 1).
exact_condition([H1, H2, H3, H4 | T], L):-
    (H1 #= 2 #/\ H2 #= 3 #/\ H3 #= 4 #/\ H4 #= 1) #<=> X,
    exact_condition([H2, H3, H4|T], [X|L]).

% 4. questions(+Valuations, +MinGrade, -Right)

questions(Valuations, MinGrade, Right):- 
    length(Valuations, N),
    length(Right, N),
    domain(Right, 0, 1),
    scalar_product(Valuations, Right, #>=, MinGrade),
    labeling([], Right).

% 5. makeTest(+NCategories, +TotalTime, +MinQuestionsPerLevel, -Questions)

% question(IDQuestion, IDTopic, Difficulty, EstimatedTime).
question(1, 1, 1, 3). question(2, 1, 2, 5). question(3, 1, 3, 8).
question(4, 2, 1, 4). question(5, 2, 2, 6). question(6, 2, 3, 9).
question(7, 3, 1, 4). question(8, 3, 2, 6). question(9, 3, 3, 9).
question(10, 4, 1, 6). question(11, 4, 2, 9). question(12, 4, 3, 12).
question(13, 5, 1, 6). question(14, 5, 2, 9). question(15, 5, 3, 12).
question(16, 6, 1, 6). question(17, 6, 2, 9). question(18, 6, 3, 12).
question(19, 7, 1, 6). question(20, 7, 2, 9). question(21, 7, 3, 12).

makeTest(NCategories, TotalTime, MinQuestionsPerLevel, Questions):-
    length(Questions, NCategories),
    time_topic_diff_constraints(Questions, TotalTime, Topics, Difficulty),
    all_distinct(Topics),
    global_cardinality(Difficulty, [1-X, 2-Y, 3-Z]),
    X #>= MinQuestionsPerLevel, Y #>= MinQuestionsPerLevel, Z #>= MinQuestionsPerLevel,
    labeling([], Questions).

time_topic_diff_constraints([], TotalTime, [], []):- TotalTime #= 0.

time_topic_diff_constraints([H|T], TotalTime, [Topic|R], [Difficulty| R2]):-
    question(H, Topic, Difficulty, Time),
    NewTime #= TotalTime - Time,
    time_topic_diff_constraints(T, NewTime, R, R2).

% 6. wrap(+Presents, +PaperRolls, -SelectedPaperRolls)
% Use bin_packing or cumulative

wrap(Presents, PaperRolls, SelectedPaperRolls):-
    length(Presents, N), length(SelectedPaperRolls, N), length(PaperRolls, M),
    domain(SelectedPaperRolls, 1, M),
    paper_constraints(SelectedPaperRolls, M, PaperRolls, Presents),
    labeling([], SelectedPaperRolls).

paper_constraints([], 0, [], [], []).
paper_constraints(SelectedPaperRolls, M, [Paper|RestRools], Presents):-
    bigger_than_x(SelectedPaperRolls, M, Presents, Paper),
    M1 is M - 1,
    paper_constraints(SelectedPaperRolls, M1, RestRools, Presents).

bigger_than_x([], _, _, Paper):- Paper #>= 0.
bigger_than_x([Index|T], M, [Need|Rest], Paper):-
    Index #= M #<=> X,
    Difference is Paper - Need,
    if_then_else(X, Difference, Paper, NewPaper),
    bigger_than_x(T, M, Rest, NewPaper).

if_then_else(1, Difference, _, Difference).
if_then_else(0, _, Paper, Paper).

% 7. scalar_product
% 9. organize(+Shelves, +Objects, -Vars)
% Transpor matriz

organize(Shelves, Objects, Vars):-
    length(Objects, N), length(Vars, N),
    append(Shelves, Compartments), length(Compartments, K),
    domain(Vars, 1, K),
    build_items(Objects, Vars, Items),
    build_bins(Compartments, 1, Bins),
    bin_packing(Items, Bins),
    labeling([], Vars).

build_bins([], _, []).
build_bins([H|T], Index, [bin(Index, X)|R]):-
    X #=< H,
    Index1 is Index + 1,
    build_bins(T, Index1, R).

build_items([], [], []).
build_items([Weight-Volume|T], [H|T2], [item(H, Volume)|R]):-
    build_items(T, T2, R).

% 12. seq321(+Sequence)

seq321(Sequence):-
    length(Sequence, 5),
    domain(Sequence, 1, 3),
    regular(Sequence, +3+(+2)+(+1)),
    labeling([], Sequence).