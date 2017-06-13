# vPC
## Failure Scenarios
### 1. vPC member port fails
下联设备会通过PortChannel感知到故障，会将流量切换到另一个接口上。这种情况下，vPC peer link可能会承数据流量。
### 2. vPC peer link failure
当keepalive link还可用时，secondary switch会将其所有的member port关闭。
### 3. vPC primary switch failure
Secondary switch会变为可操作的primary switch，当原来的primary switch恢复之后，其又会变为secondary switch
### 4. vPC keepalive link failure
其流量不会造成影响，但建议尽早修复
### 5. vPC keepalive link and peer link both failure
如果vPC keepalive link先down，然后peer link跟着down，primary和secondary switch同时成为primary switch，即脑裂。现有流量不会造成影响，但新的流量就不可用。同时单播mac地址和IGMP组，因此其无法维持单播和组播的转发，还可能导致duplicate包。
