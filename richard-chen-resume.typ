#import "@preview/modern-cv:0.8.0": *

#show: resume.with(
  author: (
    firstname: "Richard",
    lastname: "Chen",
    email: "yingchuan.chen.2007@gmail.com",
    phone: "(+886) 917-527-202",
    github: "yingchuan",
    birth: "August 11th, 1976",
    linkedin: "richard-chen-6034305b",
    address: "No. 406, Yanshou St., Songshan Dist., Taipei",
    positions: (
      "Sytem Engineer",
      "Firmware Developer",
    ),
  ),
  profile-picture: none,
  date: datetime.today().display(),
  language: "en",
  colored-headers: true,
  show-footer: false,
  paper-size: "us-letter",
)

= Experience

#resume-entry(
  title: "Power-Tech Team Lead. Ubiquiti, Inc",
  location: "Room B, 11 F., No. 89, Songren Rd., Xinyi",
  date: "2023/1 - 2025/2",
  title-link: "https://github.com/ui-richard-chen",
)

#resume-item[
  + *Unifi Accessory Visor NPI (MediaTek MT8365)*
    - *Firmware Design and Implement*
      #set enum(numbering: "a)")
      + Developed scripts to efficiently build and manage Docker images and containers for streamlined development and testing.
      + Designed and implemented Rescue OS activation and standard A/B OTA firmware update procedures.
      + Developed UI OTA firmware upgrade scripts and integrated encryption support.
      + Planned and defined eMMC partition layouts.
  + *Power Distribution Hi-Density NPI (MediaTek MT7628)*
    - *Firmware Design and Implement*
      #set enum(numbering: "a)")
      + Implemented LCM screen auto-rotation utilizing gravity detection with a 3-axis accelerometer.
      + Designed and implemented a HAL framework inspired by Device Tree/Overlay Source DSL.
      + Developed drivers for AC/USB outlet control and power metering.
    - *Identified and resolved firmware issues reported by the Support Team.*
  + *Factory Test Plan Development*
    - Collaborated cross-functionally, supporting fixture development, automation script design and implementation.
    - Provided technical guidance to factory engineers, optimizing production line test procedures.
    - Designed and implemented burn-in test frameworks.
  + *Development Test Framework for CI/CD Integration*
    - Built and maintained a development testing environment using Docker, Poetry, and Pytest.
    - Developed automation scripts for remote shell execution via SSH.
]

#resume-entry(
  title: "Senior Firmware Developer. Ubiquiti, Inc",
  location: "Room A, 11 F., No. 89, Songren Rd., Xinyi",
  date: "2019/6 - 2022/12",
  title-link: "https://github.com/ui-richard-chen",
)

#resume-item[
  + *Power Distribution Pro NPI (MediaTek MT7628)*
    - *Firmware Design and Implement*
      #set enum(numbering: "a)")
      + Developed drivers for AC/USB outlet control and power metering.
      + Implemented Nuvoton MCU ISP-programming mode for OTA updates.
      + Enabled persistent storage using pstore (mtdoops/ramoops backend)
  + *Issue Resolution*
    - Addressed and resolved firmware issues reported by the Support Team.
    - Improved IGMP snooping querier functionality on UniFi Switch 16/24/48 PoE Gen2.
    - Enhanced Spanning Tree Protocol (STP) performance on UniFi Switch 48 PoE Gen2.
]

#resume-entry(
  title: "Software Architect and Developer. Lilee System, Inc",
  location: "24F, No.16-1, Xinzhan Rd, Banqiao",
  date: "2017/8 - 2019/6",
)

#resume-item[
  + *LTE QoS Required by HK MTR*
    - *Designed and implemented #link("https://github.com/yingchuan/bc-qos")[Bandwidth-Conscious QoS]*
      #set enum(numbering: "a)")  
      + Maximize available LTE bandwidth to ensure QoS operates efficiently on the edge computing gateway, while maintaining fair and stable TCP flows
]

#resume-entry(
  title: "Software Manager. Lilee Systems, Inc",
  location: "24F, No.16-1, Xinzhan Rd, Banqiao",
  date: "2010/9 - 2017/4",
)

#resume-item[
  + *Designed and implemented an Interface Description Language (IDL) for RPC and Pub/Sub communication across system components.*
  + *Led a development team of six engineers, overseeing software delivery and release cycles.*
  + *Developed proprietary Layer 2 overlay networks.*
  + *Implemented flow-based hashing for load balancing in link aggregation*
]

#resume-entry(
  title: "Senior Software Engineer. NUUO, Inc",
  date: "2010/1 - 2010/9",
)

#resume-item[
  + Designed and developed a cross-platform (Windows/Linux/MacOS) streaming engine for NUUO viewer applications.
  + Created a specialized buffer management module optimized for streaming purposes
]

#resume-entry(
  title: "Senior Software Engineer. QNAP Systems, Inc",
  date: "2008/12 - 2009/10",
)

#resume-item[
  + Performed board bring-up and initial product integration.
  + Developed burn-in factory testing utilities.
  + Backported the ext4 filesystem.
  + Implemented low-level control and management APIs for GUI integration.
]

#resume-entry(
  title: "Senior Software Engineer. Essence Technology Solution, Inc",
  date: "2004/2 - 2008/12",
)

#resume-item[
  + Developed and ported PSTN (FXO/FXS/ISDN) channel drivers for VoIP IPPBX appliances.
  + Implemented FTP Application Layer Gateway (ALG) modules for firewall ASICs.
]

#resume-entry(
  title: "Cisco contractor",
  date: "2002/9 - 2004/9",
)

#resume-item[
  + Developed test tools for Cisco Call Manager, including:
    - RTP Playback functionality.
    - Event-triggered logging with pcap-filter-like functionality.
]

= Skills

#resume-skill-item(
  "Programming Languages",
  (strong("C"), strong("Python"), "bash"),
)
#resume-skill-item("Languages", (strong("Mandarin"), "English"))

= Education

#resume-entry(
  title: "Da-yeh University",
  date: "1996 - 1999",
  description: "B.S. in Electrical Engineer",
)
