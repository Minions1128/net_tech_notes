# vPC
## Failure Scenarios
### 1. vPC member port fails
下联设备会通过PortChannel感知到故障，会将流量切换到另一个接口上。这种情况下，vPC peer link可能会承载数据流量。
### 2. vPC peer link failure
当keepalive link还可用时，secondary switch会将其所有的member port关闭。
### 3. vPC primary switch failure
Secondary switch会变为可操作的primary switch，当原来的primary switch恢复之后，其又会变为secondary switch
### 4. 