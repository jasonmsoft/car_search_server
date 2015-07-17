%%%-------------------------------------------------------------------
%%% @author cdmaji1
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. ÆßÔÂ 2015 10:37
%%%-------------------------------------------------------------------
-module(add_handler).
-author("cdmaji1").
-compile([{parse_transform, lager_transform}]).


%% API
-export([init/2, terminate/3]).


-record(state, {}).


init(Req, _Opts) ->
	{ok, Req, #state{}}.


terminate(_Reason, Req, State) ->
	ok.