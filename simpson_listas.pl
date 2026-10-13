% =====================================================================
% Universidad Tecnologica de Pereira - Programacion III
% Actividad03: Casos con Listas
% EJERCICIO 1: ARBOL GENEALOGICO DE LOS SIMPSON (con estructuras y listas)
% Integrantes: Julian Guadir, Alejandro Ipaz
% =====================================================================
%
% CAMBIO RESPECTO A LA ACTIVIDAD 1:
%   Antes: un hecho suelto por cada relacion (padre/2, madre/2).
%   Ahora: los datos viven en ESTRUCTURAS y LISTAS:
%     - familia(pareja(Padre, Madre), Hijos)   -> estructura con una lista de hijos
%     - hombres([...]) y mujeres([...])        -> listas con el genero
%   padre/2 y madre/2 pasan de ser hechos a ser REGLAS que recorren esas listas.
%   Todas las demas reglas (abuelo, tio, primo, ancestro...) se mantienen
%   igual, por eso el programa responde las mismas consultas.
% =====================================================================

% ---------- Base de conocimiento: estructuras y listas ----------

% 'desconocido' marca el progenitor que no aparece en el arbol.
familia(pareja(abraham,     desconocido), [herbert]).
familia(pareja(abraham,     mona),        [homero]).
familia(pareja(clancy,      jacqueline),  [marge, patty, selma]).
familia(pareja(homero,      marge),       [bart, lisa, maggie]).
familia(pareja(desconocido, selma),       [ling]).

hombres([abraham, herbert, homero, clancy, bart]).
mujeres([mona, jacqueline, marge, patty, selma, lisa, maggie, ling]).

% ---------- Reglas sobre las listas ----------

hombre(X) :- hombres(L), member(X, L).
mujer(X)  :- mujeres(L), member(X, L).

% padre(P, H): P es el padre de H (primer elemento de la pareja)
padre(P, H) :-
    familia(pareja(P, _), Hijos),
    P \== desconocido,
    member(H, Hijos).

% madre(M, H): M es la madre de H (segundo elemento de la pareja)
madre(M, H) :-
    familia(pareja(_, M), Hijos),
    M \== desconocido,
    member(H, Hijos).

% ---------- Reglas de la Actividad 1 (sin cambios) ----------

% progenitor(P, H): P es padre o madre de H
progenitor(P, H) :- padre(P, H).
progenitor(P, H) :- madre(P, H).

hijo(H, P) :- hombre(H), progenitor(P, H).
hija(H, P) :- mujer(H), progenitor(P, H).

% abuelos (2 generaciones)
abuelo(A, N) :- hombre(A), progenitor(A, P), progenitor(P, N).
abuela(A, N) :- mujer(A), progenitor(A, P), progenitor(P, N).

% hermanos (comparten al menos un progenitor)
hermanos(X, Y) :- progenitor(P, X), progenitor(P, Y), X \== Y.
hermano(X, Y) :- hombre(X), hermanos(X, Y).
hermana(X, Y) :- mujer(X), hermanos(X, Y).

% tios: hermanos de un progenitor
tio(T, S) :- hombre(T), progenitor(P, S), hermanos(T, P).
tia(T, S) :- mujer(T), progenitor(P, S), hermanos(T, P).

% sobrinos
sobrino(S, T) :- hombre(S), progenitor(P, S), hermanos(T, P).
sobrina(S, T) :- mujer(S), progenitor(P, S), hermanos(T, P).

% primos: hijos de hermanos
primos(X, Y) :- progenitor(P, X), progenitor(Q, Y), hermanos(P, Q).
primo(X, Y) :- hombre(X), primos(X, Y).
prima(X, Y) :- mujer(X), primos(X, Y).

% ancestros y descendientes (recursivas)
ancestro(A, D) :- progenitor(A, D).
ancestro(A, D) :- progenitor(A, X), ancestro(X, D).
descendiente(D, A) :- ancestro(A, D).

% ---------- Reglas nuevas que devuelven LISTAS ----------

% hijos(P, L): lista de los hijos de P (sin repetidos)
hijos(P, L) :- setof(H, progenitor(P, H), L), !.
hijos(_, []).

% hermanos_de(X, L): lista de hermanos de X
hermanos_de(X, L) :- setof(Y, hermanos(X, Y), L), !.
hermanos_de(_, []).

% abuelos_de(N, L): lista de abuelos y abuelas de N
abuelos_de(N, L) :-
    setof(A, P^(progenitor(A, P), progenitor(P, N)), L), !.
abuelos_de(_, []).

% ancestros_de(D, L): lista de todos los ancestros de D
ancestros_de(D, L) :- setof(A, ancestro(A, D), L), !.
ancestros_de(_, []).

% descendientes_de(A, L): lista de todos los descendientes de A
descendientes_de(A, L) :- setof(D, ancestro(A, D), L), !.
descendientes_de(_, []).

% cantidad_hijos(P, N): numero de hijos de P
cantidad_hijos(P, N) :- hijos(P, L), length(L, N).

% ---------- Consultas de prueba (resultado esperado) ----------
% Las mismas de la Actividad 1:
% ?- padre(homero, bart).        % true
% ?- abuelo(X, bart).            % X = abraham ; X = clancy
% ?- abuela(X, lisa).            % X = mona ; X = jacqueline
% ?- hermano(bart, lisa).        % true
% ?- hermana(X, bart).           % X = lisa ; X = maggie
% ?- tio(herbert, bart).         % true
% ?- tia(X, bart).               % X = patty ; X = selma
% ?- tia(marge, ling).           % true
% ?- primo(bart, ling).          % true
% ?- prima(X, ling).             % X = lisa ; X = maggie
% ?- sobrino(X, patty).          % X = bart
% ?- ancestro(abraham, X).       % herbert, homero, bart, lisa, maggie
% ?- descendiente(ling, X).      % X = selma ; X = clancy ; X = jacqueline
% ?- abuelo(clancy, ling).       % true
% Nuevas (con listas):
% ?- hijos(homero, L).           % L = [bart, lisa, maggie]
% ?- hermanos_de(bart, L).       % L = [lisa, maggie]
% ?- abuelos_de(bart, L).        % L = [abraham, clancy, jacqueline, mona]
% ?- ancestros_de(ling, L).      % L = [clancy, jacqueline, selma]
% ?- descendientes_de(abraham, L). % L = [bart, herbert, homero, lisa, maggie]
% ?- cantidad_hijos(clancy, N).  % N = 3
