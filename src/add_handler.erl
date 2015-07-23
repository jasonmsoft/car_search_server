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
	lager:info("add proc, Req: ~p", [Req]),
	lager:info("options :  ~p ", [_Opts]),
	case cowboy_req:has_body(Req) of
		'false' ->
			lager:error("add operation's body is null"),
			{ok, Req, #state{}};
		'true' ->
			case cowboy_req:body(Req) of
				{ok, Body, Req2} ->
					case jsx:is_json(Body) of
						'true' ->
							JObj = jsx:decode(Body),
							lager:debug("add post body: ~p", [JObj]),
							CarNo = get_value(<<"carno">>, {JObj}, 'undefined'),
							Name = get_value(<<"name">>, {JObj}, 'undefined'),
							PhoneNo = get_value(<<"phoneno">>, {JObj}, 'undefined'),
							HouseNo = get_value(<<"houseno">>, {JObj}, 'undefined'),
							lager:debug("do add, Carno:~ts name:~ts phoneno:~s houseno: ~s", [CarNo, Name, PhoneNo, HouseNo]),
							case create_sql(CarNo, Name, PhoneNo, HouseNo) of
								{error, _R} ->
									lager:error("param error"),
									cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'error': 'param error'}", Req2),
									{ok, Req, #state{}};
								Sql ->
									case insert(Sql) of
										{ok, _} ->
											cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'ok': 'insert success'}", Req2),
											{ok, Req, #state{}};
										_Any ->
											lager:error("insert error"),
											cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'error': 'insert error'}", Req2),
											{ok, Req, #state{}}
									end
							end;
						'false'->
							cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], "{'error': 'param is not json'}", Req2),
							lager:error("add operation's body is not json format"),
							{ok, Req, #state{}}
					end;
				_Any ->
					lager:error("read body error, ~p", [_Any]),
					{ok, Req, #state{}}
			end
	end.


get_value(Key, JObj, Default) ->
	case JObj of
		{PropList} ->
			proplists:get_value(Key, PropList, Default);
		_Any ->
			Default
	end.



create_sql('undefined', 'undefined', 'undefined', 'undefined') ->
	{error, <<"param error">>};
create_sql('undefined', _Name, _PhoneNo, _HouseNo) ->
	{error, <<"param error">>};
create_sql(_CarNo, _Name, _PhoneNo, 'undefined') ->
	{error, <<"param error">>};
create_sql(_CarNo, _Name, 'undefined', _HouseNo) ->
	{error, <<"param error">>};
create_sql(CarNo, 'undefined', PhoneNo, HouseNo) ->
	<<"insert into car_info(carno, phoneno, houseno) values( '", CarNo/binary, "', '", PhoneNo/binary, "', '" ,HouseNo/binary,  "')">>;
create_sql(CarNo, Name, PhoneNo, HouseNo) ->
	<<"insert into car_info(carno, ownername, phoneno, houseno) values( '", CarNo/binary, "', '", Name/binary, "', '", PhoneNo/binary, "', '" ,HouseNo/binary,  "')" >>.



insert(_Sql) ->
	car_search_server:execute_sql(_Sql).


terminate(_Reason, Req, State) ->
	ok.