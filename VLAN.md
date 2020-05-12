- 华为、华三交换机的Access，Hybrid和Trunk模式的收发规则

| 端口模式 | 收发 | Tag状态 | 交换机处理 |
| ------------ | ------------ | ------------ | ------------ |
| Access | 接受 | Tagged=PVID | 不接受（部分高端产品可能接受） |
| Access | 接受 | Tagged≠PVID | 不接受（部分高端产品可能接受） |
| Access | 接受 | Untagged | 接受，增加Tag=PVID |
| Access | 发送 | Tagged=PVID | 转发，删除Tag |
| Access | 发送 | Tagged≠PVID | 不转发，不处理 |
| Access | 发送 | Untagged | 无此情况 |
| Trunk | 接受 | Tagged=PVID | 接受，不修改Tag |
| Trunk | 接受 | Tagged≠PVID | 接受，不修改Tag |
| Trunk | 接受 | Untagged | 无此情况 |
| Trunk | 发送 | Tagged=PVID | 转发，删除Tag |
| Trunk | 发送 | Tagged≠PVID | 转发，不修改Tag |
| Trunk | 发送 | Untagged | 无此情况 |
| Hybrid | 接受 | Tagged=PVID | 接受，不修改Tag，对端是Trunk |
| Hybrid | 接受 | Tagged≠PVID | 接受，不修改Tag，对端是Trunk |
| Hybrid | 接受 | Untagged | 接受，添加Tag=PVID |
| Hybrid | 发送 | Tagged=PVID | 转发，查看Tagged和Untagged列表 |
| Hybrid | 发送 | Tagged≠PVID | 转发，查看Tagged和Untagged列表 |
| Hybrid | 发送 | Untagged | 无此情况 |
