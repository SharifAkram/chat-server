%% To send messages to the chat server

-module(chat_server).
-behavior(gen_server).

%% API
-export([start_link/0, join/1, leave/1, send_message/2]).

%% State
-record(state, {clients=[]}).

%% GenServer callbacks
-export([init/1, handle_call/3, handle_call_2/3, handle_cast/2, handle_cast_2/2, handle_info/2, terminate/2, code_change/3]).

%% API functions
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

join(ClientPid) ->
    gen_server:call(?MODULE, {join, ClientPid}).

leave(ClientPid) ->
    gen_server:cast(?MODULE, {leave, ClientPid}).

send_message(ClientPid, Message) ->
    gen_server:cast(?MODULE, {message, ClientPid, Message}).

%% GenServer callbacks
init([]) ->
    {ok, #state{}}.

handle_call({join, ClientPid}, _From, State) ->
    {reply, ok, State#state{clients=[ClientPid | State#state.clients]}}.

handle_call_2({leave, ClientPid}, _From, State) ->
    {reply, ok, State#state{clients=lists:delete(ClientPid, State#state.clients)}}.

handle_cast({leave, ClientPid}, State) ->
    lists:foreach(fun(Client) -> Client ! {chat_message, {leave, ClientPid}} end, State#state.clients),
    {noreply, State}.

handle_cast_2({message, _ClientPid, Message}, State) ->
    lists:foreach(fun(Client) -> Client ! {chat_message, Message} end, State#state.clients),
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% c(chat_server).
%% chat_server:start_link().
%% ClientPid = self().
%% chat_server:join(ClientPid).
%% chat_server:send_message(ClientPid, "Hi mom.").
%% ok
