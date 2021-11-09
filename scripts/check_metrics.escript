#!/usr/bin/env escript
%% -*- erlang -*-
%%! -sname check_metrics -setcookie wombat
-define(WOMBAT, 'wombat@wombat').
-define(WO_METRICS_INFO, 'node_mgr_metrics_info').

main([DestNode0]) ->
    net_kernel:start([node(), shortnames]),
	DestNode = list_to_atom(DestNode0),
    {ok, DestNodeId} = get_node_id(DestNode),
    Result = check_metrics(DestNodeId),
    io:fwrite("~p~n", [Result]).
    


get_node_id(NodeName) ->
    rpc:call(?WOMBAT, wo_topo, get_nodeid_by_name, [NodeName]).

% ==============================================================
% check all agents are running the metrics that are supposed 
% to run accoding to the capabilities being announced
% ==============================================================

check_metrics(NodeId) ->
    Capabilities = get_metrics_capabilities(NodeId),
    RunningMetrics = get_running_metrics(NodeId),
    do_check_metrics(Capabilities, RunningMetrics).

get_metrics_capabilities(NodeId)->
    [{_, _, _, {ok, MetricsGroups}}] = rpc:call(?WOMBAT, ets, lookup, [?WO_METRICS_INFO, NodeId]),
    MetricsCategories = extract_metrics_categories(MetricsGroups),
    MetricsData =  get_metrics_data(MetricsCategories),
    get_metrics_names(MetricsData).

extract_metrics_categories(MetricsGroups) ->
    lists:flatten([Categories|| {metric_group, _GroupName, _Desc, Categories} <- MetricsGroups]).

get_metrics_data(MetricsCategories) -> 
    lists:flatten([MetricsData || {metric_category, _Category, MetricsData} <- MetricsCategories]).

get_metrics_names(MetricsData) ->
    [MetricName|| {metric_data, MetricName, _, _, _, _, _} <- MetricsData].

get_running_metrics(NodeId) ->
    NodeIdBin = list_to_binary(NodeId),
    RunningMetrics0 = rpc:call(?WOMBAT, wo_metrics_db_seq, get_active_metric_info, [NodeIdBin]),
    RunningMetrics1 = dict:to_list(RunningMetrics0),
    [Metric || {Metric, _} <- RunningMetrics1].

do_check_metrics(Capabilities, RunningMetrics) ->
    lists:foldl(fun(Metric, Acc) -> 
                    case lists:member(Metric, RunningMetrics) of 
                        true -> Acc; 
                        false -> [Metric|Acc] 
                    end end, [], Capabilities).

 
