:-use_module(library(between)).

% 4.a print_n(+S, +N)

print_n(_, 0).
print_n(S, N):-
    N > 0,
    N1 is N-1,
    write(S),
    print_n(S, N1).

% 4.b print_text(+Text, +Symbol, +Padding)

% 4.c print_banner(+Text, +Symbol, +Padding)

print_banner(Text, Symbol, Padding):-
    length(Text, Size),
    EmptyLine is 2*Padding + Size,
    FullLine is EmptyLine+2,
    print_n(Symbol, FullLine),nl,
    print_banner_side(Symbol, EmptyLine),
    put_char(Symbol),
    print_n(' ', Padding),
    print_text(Text),
    print_n(' ', Padding),
    put_char(Symbol), nl,
    print_banner_side(Symbol, EmptyLine),
    print_n(Symbol, FullLine),nl.

print_text([]).
print_text([H|T]):-
    put_code(H),
    print_text(T).

print_banner_side(Symbol, Size):-
    put_char(Symbol),
    print_n(' ', Size),
    put_char(Symbol),nl.

% 4.d read_number(-X)

read_number(Sep, X):-
    read_number(Sep, X, 0).

read_number(Sep, X, Acc):-
    \+peek_char(Sep), !,
    get_code(C),
    between(48, 57, C),
    Acc1 is Acc * 10 + C - 48,
    read_number(Sep, X, Acc1).

read_number(_, X, X):- get_char(_).

% 4.e read_until_between(+Min, +Max, -Value)
% 4.f read_string(-X)
% 4.g banner/0
% 4.h print_multi_banner(+ListOfTexts, +Symbol, +Padding)
% 4.i print_multi_banner(+ListOfTexts, +Symbol, +Padding)

% 5.a read_file(+File, -N, -Matrix)

read_file(File, N, Matrix):-
    see(File),
    read_number('\n', N),
    read_matrix(Matrix, N, 0), !,
    seen.

read_matrix([], N, N).
read_matrix([Numbers|Matrix], N, Line):-
    New_Line is Line + 1, !,
    read__matrix_line(N, Numbers),
    read_matrix(Matrix, N, New_Line).

read__matrix_line(1, [V]):- !, read_number('\n', V).
read__matrix_line(N, [V|Numbers]):-
    Size is N - 1,
    read_number(' ', V),
    read__matrix_line(Size, Numbers).

% 8

% class(Course, ClassType, DayOfWeek, Time, Duration)

class(pfl, t, '1 Mon', 11, 1).
class(pfl, t, '4 Thu', 10, 1).
class(pfl, tp, '2 Tue', 10.5, 2).

class(lbaw, t, '1 Mon', 8, 2).
class(lbaw, tp, '3 Wed', 10.5, 2).

class(ltw, t, '1 Mon', 10, 1).
class(ltw, t, '4 Thu', 11, 1).
class(ltw, tp, '5 Fri', 8.5, 2).

class(fsi, t, '1 Mon', 12, 1).
class(fsi, t, '4 Thu', 12, 1).
class(fsi, tp, '3 Wed', 8.5, 2).

class(rc, t, '4 Thu', 8, 2).
class(rc, tp, '5 Fri', 10.5, 2).

% 8.a same_day(+Course1, +Course2)

same_day(Course1, Course2):-
    class(Course1, _, D, _, _),
    class(Course2, _, D, _, _).

% 8.b daily_courses(+Day, -Courses)

daily_courses(Day, Courses):-
    findall(Course, class(Course, _, Day, _, _), Courses).

% 8.c short_classes(-L)

short_classes(L):-
    findall(
        Course-Day/Time, 
        (class(Course, _, Day, Time, Duration), Duration < 2), 
        L
    ).

% 8.d course_classes(+Course, -Classes)

course_classes(Course, Classes):-
    findall(
        Day/Time-Type, 
        class(Course, Type, Day, Time, _), 
        Classes
    ).

% 8.e courses(-L)

courses(L):-
    findall(Course, class(Course, _, _, _, _), RepeatedCourses),
    sort(RepeatedCourses, L).

% 8.f schedule/0
schedule:-
    findall(Day/Time-Course, class(Course, _, Day, Time, _), L),
    keysort(L, SortedL),
    print_list(SortedL).

print_list([]).
print_list([H|L]):-
    write(H),nl,
    print_list(L).

% 8.h find_class/0

find_class:-
    write('Input Day/Hour:'),
    read(Day/Hour),
    class(Course, _, Day, H, Duration),
    End is H+Duration,
    Hour =< End, Hour > H,
    write(Course-H-Duration).