% =====================================================================
% Universidad Tecnologica de Pereira - Programacion III
% Actividad03: Casos con Listas
% EJERCICIO 2: CIUDADES DE CANADA - GRAFO DIRIGIDO (con estructuras y listas)
% Integrantes: Julian Guadir, Alejandro Ipaz
% =====================================================================
%
% CAMBIO RESPECTO A LA ACTIVIDAD 2:
%   Antes: un hecho arista/3 por cada conexion y un hecho nodo/1 por ciudad.
%   Ahora: el grafo completo es UNA lista de estructuras arista(O, D, Costo)
%   y los nodos son UNA lista de ciudades. arista/3 y nodo/1 pasan a ser
%   REGLAS que recorren esas listas, asi camino/3, conectado/3,
%   tiene_aristas/1 y costo_via/4 funcionan sin cambios en su uso.
% =====================================================================

% ---------- Base de conocimiento: estructuras y listas ----------

% grafo(Aristas): lista de estructuras arista(Origen, Destino, Costo)
grafo([ arista(vancouver, edmonton, 16),
        arista(vancouver, calgary,  13),
        arista(calgary,   edmonton,  4),
        arista(edmonton,  saskatoon, 12),
        arista(saskatoon, calgary,   9),
        arista(calgary,   regina,   14),
        arista(regina,    saskatoon, 7),
        arista(saskatoon, winnipeg, 20),
        arista(regina,    winnipeg,  4) ]).

% nodos(Ciudades): lista de vertices del grafo
nodos([vancouver, edmonton, calgary, saskatoon, regina, winnipeg]).

% ---------- Reglas sobre las listas ----------

% arista(O, D, C): hay una conexion de O a D con costo C
arista(O, D, C) :- grafo(G), member(arista(O, D, C), G).

% nodo(N): N es una ciudad del grafo
nodo(N) :- nodos(L), member(N, L).

% ---------- Reglas de la Actividad 2 (misma logica) ----------

% camino(X, Y, C): existe un camino de X a Y con costo total C.
% Se lleva una lista de visitados para evitar ciclos.
camino(X, Y, C) :- camino(X, Y, [X], C).

camino(X, Y, _, C) :-
    arista(X, Y, C).
camino(X, Y, V, C) :-
    arista(X, Z, C1),
    Z \== Y,
    \+ member(Z, V),
    camino(Z, Y, [Z|V], C2),
    C is C1 + C2.

% conectado(X, Y, C): nodos alcanzables desde X y el costo de cada ruta.
conectado(X, Y, C) :-
    nodo(Y),
    X \== Y,
    camino(X, Y, C).

% tiene_aristas(X): el nodo X tiene al menos una arista (saliente o entrante).
tiene_aristas(X) :- arista(X, _, _), !.
tiene_aristas(X) :- arista(_, X, _), !.

% costo_via(X, Y, Z, C): costo de ir de X a Z pasando por Y.
costo_via(X, Y, Z, C) :-
    camino(X, Y, C1),
    camino(Y, Z, C2),
    C is C1 + C2.

% ---------- Reglas nuevas que usan LISTAS ----------

% ruta(X, Y, R, C): igual que camino/3 pero R es la LISTA de ciudades
% recorridas, de X a Y.
ruta(X, Y, R, C) :- ruta(X, Y, [X], R, C).

ruta(X, Y, V, R, C) :-
    arista(X, Y, C),
    reverse([Y|V], R).
ruta(X, Y, V, R, C) :-
    arista(X, Z, C1),
    Z \== Y,
    \+ member(Z, V),
    ruta(Z, Y, [Z|V], R, C2),
    C is C1 + C2.

% vecinos(X, L): lista de ciudades a las que se llega directo desde X
vecinos(X, L) :- findall(Y, arista(X, Y, _), L).

% alcanzables(X, L): lista (sin repetidos) de ciudades alcanzables desde X
alcanzables(X, L) :- setof(Y, C^conectado(X, Y, C), L), !.
alcanzables(_, []).

% costos(X, Y, L): lista ordenada de los costos de todos los caminos X -> Y
costos(X, Y, L) :- setof(C, camino(X, Y, C), L), !.
costos(_, _, []).

% camino_minimo(X, Y, R, C): ruta de menor costo entre X e Y
camino_minimo(X, Y, R, C) :-
    findall(C0-R0, ruta(X, Y, R0, C0), Pares),
    Pares \== [],
    keysort(Pares, [C-R|_]).

% ---------- Consultas de prueba (resultado esperado) ----------
% Las mismas de la Actividad 2:
% ?- camino(saskatoon, vancouver, C).        % false
% ?- conectado(regina, N, C).                % N = saskatoon, C = 7 ; ...
% ?- tiene_aristas(regina).                  % true
% ?- costo_via(vancouver, calgary, winnipeg, C).
% ?- camino(edmonton, calgary, C).           % C = 21
% Nuevas (con listas):
% ?- ruta(edmonton, calgary, R, C).          % R = [edmonton, saskatoon, calgary], C = 21
% ?- vecinos(calgary, L).                    % L = [edmonton, regina]
% ?- alcanzables(regina, L).
% ?- camino_minimo(vancouver, winnipeg, R, C).
