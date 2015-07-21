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

	CarNo1 = case lists:keyfind(<<"carno">>, 1, Vars) of
		{_, CarNo} ->
			CarNo;
		_ ->
			'undefined'
	end,
	Name1 = case lists:keyfind(<<"name">>, 1, Vars) of
		        {_, Name} ->
			        Name;
				_ ->
					'undefined'
	        end,
	PhoneNo1 = case lists:keyfind(<<"phoneno">>, 1, Vars) of
		           {_, PhoneNo} ->
			           PhoneNo;
		           _ ->
			           'undefined'
	           end,

	HouseNo1 = case lists:keyfind(<<"houseno">>, 1, Vars) of
		           {_, HouseNo} ->
			           HouseNo;
		           _ ->
			           'undefined'
	           end,
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
					lager:error("search result error , ~p", [_Any])
			end
	end,
	{ok, Req2, #state{}}.


terminate(_Reason, _Req, _State) ->
	ok.

create_search_sql('undefined', 'undefined', 'undefined', 'undefined') ->
	{error, <<"param error">>};

create_search_sql('undefined', _Name, _PhoneNo, 'undefined') ->
	{error, <<"param error">>};

create_search_sql(CarNo, 'undefined', 'undefined', 'undefined') ->
	<<"select * from car_info where carno = '", CarNo/binary, "'">>;

create_search_sql('undefined', 'undefined', 'undefined', HouseNo) ->
	<<"select * from car_info where houseno = '", HouseNo/binary, "'">>;

create_search_sql(CarNo, _Name, _PhoneNo, HouseNo) ->
	<<"select * from car_info where carno = '", CarNo/binary, "' or houseno = '", HouseNo/binary, "'">>.



search(_Sql) ->
	car_search_server:execute_sql(_Sql).

create_response_body(Result) ->
	noop.