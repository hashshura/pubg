/* Games facts */ 
:- dynamic(health/1).
:- dynamic(stamina/1).
:- dynamic(armor/1).
:- dynamic(playerposition/2).
:- dynamic(weapon/1).
:- dynamic(equip/1).
:- dynamic(enemyposition/3).
:- dynamic(enemycount/1).
:- dynamic(inventory/1).
:- dynamic(step/1).
:- dynamic(enemyweapon/3).
:- dynamic(armorposition/3).
:- dynamic(weaponposition/3).
:- dynamic(medicineposition/3).
:- dynamic(ammoposition/3).
:- dynamic(existweapon/3).
:- dynamic(existmedicine/3).
:- dynamic(existammo/3).
:- dynamic(existarmor/3).
:- dynamic(ammo/1).

inc :-
	retract(step(X)),
	Next_X is X+1,
	asserta(step(Next_X)).

/*Enemies stuffs*/
createenemies :-
	asserta(enemyposition(1,2,3)),
	asserta(enemyweapon(1,ak47)),
	asserta(enemyposition(2,5,8)),
	asserta(enemyweapon(2,ak47)),
	asserta(enemyposition(3,9,1)),
	asserta(enemyweapon(3,ak47)),
	asserta(enemyposition(4,4,5)),
	asserta(enemyweapon(4,ak47)),
	asserta(enemycount(4)).

/*start games */
start :-
	asserta(step(0)),
	asserta(health(100)),
	asserta(playerposition(2,2)),
	asserta(stamina(100)),
	asserta(armor(0)),
    asserta(weapon('none')),
	asserta(inventory([])),
	asserta(ammo(0)),
	createenemies, existammo, existarmor, existweapon, existmedicine, !,
	write('======================================================='), nl,
	write('=                         _             _             ='), nl,
	write('=                        | |           ( )            ='), nl,
	write('=         _ __  _ __ ___ | | ___   __ _|/ ___         ='), nl,
	write('=        | \'_ \\| \'__/ _ \\| |/ _ \\ / _` | / __|        ='), nl,
	write('=        | |_) | | | (_) | | (_) | (_| | \\__ \\        ='), nl,
	write('=        | .__/|_|  \\___/|_|\\___/ \\__, | |___/        ='), nl,
	write('=        | |                       __/ |              ='), nl,
	write('=        |_|    unknown           |___/               ='), nl,
	write('=                  battlegrounds                      ='), nl,
	write('======================================================='), nl,
	nl,
	nl,
	write(' Welcome, Warrior.'), nl,
	nl,
	write(' You are chosen as one of class K-3\'s representatives'), nl,
	write(' for the battle by a(n) (un)lucky lottery. Carve the'), nl,
	write(' way out through your opponents\' corpses.'), nl,
	nl,
	write(' Available commands:                               '), nl,
	write('    start. -- start the game!                      '), nl,
	write('    help. -- show available commands               '), nl,
	write('    quit. -- quit the game                         '), nl,
	write('    look. -- look around you                       '), nl,
	write('    n. s. e. w. -- move                            '), nl,
	write('    map. -- look at the map and detect enemies     '), nl,
	write('    take(Object). -- pick up an object             '), nl,
	write('    drop(Object). -- drop an object                '), nl,
	write('    use(Object). -- use an object                  '), nl,
	write('    attack. -- attack enemy that crosses your path '), nl,
	write('    status. -- show your status                    '), nl,
	write('    save(Filename). -- save your game              '), nl,
	write('    load(Filename). -- load previously saved game  '), nl,
	nl,
	write(' Legends:           '), nl,
	write('    W = weapon      '), nl,
	write('    A = armor       '), nl,
	write('    M = medicine    '), nl,
	write('    O = ammo        '), nl,
	write('    P = player      '), nl,
	write('    E = enemy       '), nl,
	write('    - = accessible  '), nl,
	write('    X = inaccessible'), nl,
	nl.

/*maps stuffs */
deadzone(X, Y) :-
	step(Steps),
	Div is Steps // 5 + 1,
	(
	X =< Div, !;
	Y =< Div, !;
	Divl is 21 - Div, X >= Divl, !;
	Divl is 21 - Div, Y >= Divl, !
	).
	
map :-
	printmap(1, 1).
	
printmap(X, Y) :-
	(Y == 21, !, nl, Next_X is X + 1, printmap(Next_X, 1));
	(X < 21, !, write(' '), (
		(playerposition(X, Y), write('P'), !); 
		(deadzone(X, Y), write('X'), !);
		write('_')
	), write(' '), Next_Y is Y + 1, printmap(X, Next_Y));
	X == 21.

/*rest for players*/
rest :-
	inc, enemywalk(1), retract(stamina(Prev)), Now is Prev + 10, Now > 100, !, asserta(stamina(100));
	asserta(stamina(Now)).
	
enemywalk(Id) :-
	enemycount(N), Id =< N, retract(enemyposition(Id,X,Y)), playerposition(Xp,Yp),
		(X > Xp, !, X1 is X - 1, asserta(enemyposition(Id,X1,Y)), NextId is Id + 1, enemywalk(NextId);
		X < Xp, !, X1 is X + 1, asserta(enemyposition(Id,X1,Y)), NextId is Id + 1, enemywalk(NextId);
		Y > Yp, !, Y1 is Y - 1, asserta(enemyposition(Id,X,Y1)), NextId is Id + 1, enemywalk(NextId);
		Y < Yp, !, Y1 is Y + 1, asserta(enemyposition(Id,X,Y1)), NextId is Id + 1, enemywalk(NextId)).


look :-
	playerposition(X, Y),
	Startpx is X-1,
	Startpy is Y-1,
	printlook(Startpx, Startpy).
	
printlook(X, Y) :-
	playerposition(Px, Py),
	Endpy is Py + 2,
	Endpx is Px + 2,
	Startpy is Py - 1,
	(
		(Y == Endpy, !, nl, Next_X is X + 1, printlook(Next_X, Startpy));
		(X < Endpx, !, write(' '),
		(
			(enemyposition(Id,X,Y), write('E'), !);
			(playerposition(X, Y), write('P'), !); 
			(deadzone(X, Y), write('X'), !);
			(existarmor, armorposition(_,X,Y), write('A'),!);
			(existweapon, weaponposition(_,X,Y), write('W'),!);
			
			write('_')
		),
		write(' '), Next_Y is Y + 1, printlook(X, Next_Y));
		X == Endpx
	).

/* armor, weapon, ammo, and medicine places */
existarmor :-
	asserta(armorposition(hat, 5,5)),
	asserta(armorposition(hat, 19,4)),
	asserta(armorposition(vest, 3,14)),
	asserta(armorposition(vest, 17,18)),
	asserta(armorposition(helmet,2,20)),
	asserta(armorposition(kopyah, 4,12)),
	asserta(armorposition(helmet, 5, 13)).
	
existweapon :-
	asserta(weaponposition(ak47,15,15)),
	asserta(weaponposition(pistol,2,3)),
	asserta(weaponposition(watergun,3,2)),
	asserta(weaponposition(sword,12,12)),
	asserta(weaponposition(ak47,10,10)),
	asserta(weaponposition(grenade,15,15)),
	asserta(weaponposition(grenade,3,7)),
	asserta(weaponposition(pistol, 6,6)).
	
existammo :-
	asserta(ammoposition(pistol, 2,4)),
	asserta(ammoposition(pistol, 4,6)),
	asserta(ammoposition(pistol, 5,6)).

existmedicine :- 
    asserta(medicineposition(bandage, 3, 7)),
    asserta(medicineposition(bandage, 6, 15)),
    asserta(medicineposition(bandage, 20, 10)).
	

/*temporary rules */
w :- inc, retract(playerposition(X, Y)), Next_y is Y-1, asserta(playerposition(X, Next_y)).
s :- inc, retract(playerposition(X, Y)), Next_x is X+1, asserta(playerposition(Next_x, Y)).
e :- inc, retract(playerposition(X, Y)), Next_y is Y+1, asserta(playerposition(X, Next_y)).
n :- inc, retract(playerposition(X, Y)), Next_x is X-1, asserta(playerposition(Next_x, Y)).


/*inventory rules */
isiinventory([], 0).
isiinventory([H|T], X) :- isiinventory(T, Y), X is (Y + 1). 

printinventory([]) :- nl.
printinventory([H|[]]) :- write(H), nl. 
printinventory([H|T]) :- write(H), write(', '), printinventory(T).

printisiinventory([]) :- write('Your inventory is empty!'), nl. 
printisiinventory([H|T]) :- printinventory([H|T]).

isada(Object, []) :- false.
isada(Object, [H|T]) :- (Object == H), !.
isada(Object, [H|T]) :- isada(Object, T), !.
isexist(Object) :- retract(inventory(I)), asserta(inventory(I)), isada(Object, I).

del(X,[X|Tail], Tail).
del(X,[Y|Tail], [Y|Tail1]) :- del(X, Tail, Tail1).

removeobject(Object) :- retract(inventory(Inventory)), del(Object, Inventory, Newinventory), asserta(inventory(Newinventory)).

addinventory(Object, X, Y) :- retract(inventory(Inventory)), isiinventory(Inventory, Frek), 
                                (Frek < 10), append([Object], Inventory, TY), asserta(inventory(TY)), write('You took the '), write(Object), write('!'), nl.

addinventory(Object, X, Y) :- retract(inventory(Inventory)), asserta(inventory(Inventory)), isiinventory(Inventory, Frek), 
                                (Frek >= 10), asserta(weaponposition(Object, X, Y)).


/*Armor rules */
addarmor(Armor, X, Y) :- (Armor == 'hat'),retract(armor(Ar)), (Ar + 5 =< 100), asserta(armor(Ar)), write('You took the '), write(Armor),nl.
addarmor(Armor, X, Y) :- (Armor == 'hat'), retract(armor(Ar)), (Ar + 5 > 100), asserta(armor(Ar)), asserta(armorposition(Armor, X, Y)).

addarmor(Armor, X, Y) :- (Armor == 'vest'), retract(armor(Ar)), (Ar + 10 =< 100), asserta(armor(Ar)),  write('You took the '), write(Armor),nl.
addarmor(Armor, X, Y) :- (Armor == 'vest'), retract(armor(Ar)), (Ar + 10 > 100), asserta(armor(Ar)), asserta(armorposition(Armor, X, Y)).

addarmor(Armor, X, Y) :- (Armor == 'helmet'), retract(armor(Ar)), (Ar + 15 =< 100), asserta(armor(Ar)), write('You took the '), write(Armor),nl.
addarmor(Armor, X, Y) :- (Armor == 'helmet'), retract(armor(Ar)), (Ar + 15 > 100), asserta(armor(Ar)), asserta(armorposition(Armor, X, Y)).

addarmor(Armor, X, Y) :- (Armor == 'kopyah'), retract(armor(Ar)), (Ar + 20 =< 100), asserta(armor(Ar)),  write('You took the '), write(Armor),nl.
addarmor(Armor, X, Y) :- (Armor == 'kopyah'), retract(armor(Ar)), (Ar + 20 > 100), asserta(armor(Ar)), asserta(armorposition(Armor, X, Y)).

/*Medicine rules */
addmedicine(Medicine, X, Y) :- (Medicine == 'bandage'), retract(health(H)), (H + 10 =< 100), asserta(health(H)), write('You took the bandage!'), nl.
addmedicine(Medicine, X, Y) :- (Medicine == 'bandage'), retract(health(H)), (H + 10 > 100), asserta(health(H)), asserta(medicineposition(Medicine, X, Y)).


/*player status*/
status :- retract(health(Health)), write('Health: '), H is Health, write(H), nl, asserta(health(H)),
		retract(armor(Armor)), write('Armor: '), A is Armor, write(A), nl, asserta(armor(A)), 
		retract(weapon(Weapon)), write('Weapon: '), write(Weapon), nl, asserta(weapon(Weapon)),
		retract(ammo(Ammo)), write('Ammo: '), Am is Ammo, write(Am), nl, asserta(ammo(Am)),
		retract(inventory(Inventory)), write('Inventory: '), printisiinventory(Inventory), asserta(inventory(Inventory)), !.

/*classify an object */
isweapon(X) :- (X == 'pistol');(X == 'watergun');(X == 'sword');(X == 'grenade');(X == 'ak47').
ismedicine(X) :- (X == 'bandage').
isarmor(X) :- (X == 'hat');(x == 'vest');(x == 'helmet');(x == 'kopyah').

/*take an object and placed it to inventory */
take(X) :- retract(playerposition(PX, PY)), asserta(playerposition(PX, PY)), 
            weaponposition(X, PX, PY), takeweapon(PX, PY), !.
take(X) :- retract(playerposition(PX, PY)), asserta(playerposition(PX, PY)), 
            armorposition(X, PX, PY), takearmor(PX, PY), !.
take(X) :- retract(playerposition(PX, PY)), asserta(playerposition(PX, PY)), 
            medicineposition(X, PX, PY), takemedicine(PX, PY), !.
take(X) :- retract(playerposition(PX, PY)), asserta(playerposition(PX, PY)), 
            ammoposition(X, PX, PY), takeammo(PX, PY), !.
take(X) :- write(X), write(' is not available in this area.'), nl,!.

takeweapon(X, Y) :- retract(weaponposition(Weapon, X, Y)),addinventory(Weapon, X, Y).
takearmor(X, Y) :- retract(armorposition(Armor, X, Y)), addarmor(Armor, X, Y).
takemedicine(X, Y) :- retract(medicineposition(Medicine, X, Y)), addmedicine(Medicine,X,Y).

/*use an object in inventory, and removed it from inventory */
use(X) :- isexist(X), isweapon(X), write(X), write(' is equipped.'), nl, asserta(weapon(X)), removeobject(X), !. 
% use(X) :- isexist(X), (X == 'bandage'), retract(Health(H)), asserta(Health(H+10)), removeobject(X), write('Your Health is increasing 10 unit!'), nl.