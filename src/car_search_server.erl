%%%-------------------------------------------------------------------
%%% @author cdmaji1
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(car_search_server).
-author("cdmaji1").
-compile([{parse_transform, lager_transform}]).
-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3,
	execute_sql/1]).

-export([start/0, test/0]).

-define(SERVER, ?MODULE).

-record(state, {}).







%%%===================================================================
%%% API
%%%===================================================================
start() ->
	io:format("start car_search_server .. ~n"),
	application:start(?MODULE),
	io:format("app start over ~n").

test()->
	io:format("test .. ~n").


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
	{ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
	io:format("start deps start ..... ~n"),
	start_deps(),
	lager:info("##########car_Search_server start deps over"),
	Ret = gen_server:start_link({local, ?SERVER}, ?MODULE, [], []),
	lager:info("##########car_Search_server start ret ~p", [Ret]),
	Ret.



start_deps() ->
	io:format("start car_search_server really start .. ~n"),
	lager:start(),
	lager:info("deps start ........."),
	RetC = application:start(crypto),
	lager:info("deps crypto start ......... ~p ", [RetC]),
	Ret1 = application:start(cowlib),
	lager:info("deps cowlib start ......... ~p ", [Ret1]),
	Ret2 =  application:start(ranch),
	lager:info("deps ranch start ......... ~p ", [Ret2]),
	Ret = application:start(cowboy),
	lager:info("cowboy start result : ~p", [Ret]),
	Dispatch = cowboy_router:compile([
		{'_', [{"/search", search_handler, []},
			{"/add", add_handler, []},
			{"/del", del_handler, []}]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8889}],
		[{env, [{dispatch, Dispatch}]}]
	),
	ok = application:start(emysql),

	lager:debug("emysql start over!!!!"),

	emysql:add_pool('car_search_pool', [{size,1},
		{user,"root"},
		{password,"123456"},
		{database,"car_search"},
		{encoding,utf8},
		{host,"10.28.163.96"}]),
	lager:debug("depends start over!!!!")
.


execute_sql(Sql) ->
	lager:debug("execute sql ~p", [Sql]),
	gen_server:call(?MODULE, {'execute_sql', Sql}).









%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
	{ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term()} | ignore).
init([]) ->
	lager:info("start search server init..."),
	{ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
State :: #state{}) ->
	{reply, Reply :: term(), NewState :: #state{}} |
	{reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
	{stop, Reason :: term(), NewState :: #state{}}).

handle_call({'execute_sql', Sql}, _From, State) ->
	lager:debug("execute sql  ~p ", [Sql]),
	Result = emysql:execute('car_search_pool', Sql),
	{reply, {ok, Result}, State};

handle_call(_Request, _From, State) ->
	lager:info("unhandle call request ~p", [_Request]),
	{reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
	{noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
	{noreply, NewState :: #state{}} |
	{noreply, NewState :: #state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
	{noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
State :: #state{}) -> term()).
terminate(_Reason, _State) ->
	ok = cowboy:stop_listener('car_search_listener'),
	lager:info("car_search terminate .... ~p ", [_Reason]),
	ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
Extra :: term()) ->
	{ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
