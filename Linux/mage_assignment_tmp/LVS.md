# LVS

- lvs集群的类型:
    - lvs-nat: 修改请求报文的目标IP; 多目标IP的DNAT;
    - lvs-dr: 操纵封装新的MAC地址;
    - lvs-tun: 在原请求IP报文之外新加一个IP首部;
    - lvs-fullnat: 修改请求报文的源和目标IP;

- lvs-nat: 多目标IP的DNAT, 通过将请求报文中的目标地址和目标端口修改为某挑出的RS的RIP和PORT实现转发;
    - (1) RIP和DIP必须在同一个IP网络, 且应该使用私网地址; RS的网关要指向DIP;
    - (2) 请求报文和响应报文都必须经由Director转发; Director易于成为系统瓶颈;
    - (3) 支持端口映射, 可修改请求报文的目标PORT;
    - (4) vs必须是Linux系统, rs可以是任意系统;
    - CIP --> VIP --> RIP -(Director)-> CIP

- lvs-dr: Direct Routing, 直接路由; 通过为请求报文重新封装一个MAC首部进行转发, 源MAC是DIP所在的接口的MAC, 目标MAC是某挑选出的RS的RIP所在接口的MAC地址; 源IP/PORT, 以及目标IP/PORT均保持不变; Director和各RS都得配置使用VIP;
    - (1) 确保前端路由器将目标IP为VIP的请求报文发往Director:
        - (a) 在前端网关做静态绑定;
        - (b) 在RS上使用arptables;
        - (c) 在RS上修改内核参数以限制arp通告及应答级别;
            - arp_announce
            - arp_ignore
    - (2) RS的RIP可以使用私网地址, 也可以是公网地址; RIP与DIP在同一IP网络; RIP的网关不能指向DIP, 以确保响应报文不会经由Director;
    - (3) RS跟Director要在同一个物理网络;
    - (4) 请求报文要经由Director, 但响应不能经由Director, 而是由RS直接发往Client;
    - (5) 不支持端口映射;
    - CIP --> VIP --> RIP --> CIP
    - CMAC -...-> VMAC --> RMAC -..-> CMAC

- lvs-tun: 转发方式: 不修改请求报文的IP首部(源IP为CIP, 目标IP为VIP), 而是在原IP报文之外再封装一个IP首部(源IP是DIP, 目标IP是RIP), 将报文发往挑选出的目标RS; RS直接响应给客户端(源IP是VIP, 目标IP是CIP);
    - (1) DIP, VIP, RIP都应该是公网地址;
    - (2) RS的网关不能, 也不可能指向DIP;
    - (3) 请求报文要经由Director, 但响应不能经由Director;
    - (4) 不支持端口映射;
    - (5) RS的OS得支持隧道功能;
    - CIP -- VIP, DIP(tun CIP) --> RIP(tun VIP), VIP --> CIP

- lvs-fullnat: 通过同时修改请求报文的源IP地址和目标IP地址进行转发;
    - (1) VIP是公网地址，RIP和DIP是私网地址，且通常不在同一IP网络; 因此，RIP的网关一般不会指向DIP;
    - (2) RS收到的请求报文源地址是DIP，因此，只能响应给DIP; 但Director还要将其发往Client;
    - (3) 请求和响应报文都经由Director;
    - (4) 支持端口映射;
    - 注意: 此类型默认不支持;
    - CIP --> VIP, DIP(nat CIP) --> RIP(nat VIP), VIP --> CIP
