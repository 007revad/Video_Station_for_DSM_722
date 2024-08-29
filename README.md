# <img src="images/VideoStation_64.png" width="40"> Video Station for DSM 7.2.2

<a href="https://github.com/007revad/Video_Station_for_DSM_722/releases"><img src="https://img.shields.io/github/release/007revad/Video_Station_for_DSM_722.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FVideo_Station_for_DSM_722&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/paypalme/007revad)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Script to install Video Station in DSM 7.2.2

Coming very soon :o) 

Synology's Video Station package has been installed more than 66 million times so there are a lot people very annoyed that Synology decided to abandon Video Station when DSM 7.2.2 was released. Many of those people are saying they will never buy another Synology NAS. So I decided to make it possible to install Video Station in DSM 7.2.2 for people who really want Video Station.

#### NOTE

To get Video Station to work the script needs to install an older version of AME... which means Drive, Photos may not work unless you install older versions of them.

<p align="center">Video Station installed in DSM 7.2.2</p>
<p align="center"><img src="/images/installed-1.png"></p>

<p align="center"><img src="/images/installed-3.png"></p>

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/Video_Station_for_DSM_722/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

### To run the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

```YAML
sudo -s /volume1/scripts/videostation_for_722.sh
```

**Note:** Replace /volume1/scripts/ with the path to where the script is located.
