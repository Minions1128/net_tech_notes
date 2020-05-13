# Segment Routing

- 驱动力
    - LDP 与 IGP 同步问题: 要考虑 LDP 与 IGP 的配置, 状态的一致性
    - RSVP TE 问题:
        - 扩展性不好, 需要建立tunnel
        - ECMP支持不好

- 原理简介
    - 源路由: RSVP TE
    - 无状态: 不需要中间节点的状态
