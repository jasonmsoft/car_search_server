%%%-------------------------------------------------------------------
%%% @author cdmaji1
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. ÆßÔÂ 2015 8:33
%%%-------------------------------------------------------------------
-module(search_handler).
-author("cdmaji1").
-compile([{parse_transform, lager_transform}]).

%% API
-export([init/2, terminate/3]).


-record(state, {}).


init(Req, _Opts) ->
	Vars = cowboy_req:parse_qs(Req),
	CarNo1 = case lists:keyfind(<<"carno">>, 1, Vars) of
		{_, CarNo} ->
			CarNo;
		Any ->
			'undefined'
	end,
	Name1 = case lists:keyfind(<<"name">>, 1, Vars) of
		        {_, Name} ->
			        Name;
				_Any ->
					'undefined'
	        end,
	PhoneNo1 = case lists:keyfind(<<"phoneno">>, 1, Vars) of
		           {_, PhoneNo} ->
			           PhoneNo;
		           _Any ->
			           'undefined'
	           end,

	HouseNo1 = case lists:keyfind(<<"houseno">>, 1, Vars) of
		           {_, HouseNo} ->
			           HouseNo;
		           _Any ->
			           'undefined'
	           end,
	Req2 = case create_search_sql(CarNo1, Name1, PhoneNo1, HouseNo1) of
		{error, _R} ->
			cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'error': 'param error'}", Req);
		Sql ->
			Result = search(Sql),
			cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'ok':}", Req)
	end,
	{ok, Req2, #state{}}.


terminate(_Reason, Req, State) ->
	ok.

create_search_sql('undefined', 'undefined', 'undefined', 'undefined') ->
	{error, <<"param error">>};

create_search_sql('undefined', _Name, _PhoneNo, 'undefined') ->
	{error, <<"param error">>};

create_search_sql(CarNo, 'undefined', 'undefined', 'undefined') ->
	<<"select * from carsearch where carno = '", CarNo/binary, "'">>;

create_search_sql('undefined', 'undefined', 'undefined', HouseNo) ->
	<<"select * from carsearch where houseno = '", HouseNo/binary, "'">>;

create_search_sql(CarNo, _Name, _PhoneNo, HouseNo) ->
	<<"select * from carsearch where carno = '", CarNo/binary, "' or houseno = '", HouseNo/binary, "'">>.



search(Sql) ->
	noop.

create_response_body() ->
	noop.