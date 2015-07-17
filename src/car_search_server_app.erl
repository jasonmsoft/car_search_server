-module(car_search_server_app).


-compile([{parse_transform, lager_transform}]).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).


%% ===================================================================
%% custom functions
%% ===================================================================


%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    io:format("application start ..... ~n"),
    car_search_server_sup:start_link().

stop(_State) ->
    ok.

