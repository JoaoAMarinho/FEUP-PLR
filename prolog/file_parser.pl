:-use_module(library(between)).

/*
* Returns problem type according to ID:
* problem_type(+ID, -Type)
*/
problem_type(2, Type):-  Type = mdvrp.
problem_type(4, Type):-  Type = vrptw.
problem_type(6, Type):-  Type = mdvrptw.


/*
* Parses an input file:
* parse_file(-Problem_Type, -N_Vehicles, -N_Customers, -N_Depots, -Depots_Info, -Depots, -Customers)
*/
parse_file(Problem_Type, N_Vehicles, N_Customers, N_Depots, Depots_Info, Depots, Customers):-
	%write('Enter the file path: '),
	%read(Filepath),
	%see(Filepath),
	see('../data/vrptw/c000'),
	parse_first_line(Problem_ID, N_Vehicles, N_Customers, N_Depots),
	problem_type(Problem_ID, Problem_Type),
	parse_depots_info(N_Depots, Depots_Info),
	parse_single_depot(Problem_Type, N_Depots, New_N_Depots, Depots),   % only vrptw will have a depot before customers
	parse_nodes(N_Customers, Problem_Type, Customers),
	parse_nodes(New_N_Depots, Problem_Type, Depots),                    % mdvrp and mdvrptw have depots after customers
	seen.
	%write(Problem_ID-Depots_Info-N_Customers-N_Depots), nl,
	%write(Depots_Info), nl,
	%write(Depots), nl.


/*
* Parses an input file:
* parse_first_line(-Problem_ID, -N_Vehicles, -N_Customers, -N_Depots)
*/
parse_first_line(Problem_ID, N_Vehicles, N_Customers, N_Depots):-
	read_int(Problem_ID),
	read_int(N_Vehicles),
	read_int(N_Customers),
	read_int(N_Depots).


/*
* Parses depots info:
* parse_depots_info(+N_Depots, -Depots_Info)
*/
parse_depots_info(0, []):- !.
parse_depots_info(N, [Depot|Depots]):-
	read_int(Max_Duration),
	read_int(Max_Load),
	Depot = depot_info(Max_Duration, Max_Load),
	N1 is N - 1,
	parse_depots_info(N1, Depots).


/*
* Parses nodes:
* parse_nodes(+N_Nodes, +Problem_Type, -Nodes)
*/
parse_nodes(-1, vrptw, _).  % vrptw has a depot before customers
parse_nodes(0, _, []).
parse_nodes(N, Problem_Type, [Node|Nodes]):-
	read_line_info(Problem_Type, ID, X, Y, Service_Time, _Demand, _Frequency, _Visit_Combinations, Time_Window),
	Node = node(ID, X, Y, Service_Time, Time_Window),
	N1 is N - 1,
	parse_nodes(N1, Problem_Type, Nodes).

/*
* Parses single depot (only for vrptw):
* parse_single_depot(+Problem_Type, +N_Depots, +New_N_Depots, -Depot)
*/
parse_single_depot(vrptw, _, -1, [Depot]):-
	read_line_info(vrptw, ID, X, Y, Service_Time, _Demand, _Frequency, _Visit_Combinations, Time_Window), !,
	Depot = node(ID, X, Y, Service_Time, Time_Window).
parse_single_depot(_, N_Depots, N_Depots, _).


/*
* Reads a time window (begin and end) from the input stream:
* read_time_window(+Problem_Type, -Time_Window)
*/
read_time_window(vrptw, Time_Window):-   read_time_window(Time_Window), !.
read_time_window(mdvrptw, Time_Window):- read_time_window(Time_Window), !.
read_time_window(_, []).

read_time_window(Begin_Time_Window-End_Time_Window):-
	read_int(Begin_Time_Window),
	read_int(End_Time_Window).


/*
* Reads a line of information from the input stream:
* read_line_info(+Problem_Type, -ID, -X, -Y, -Service_Time, -Demand, -Frequency, -Visit_Combinations, -Time_Window)
*/
read_line_info(Problem_Type, ID, X, Y, Service_Time, Demand, Frequency, Visit_Combinations, Time_Window):-
	read_int(ID),
	read_float(X),
	read_float(Y),
	read_float(Service_Time_Float),
	Service_Time is round(Service_Time_Float),
	read_float(Demand),
	read_int(Frequency),
	read_int(N_Visit_Combinations),
	read_int_list(N_Visit_Combinations, Visit_Combinations),
	read_time_window(Problem_Type, Time_Window). % only for vrptw and mdvrptw


/*
* Reads an integer from the input stream:
* read_int(-N)
*/
read_int(N):-
	ignore_spaces,
    read_int(N, 0).

read_int(N,N):- peek_char('\n'), get_char(_), !.
read_int(N,N):- peek_char(' '), get_char(_), !.
read_int(N, Acc):-
	get_code(C),
    between(48, 57, C),
    Acc1 is Acc * 10 + C - 48,
    read_int(N, Acc1).

/*
* Reads a float from the input stream:
* read_float(-N)
*/
read_float(N):-
	ignore_spaces,
	is_negative(Sign),
	read_float(N, 0, Sign).

is_negative(-1):- peek_char('-'), get_char(_), !.
is_negative(1).

read_float(N, Acc, Sign):- 
	peek_char('.'), get_char(_), !,
	read_floating_point(F),
	Acc1 is Acc + F, N is Sign * Acc1.

read_float(N, Acc, Sign):- peek_char(' '), get_char(_), !, N is Sign * Acc.
read_float(N, Acc, Sign):-
	get_code(C),
	between(48, 57, C),
	Acc1 is Acc * 10 + C - 48,
	read_float(N, Acc1, Sign).

read_floating_point(F):-
	read_floating_point(F, 0, 1).

read_floating_point(F, F, _):- peek_char(' '), get_char(_), !.
read_floating_point(F, Acc, Exp):-
	get_code(C),
	between(48, 57, C),
	Acc1 is (C - 48)*0.1^Exp + Acc,
	Exp1 is Exp + 1,
	read_floating_point(F, Acc1, Exp1).


/*
* Reads a list of integers from the input stream:
* read_int_list(+N, -List)
*/
read_int_list(0, []).
read_int_list(N, [Int|List]):-
	read_int(Int),
	N1 is N - 1,
	read_int_list(N1, List).


/*
* Ignores spaces from the input stream:
* ignore_spaces()
*/
ignore_spaces:-
	peek_char(' '), !,
	get_char(_),
	ignore_spaces.
ignore_spaces.