#!/usr/bin/env escript
%% -*- erlang -*-
%%! -sname check_agents -setcookie wombat
-define(WOMBAT, 'wombat@wombat').


main([DestNode0]) ->
    net_kernel:start([node(), shortnames]),
	DestNode = list_to_atom(DestNode0),
    {ok, DestNodeId} = get_node_id(DestNode),
    Result = check_agents(DestNode, DestNodeId),
    io:fwrite("~p~n", [Result]).
    

% ==============================================================
% check all planned agents are working according to the 
% applications currently running on the node
% ==============================================================
check_agents(DestNode, DestNodeId) ->
    Apps = get_running_applications(DestNode),
    SupposedAgents = get_what_agents(Apps),
    {ok, RunningAgents} = get_running_agents(DestNodeId),
    do_check_agents(SupposedAgents, RunningAgents).


% get the running applications from the node
get_running_applications(DestNode) ->
	rpc:call(DestNode, wombat_plugin_controller, which_applications, []).

% check what plugins supposed to run for the specified applications
get_what_agents(Apps) ->
    Agents = rpc:call(?WOMBAT, wo_plugins_master, get_plugins_for_apps, [Apps]),
    [Agent || {Agent, _, _, _} <- Agents].

get_node_id(NodeName) ->
    rpc:call(?WOMBAT, wo_topo, get_nodeid_by_name, [NodeName]).

% get current wombat running agents for a specific node
get_running_agents(NodeId) ->
    rpc:call(?WOMBAT, wo_plugins_node_mgr, plugins_state, [NodeId]).

% compare planned agents with the running ones
do_check_agents(SupposedAgents, CurrentAgents) ->
    lists:foldl(fun(Agent, Acc) -> case lists:keyfind(Agent, 1, CurrentAgents) of
                                        {Agent, _, true} ->  Acc;
                                        {Agent, _, false} -> [Agent|Acc];
                                        _-> [Agent|Acc]
                                   end end, [], SupposedAgents).
    
                                   





