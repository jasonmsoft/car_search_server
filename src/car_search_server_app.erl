-module(car_search_server_app).


-compile([{parse_transform, lager_transform}]).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).


%% ===================================================================
%% custom functions
%% ===================================================================
start() ->
    application:start(?MODULE).


%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    car_search_server_sup:start_link().

stop(_State) ->
    ok.

