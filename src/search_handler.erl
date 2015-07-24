%% -*- coding: utf-8 -*-
%%%-------------------------------------------------------------------
%%% @author cdmaji1
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created :  2015 8:33
%%%-------------------------------------------------------------------
-module(search_handler).
-author("cdmaji1").
-compile([{parse_transform, lager_transform}]).

%% API
-export([init/2, terminate/3]).


-record(state, {}).


init(Req, _Opts) ->
	lager:info("search proc, Req: ~p", [Req]),
	lager:info("options :  ~p ", [_Opts]),

	Vars = cowboy_req:parse_qs(Req),

	lager:debug("req parse result : ~p", [Vars]),

	CarNo1 = get_value(<<"carno">>, Vars, 'undefined'),
	Name1 = get_value(<<"name">>, Vars, 'undefined'),
	PhoneNo1 = get_value(<<"phoneno">>, Vars, 'undefined'),
	HouseNo1 = get_value(<<"houseno">>, Vars, 'undefined'),
	Req2 = case create_search_sql(CarNo1, Name1, PhoneNo1, HouseNo1) of
		{error, _R} ->
			cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'error': 'param error'}", Req);
		Sql ->
			case search(Sql) of
				{ok, Result} ->
					JsonResult = jsx:encode([{<<"ok">>, Result}]),
					lager:debug("json result : ~s", [JsonResult]),
					cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], JsonResult, Req);
				_Any ->
					BinRet = <<"{'error': 'not found'}">>,
					cowboy_req:reply(200, [{<<"content-type">>, <<"application/json;charset=utf-8">>}],BinRet, Req)
			end
	end,
	{ok, Req2, #state{}}.


terminate(_Reason, _Req, _State) ->
	ok.

create_search_sql('undefined', 'undefined', 'undefined', 'undefined') ->
	{error, <<"param error">>};

create_search_sql('undefined', _Name, _PhoneNo, 'undefined') ->
	{error, <<"param error">>};

create_search_sql(CarNo, _Name, _PhoneNo, 'undefined') ->
	<<"select * from car_info where carno = '", CarNo/binary, "'">>;

create_search_sql('undefined', _Name, _PhoneNo, HouseNo) ->
	<<"select * from car_info where houseno = '", HouseNo/binary, "'">>;

create_search_sql(CarNo, _Name, _PhoneNo, HouseNo) ->
	<<"select * from car_info where carno = '", CarNo/binary, "' and houseno = '", HouseNo/binary, "'">>.



search(_Sql) ->
	car_search_server:execute_sql(_Sql).


get_value(Key, Vars, Default) ->
	case lists:keyfind(Key, 1, Vars) of
		'false' ->
			Default;
		{_, Value} ->
			Value
	end.



create_response_body(Result) ->
	noop.