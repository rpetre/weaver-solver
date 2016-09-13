%prolog comment to force vim use the correct syntax

%
% Example: game([[y,b,y],[r,y,b]],[[b,y,r],[y,b,y]],3)
%

/**
 * 
 * game(+InCond:list, +OutCond:list, +MaxFlips:int)
 *
 * Solves a weaver game being given the input and output colours and the max number of flips
 * InCond and OutCond are both lists of two elements: [InTop,InLeft] and [OutBot,OutRight]
 * Every constraint is a list of the colors on that side of the puzzles
 * The number of Top/Bot and Left/Right should be respectively equal
 */

game(InCond,OutCond,MaxFlips) :-
    [InTop,InLeft] = InCond,
    [OutBot,OutRight] = OutCond,
    length(InTop,Width),
    length(OutBot,Width),
    length(InLeft,Height),
    length(OutRight,Height),
    % M is the boolean array of flips
    generate_matrix(Width,Height,is_boolean,M),
    max_flips(M,MaxFlips),
    W1 is Width+1, H1 is Height+1,
    % Down and Right are the colour arrays of node outputs
    % both are zero-based to include the inputs
    % var/1 is used as a generator to have them seeded with free variables
    generate_matrix(W1,H1,var,Down),
    generate_matrix(W1,H1,var,Right),
    % seed the borders of the Down and Right arrays with the conditions
    matrix_row(Down,0,InTop),
    matrix_row(Down,Height,OutBot),
    matrix_col(Right,0,InLeft),
    matrix_col(Right,Width,OutRight),
    Game=[M,Down,Right],
    check_game_board(M,1,Game),
    print_matrix(M).

/**
 * check_game_board(+Board:list, +Y:int, +Game:list)
 *
 * Validates a game board recursively (row-based), i.e. colours are propagating
 * through the Down and Right arrays (members of Game) based on the state of the board
 * Y is the current row, Board is the subset remaining
 * Game is the tuple [M,Down,Right] of full arrays
 */
check_game_board([],_,_).
check_game_board([Row|Rows],Y,Game) :-
    check_game_row(Row,1,Y,Game),
    Y1 is Y+1,
    check_game_board(Rows,Y1,Game).

/**
 * check_game_row(+Row:list, +X:int, +Y:int, +Game:list)
 *
 * Validates a board row recursively
 * X,Y are coordinates of the head of the row
 * rest of vars are similar to check_game_board/3
 */
check_game_row([],_,_,_).
check_game_row([_|Items],X,Y,Game) :-
    check_game(X,Y,Game),
    X1 is X+1,
    check_game_row(Items,X1,Y,Game).

/**
 * check_game(+X:int, +Y:int, +Game:list)
 *
 * Validates a specific node of the board based on its flip state
 * i.e. unifies the outputs to the inputs in the Down and Right arrays
 */

% the straight case
check_game(X,Y,[M,Down,Right]) :-
    X>0, Y>0, X1 is X-1, Y1 is Y-1,
    cell0(Down,X,Y,C1),cell0(Right,X,Y,C2),
    \+cell(M,X,Y,1),
    cell0(Down,X,Y1,C1),cell0(Right,X1,Y,C2).
% the crossed case
check_game(X,Y,[M,Down,Right]) :-
    X>0, Y>0, X1 is X-1, Y1 is Y-1,
    cell0(Down,X,Y,C1),cell0(Right,X,Y,C2),
    cell(M,X,Y,1),
    cell0(Down,X,Y1,C2),cell0(Right,X1,Y,C1).


%%%%% Matrix helper predicates %%%%%

/**
 * generate_matrix(+Width:int, +Height:int, +Func:predicate, -M:list)
 *
 * generates a Width x Height matrix
 * elements of the matrix will be subjected to the Func predicate (use var/1 to leave
 * them as free variables)
 * M will be constructed as a list of rows
 */
generate_matrix(Width,Height,Func,M) :-
    length(M, Height),
    NewRow =.. [generate_row, Func, Width],
    maplist(NewRow, M) .

/**
 * generate_row(+Func:predicate, +Width:int, -Row:list)
 *
 * generates a row of Width elements (for generate_matrix)
 * each element will be subjected to the Func predicate
 */
generate_row(Func,Width,Row) :-
    length(Row,Width) ,
    maplist(Func,Row) .

/**
 * is_boolean(+X:int)
 *
 * Forces X to be either 0 or 1
 * helper predicate for generate_matrix
 */
is_boolean(X) :-
    X = 0 ; X = 1.

/**
 * matrix_row(+M:list, +Y:int, ?List:list)
 *
 * unifies the Yth row of the M array (0-indexed) to List
 */
matrix_row(M,Y,List) :- nth0(Y,M,[_|List]).

/**
 * matrix_col(+M:list, +X:int, ?List:list)
 *
 * unifies the Xth column of the M array (0-indexed) to List
 */
matrix_col(M,X,List) :-
    Val =.. [nth0,X],
    maplist(Val,M,[_|List]).


/**
 * matrix_sum(+M:list, -S:int)
 *
 * sums all elements of M into S
 */
matrix_sum([],0).
matrix_sum([Row|Rows],S) :-
    row_sum(Row,S1),
    matrix_sum(Rows,S2),
    S is S1+S2.
row_sum([],0).
row_sum([H|T],S) :-
    row_sum(T,S1),
    S is H+S1.

/**
 * max_flips(+M:list, +Num:int)
 *
 * Verifies that the sum of M is at most Num
 */
max_flips(M,Num) :-
    matrix_sum(M,S),
    S =< Num.


/**
 * print_matrix(+M:list)
 *
 * pretty-prints a boolean matrix of twists.
 * 0 will be output as '+'
 * 1 will be output as 'X'
 */
print_matrix([]).
print_matrix([Row|Rows]) :-
    print(' '),
    print_line(Row),
    nl,
    print_matrix(Rows).
print_line([]).
print_line([Head|Tail]) :-
    print_val(Head),
    print_line(Tail).
print_val(0) :- print('+').
print_val(1) :- print('X').

% predicates to compute width and height of a row-based matrix
width(M,W) :- length(M,W), W is W.
height(M,H) :- M = [Row|_] , length(Row,H).

% predicates to extract a specific cell of a matrix, both 1 and 0 indexed versions
cell(M,X,Y,V) :- nth1(Y,M,Row) , nth1(X,Row,V).
cell0(M,X,Y,V) :- nth0(Y,M,Row) , nth0(X,Row,V).

