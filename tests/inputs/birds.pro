% https://raw.githubusercontent.com/Anniepoo/prolog-examples/master/birds.pl
% renamed birds.pro to test pro disambiguation
:- module(birds, [solve/0]).
%
% Start of an implementation of the code at
% http://www.amzi.com/ExpertSystemsInProlog/
%
%
:- dynamic
	known/3,
	voice/1,
	season/1,
	cheek/1,
	head/1,
	flight/1,
	bill/1,
	live/1,
	nostrils/1.

:- discontiguous bird/1, wings/1.
:- set_prolog_flag(unknown, error).

bird(laysan_albatross):-
  family(albatross),
  color(white).

bird(black_footed_albatross):-
  family(albatross),
  color(dark).

bird(whistling_swan) :-
  family(swan),
  voice(muffled_musical_whistle).

bird(trumpeter_swan) :-
  family(swan),
  voice(loud_trumpeting).


order(tubenose) :-
nostrils(external_tubular),
live(at_sea),
bill(hooked).

order(waterfowl) :-
feet(webbed),
bill(flat).

family(albatross) :-
order(tubenose),
size(large),
wings(long_narrow).

family(swan) :-
order(waterfowl),
neck(long),
color(white),
flight(ponderous).

bird(canada_goose):-
family(goose),
season(winter),
country(united_states),
head(black),
cheek(white).

bird(canada_goose):-
family(goose),
season(summer),
country(canada),
head(black),
cheek(white).

country(united_states):- region(mid_west).

country(united_states):- region(south_west).

country(united_states):- region(north_west).

country(united_states):- region(mid_atlantic).

country(canada):- province(ontario).

country(canada):- province(quebec).

region(new_england):-
state(X),
member(X, [massachusetts, vermont]).

region(south_east):-
state(X),
member(X, [florida, mississippi]).

state(X) :- member(X, [florida, mississippi, massachusetts, vermont]).

province(X) :- member(X, [ontario, quebec]).

ask(A, V):-
  known(yes, A, V), % succeed if true
  !. % stop looking

ask(A, V):-
  known(_, A, V), % fail if false
  !, fail.

% known is barfing
ask(A, V):-
  write(A:V), % ask user
  write('? : '),
  read(Y), % get the answer
  asserta(known(Y, A, V)), % remember it
  Y == yes. % succeed or fail
ask(A, V):-
	\+ multivalued(A),
	known(yes, A, V2),
	V \== V2,
	!, fail.

eats(X):- ask(eats, X).

feet(X):- ask(feet, X).

wings(X):- ask(wings, X).

neck(X):- ask(neck, X).

color(X):- ask(color, X).

multivalued(voice).
multivalued(feed).

size(X):- menuask(size, X, [large, plump, medium, small]).

flight(X):- menuask(flight, X, [ponderous, agile, flap_glide]).



menuask(A, V, MenuList) :-
write('What is the value for'), write(A), write('?'), nl,
write(MenuList), nl,
read(X),
check_val(X, A, V, MenuList),
asserta( known(yes, A, X) ),
X == V.

check_val(X, _A, _V, MenuList) :-
member(X, MenuList), !.

check_val(X, A, V, MenuList) :-
write(X), write(' is not a legal value, try again.'), nl,
menuask(A, V, MenuList).

top_goal(X) :- bird(X).

solve :-
retractall(known/3),
top_goal(X),
write('The answer is '), write(X), nl.

solve :-
write('No answer found.'), nl.

