// Bandwidth Conscious QoS Technical Design Document
// Author: Richard Chen

#set document(title: "Bandwidth Conscious QoS for Edge Computing Gateway")
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "Linux Libertine", size: 11pt)
#set heading(numbering: "1.")
#set par(justify: true)

// Title
#align(center)[
  #text(size: 20pt, weight: "bold")[
    Technical Design Document: Bandwidth Conscious QoS for Edge Computing Gateway
  ]
  #v(0.5em)
  #text(size: 12pt)[
    *Project:* Bandwidth Conscious QoS (bc-qos) \
    *Target Environment:* LTE Edge Gateway / VPN Tunneling Scenarios
  ]
]

#v(1em)
#line(length: 100%)

= Executive Summary

This project addresses the critical challenge of *Bufferbloat* and bandwidth contention in Edge Computing Gateways operating over LTE networks. Due to the highly dynamic nature of LTE bandwidth, static QoS configurations fail to prevent latency spikes during congestion.

We introduce a *Bandwidth Conscious QoS* system that implements an *Adaptive Traffic Control* mechanism. By combining efficient *cBPF classification*, *HTB hierarchical queuing*, and *fq_codel scheduling* with a *passive bandwidth detection algorithm*, the system dynamically shifts the bottleneck from the ISP/LTE network to the local gateway. This ensures low latency and prioritizes critical services (Management, IoT) even under constrained bandwidth conditions.

#line(length: 100%)

= System Architecture

The system operates on an Edge Computing Gateway that connects to the Internet via LTE and establishes a UDP Tunnel to a cloud backend (AWS/EC2). The internal network is managed by OpenVSwitch (OVS) to serve various client types, including Passenger WiFi, Telematics, and Video surveillance.

#figure(
  image("edge-computing-gateway-architecture.png", width: 90%),
  caption: [Edge Computing Gateway Architecture],
) <fig-arch>

== Service Requirements & VLAN Priority

Traffic is segmented into four VLANs based on SSID, each assigned a specific priority level. Critical management traffic is given the highest priority to ensure connectivity stability.

#figure(
  table(
    columns: (1fr, 1fr, 1.2fr, 1.5fr, 1.5fr),
    inset: 8pt,
    align: (left, center, center, left, left),
    stroke: 0.5pt,
    [*SSID*], [*VLAN ID*], [*Priority*], [*Description*], [*Note*],
    [SSID 1], [VLAN 10], [1 (Highest)], [Management Network], [Critical Control Signals],
    [SSID 2], [VLAN 20], [2], [IoT Devices Network], [Telematics Data],
    [SSID 3], [VLAN 30], [3], [Staff Network], [Internal Staff Use],
    [SSID 4], [VLAN 40], [4 (Lowest)], [Guest Network], [Passenger WiFi],
  ),
  caption: [VLAN Priority Assignment],
)

#line(length: 100%)

= Traffic Control Mechanism

To achieve high-performance traffic management in the Linux Kernel Space, the following Traffic Control (TC) components are utilized:

== Hierarchical Queuing (HTB)

We utilize *HTB (Hierarchical Token Bucket)* as the root queuing discipline (qdisc). HTB allows for the definition of guaranteed rates and maximum "ceil" rates for each class, perfectly mapping to the defined VLAN priorities.

#figure(
  image("htb-hierarchy-with-cBPF-filters.png", width: 90%),
  caption: [HTB Hierarchy with cBPF Filters],
) <fig-htb>

== High-Performance Classification (cBPF)

For maximum packet forwarding efficiency, the system employs *cBPF (Classic Berkeley Packet Filter)* instead of traditional u32 or basic filters.

- *Mechanism:* cBPF bytecodes are executed directly within the kernel to parse VLAN tags from packet headers and map them to the corresponding HTB Class IDs (e.g., VLAN 10 → Class 1:10).
- *Benefit:* This provides extremely low-latency classification with minimal CPU overhead.

== Active Queue Management (fq_codel)

*fq_codel (Flow Queue CoDel)* is deployed at the leaf classes of the HTB hierarchy.

- *Flow Queueing:* Ensures fairness between flows (preventing a single user from hogging bandwidth).
- *CoDel:* Actively monitors queue delay (sojourn time) and drops packets when latency becomes excessive, effectively neutralizing bufferbloat.

#line(length: 100%)

= Adaptive Bandwidth Control Strategy

The core innovation of this system is a User Space control loop that dynamically adjusts the HTB `ceil` parameter based on real-time LTE network conditions.

== Passive Bandwidth Detection

Instead of saturating the link with active probes (like iperf), the system uses existing Tunnel Keepalive messages (Echo Request/Response) to calculate throughput passively.

#figure(
  image("echo-request-response-flow-for-bandwidth-estimation.png", width: 90%),
  caption: [Echo Request/Response flow for bandwidth estimation],
) <fig-echo>

*Calculation Formula:*

The data rate is derived from the difference in packet counters ($S$, $S'$ for TX; $R$, $R'$ for RX) over the time interval $Delta t$:

#align(center)[
  #block(
    fill: luma(245),
    inset: 1em,
    radius: 4pt,
  )[
    $ "data rate" = (R' - R) / (Delta t) $
    $ Delta t = t_(S') - t_S $
  ]
]

== Control Logic: The "Pinch" Strategy

The system follows an *AIMD (Additive Increase, Multiplicative Decrease)* approach to manage the HTB ceiling:

+ *Steady State (Line Rate):*
  - *Condition:* $Delta "Tx" approx Delta "Rx"$ (No Packet Loss).
  - *Action:* Set HTB ceil to the hardware/LTE theoretical maximum.
  - *Rationale:* Do not limit user speeds when bandwidth is sufficient.

+ *Congestion Detected (The Pinch):*
  - *Condition:* $Delta "Tx" > Delta "Rx"$ (Packet Loss Detected). This indicates the bottleneck has shifted to the ISP/LTE side.
  - *Action:* Immediately throttle the HTB ceil to the measured Safe Rate ($Delta "Rx" / Delta t$).
  - *Rationale:* This forces the queue buildup back to the local Gateway (tap0), allowing fq_codel to manage the traffic.

+ *Recovery (Slow Release):*
  - *Condition:* Congestion subsides.
  - *Action:* Slowly increase the HTB ceil (Additive Increase).
  - *Rationale:* Prevents oscillation by gradually probing for available bandwidth.

#line(length: 100%)

= Performance Verification

The following results compare the upstream TCP performance of 4 concurrent flows under different queuing disciplines.

== Baseline: Default pfifo

#figure(
  image("tcp-performance-with-default-pfifo-qdisc.jpg", width: 90%),
  caption: [TCP Performance with default pfifo qdisc],
) <fig-pfifo>

- *Observation:* Significant volatility and "global synchronization" drops.
- *Analysis:* The LTE buffer is full, causing indiscriminate packet drops and unstable latency.

== Optimized: Adaptive QoS (HTB + fq_codel)

#figure(
  image("tcp-performance-with-adaptive-htb-fq_codel.jpg", width: 90%),
  caption: [TCP Performance with Adaptive HTB & fq_codel],
) <fig-adaptive>

- *Observation:* Stable "sawtooth" wave patterns with excellent fairness across all 4 clients.
- *Analysis:* The adaptive mechanism successfully constrained the bandwidth to the link's capacity, eliminating bufferbloat and ensuring smooth throughput for all flows.

#pagebreak()

= Appendix: fq_codel Internals

#figure(
  image("fq_codel.drawio.png", width: 100%),
  caption: [Flow Queue CoDel Scheduler Internals],
) <fig-fqcodel>

== Data Structures

*Enqueue Path (Bottom-Left):*
- Incoming SKB is hashed into one of 1024 flow queues
- Each flow maintains its own `deficit` counter and `codel queue`

*Dequeue Path (Top-Left):*
- DRR (Deficit Round Robin) Scheduler polls packets from flows

== Dual-List Design

The scheduler maintains two lists for flow prioritization:

#figure(
  table(
    columns: (1fr, 1.5fr, 2fr),
    inset: 8pt,
    stroke: 0.5pt,
    [*List*], [*Contents*], [*Purpose*],
    [`new_flows`], [Newly active flows], [Priority service for responsiveness],
    [`old_flows`], [Established flows], [Fair sharing via round-robin],
  ),
  caption: [Flow List Classification],
)

== State Machine

Flows transition between three states:

#align(center)[
  #block(
    fill: luma(245),
    inset: 1em,
    radius: 4pt,
  )[
    `empty` $arrow.r^"Arrival"$ `new` $arrow.r^"Empty or Credit Exhausted"$ `old` $arrow.r^"Empty"$ `empty`
  ]
]

== Dequeue Algorithm (Pseudocode)

```c
begin:
    head = &q->new_flows;
    if (list_empty(head)) {
        head = &q->old_flows;
        if (list_empty(head))
            return NULL;
    }
    flow = list_first_entry(head, struct fq_codel_flow, flowchain);

    if (flow->deficit <= 0) {
        flow->deficit += q->quantum;
        list_move_tail(&flow->flowchain, &q->old_flows);
        goto begin;
    }

    skb = codel_dequeue(...);  // CoDel handles latency control

    flow->deficit -= qdisc_pkt_len(skb);
    return skb;
```

== Design Rationale

- *New flows get priority:* Ensures low latency for interactive traffic
- *Deficit Round Robin:* Guarantees fairness among competing flows
- *CoDel at each queue:* Monitors sojourn time and drops packets when latency exceeds threshold, eliminating bufferbloat
