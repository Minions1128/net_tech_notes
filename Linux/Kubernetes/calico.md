# 报文处理流程

```
PREROUTING@raw
PREROUTING@mangle
PREROUTING@nat
-Routing Decision-
FORWARD@mangle
FORWARD@filter
-Routing Decision-
POSTROUTING@mangle
POSTROUTING@nat
```
```
calicoctl config get -Name

 Name            | Scope       | Value                                  |
-----------------+-------------+----------------------------------------+
 logLevel        | global,node | none,debug,info,warning,error,critical |
 nodeToNodeMesh  | global      | on,off                                 |
 asNumber        | global      | 0-4294967295                           |
 ipip            | global      | on,off                                 |
```

```
1. Felix,                       the primary calico agent that runs on each machine that hosts endpoints.
2. etcd,                        the data store.
3. BIRD,                        a BGP client that distributes routing information.
4. BGP Route Reflector (BIRD),  an optional BGP route reflector for higher scale.
5. The Orchestrator plugin,     orchestrator-specific code that tightly integrates calico into that orchestrator.
```
