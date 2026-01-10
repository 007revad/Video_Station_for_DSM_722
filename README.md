# <img src="images/VideoStation_64.png" width="40"> Video Station for DSM 7.2.2 and DSM 7.3.x

<a href="https://github.com/007revad/Video_Station_for_DSM_722/releases"><img src="https://img.shields.io/github/release/007revad/Video_Station_for_DSM_722.svg"></a>
![Badge](https://hitscounter.dev/api/hit?url=https%3A%2F%2Fgithub.com%2F007revad%2FVideo_Station_for_DSM_722&label=Visitors&icon=github&color=%23198754&message=&style=flat&tz=Australia%2FSydney)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/paypalme/007revad)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
<!-- [![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad) -->

The Video Station icon above is Copyright © 2004-2026 [Synology Inc.](https://kb.synology.com/en-br/DSM/help/DSM/Home/about?version=7)

### Description

Script to install Video Station in DSM 7.2.2, 7.3, 7.3.1 and 7.3.2

Also installs the DSM 7.2.1 version of Advanced Media Codecs so that Synology Photos can create thumbnails of HEIC photos.

Synology's Video Station package has been installed more than 66 million times so there are a lot people very annoyed that Synology decided to abandon Video Station when DSM 7.2.2 was released. Many of those people are saying they will never buy another Synology NAS. So I decided to make it possible to install Video Station in DSM 7.2.2, 7.3, 7.3.1 and 7.3.2 for people who really want Video Station.

This script installs Video Station 3.1.0-3153 and Advanced Media Extensions 3.1.0-3005

Now also installs Media Server 2.0.5-3152 which supports video and audio conversion.

**HEIC for Synology Photos:** After running this script and enabling HEVC decoding in Advanced Media Extensions Synology Photos will be able to create thumbnails for HEIC photos again (you can then uninstall Video Station and/or Media Server if you don't need them).

**UPDATE:** Version 1.3.12 and later has a menu where you can select to only install Advanced Media Codecs, or skip installing Media Server or Video Station. See 
<a href="#Screenshots">Screenshots</a>

> **Warning** <br>
> Recent zero-days security exploits were found in [Synology Photos](https://www.synology.com/en-us/security/advisory/Synology_SA_24_19) and [Synology Drive Server](https://www.synology.com/en-global/security/advisory/Synology_SA_24_21) and quickly patched by Synology. <br>
> Synology has not made Video Station [End-Of-Life](https://www.synology.com/en-us/products/status?tab=software), as it is still available for DSM 7.2 and 7.2.1 which are both still getting security updates, so Synology should patch Video Station if any security exploits are found.

<br>

**<p align="center">Video Station installed in DSM 7.2.2</p>**
<!-- <p align="center"><img src="/images/installed-1.png"></p> -->

<p align="center"><img src="/images/installed-3.png"></p>

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/Video_Station_for_DSM_722/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

### Options when running the script

There are optional flags you can use when running the script:
```
Options:
  -h, --help            Show this help message
  -v, --version         Show the script version
      --install=OPTION  Automatically install OPTION (for use when scheduled)
                        OPTION can be either: 
                          'all' to install Video Station, Media Server and
                            Advanced Media Codecs
                          'novs' to install all except Video Station
                          'noms' to install all except Media Server
                          'onlyamc' to only install Advanced Media Codecs
                        Examples:
                          videostation_for_722.sh --install=all
                          videostation_for_722.sh --install=novs
                          videostation_for_722.sh --install=noms
                          videostation_for_722.sh --install=onlyamc
```

### To run the script via task scheduler

See [How to run from task scheduler](https://github.com/007revad/Video_Station_for_DSM_722/blob/main/how_to_run_from_scheduler.md)

### To run the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

```YAML
sudo -s /volume1/scripts/videostation_for_722.sh
```

**Note:** Replace /volume1/scripts/ with the path to where the script is located.

<p align="center"><img src="/images/script_v1-1.png"></p>

### After running the script

Enable HEVC decoding:
1. Open Package Center > Installed.
2. Click Advanced Media Extensions.
3. Click on Open.
4. You may need to [Sign in to your Synology account](https://github.com/007revad/Video_Station_for_DSM_722/blob/main/syno_account_sign_in.md)
5. Click on Install then OK.

<p align="center"><img src="/images/enable_hevc.png"></p>

### What about DTS, EAC3 and TrueHD Audio?

You can install FFmpeg 7 from SynoCommunity. See [Easy Install](https://synocommunity.com/#easy-install) to add SynologyCommunity package repository to Package Center.

<p align="center"><img src="/images/ffmpeg7.png"></p>

Then you have a choice of two official Wrappers:
</br>

1) Download  the latest release from https://github.com/AlexPresso/VideoStation-FFMPEG-Patcher and unzip it.

    - Then run VideoStation-FFMPEG-Patcher with the `-v 7` option:
    ```YAML
    sudo -s /volume1/scripts/VideoStation-FFMPEG-Patcher/patcher.sh -v 7
    ```
2) Check it out for more details: https://github.com/darknebular/Wrapper_VideoStation
    ```YAML
    bash -c "$(curl "https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/installer.sh")"
    ```

### What about future DSM updates?

***With Video Station installed:***

1. You'll get a message saying Video Station needs to be uninstalled before updating DSM.
2. Uninstall Video Station (but do **not** tick the box to delete Video Station's database).
3. Update DSM.
4. Package Center will show Advanced Media Extensions and Media Server as "incompatible with your DSM".
5. Run this script again.

***Without Video Station installed:***

1. Update DSM.
2. Package Center will show Advanced Media Extensions and Media Server as "incompatible with your DSM".
3. Run this script again.

</br>

<div id="Screenshots"></div>

### Screenshots

<p align="center">Install only Advanced Media Codecs</p>
<p align="center"><img src="/images/install_ame_only.png"></p>

<p align="center">Skip installing Media Server</p>
<p align="center"><img src="/images/skip_ms.png"></p>

<p align="center">Install All</p>
<p align="center"><img src="/images/install_all.png"></p>

</br>
