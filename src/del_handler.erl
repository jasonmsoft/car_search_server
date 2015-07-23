%%%-------------------------------------------------------------------
%%% @author cdmaji1
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. ���� 2015 10:37
%%%-------------------------------------------------------------------
-module(del_handler).
-author("cdmaji1").
-compile([{parse_transform, lager_transform}]).


%% API
-export([init/2, terminate/3]).


-record(state, {}).


init(Req, _Opts) ->
	lager:info("delete proc, Req: ~p", [Req]),
	lager:info("options :  ~p ", [_Opts]),
	Vars = cowboy_req:parse_qs(Req),
	CarNo = get_value(<<"carno">>, Vars, 'undefined'),
	HouseNo = get_value(<<"houseno">>, Vars, 'undefined'),
	lager:info("carno ~p houseno ~p", [CarNo, HouseNo]),
	case create_delete_sql(CarNo, HouseNo) of
		{error, R} ->
			lager:error("param error when delete ~p", [R]),
			cowboy_req:reply(200, [{<<"content-type">>, <<"application/json;charset=utf-8">>}],<<"{'errro': 'param error'}">>, Req),
			{ok, Req, #state{}};
		Sql ->
			lager:info("delete sql is : ~p", [Sql]),
			delete(Sql),
			cowboy_req:reply(200, [{<<"content-type">>, <<"application/json;charset=utf-8">>}],<<"{'ok': 'delete success'}">>, Req),
			{ok, Req, #state{}}
	end.



get_value(Key, Vars, Default) ->
	case lists:keyfind(Key, 1, Vars) of
		'false' ->
			Default;
		{_, Value} ->
			Value
	end.


delete(_Sql) ->
	car_search_server:execute_sql(_Sql).


create_delete_sql('undefined', 'undefined') ->
	{error, <<"param error">>};
create_delete_sql(CarNo, 'undefined') ->
	<<"delete from car_info where carno = '", CarNo/binary, "'">>;
create_delete_sql('undefined', HouseNo) ->
	<<"delete from car_info where houseno = '", HouseNo/binary, "'">>;
create_delete_sql(CarNo, HouseNo) ->
	<<"delete from car_info where houseno = '", HouseNo/binary, "' and carno = '", CarNo, "' ">>.



terminate(_Reason, _Req, _State) ->
	ok.