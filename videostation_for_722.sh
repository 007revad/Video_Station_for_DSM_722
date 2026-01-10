#!/usr/bin/env bash
#------------------------------------------------------------------------------
# https://www.synology.com/en-au/releaseNote/VideoStation
# https://www.synology.com/en-au/releaseNote/CodecPack
# https://www.synology.com/en-au/releaseNote/MediaServer
# https://www.synology.com/en-au/releaseNote/DSM
#
# Video Station does not support TrueHD or DTS audio.
# Video Station does not decode AAC audio.
#------------------------------------------------------------------------------
# https://archive.synology.com/download/Package
# https://web.archive.org/web/20240825163306/https://archive.synology.com/download/Package
#------------------------------------------------------------------------------
# To get Video Station to work I needed to install an older version of AME...
# which means Drive and Surveillance Station may not work
# (unless I install older versions of them).
#------------------------------------------------------------------------------
# I've seen evidence of:
#   VideoStation="3.2.0-3173" (when you try to manually install 3.1.1)
#   CodecPack="4.0.0-4003"
# It looks like Synology were developing a new video station for DSM 7.2.2
# before someone decided to scrap it and cannibalise AME to save a few dollars
#------------------------------------------------------------------------------
# TODO
# Figure out how to install already downloaded package to specific volume
# Figure out where package center saves it's settings
# Figure out how to run VideoStation 3.1.1-3168 with CodecPack 3.1.0-3005
#   or add OpenSubtitle changes from 3.1.1-3168 to 3.1.0-3153
#------------------------------------------------------------------------------

scriptver="v1.4.20"
script=Video_Station_for_DSM_722
repo="007revad/Video_Station_for_DSM_722"
scriptname=videostation_for_722

ding(){ 
    printf \\a
}

# Save options used for getopt
args=("$@")

if [[ $1 == "--trace" ]] || [[ $1 == "-t" ]]; then
    trace="yes"
fi

# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    ding
    echo -e "${Error}ERROR${Off} This script must be run as sudo or root!"
    exit 1  # Not running as sudo or root
fi

# Get NAS model
model=$(cat /proc/sys/kernel/syno_hw_version)
#modelname="$model"


# Show script version
#echo -e "$script $scriptver\ngithub.com/$repo\n"
echo "$script $scriptver"

# Get DSM full version
productversion=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION productversion)
buildphase=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION buildphase)
buildnumber=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION buildnumber)
smallfixnumber=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION smallfixnumber)

# Get CPU arch and platform_name
arch="$(uname -m)"
platform_name=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/synoinfo.conf platform_name)

# Show DSM full version and model
if [[ $buildphase == GM ]]; then buildphase=""; fi
if [[ $smallfixnumber -gt "0" ]]; then smallfix="-$smallfixnumber"; fi
echo "$model DSM $productversion-$buildnumber$smallfix $buildphase"

# Show CPU arch and platform_name
echo "CPU $platform_name $arch"

# Show options used
if [[ ${#args[@]} -gt "0" ]]; then
    echo -e "Using options: ${args[*]}\n"
else
    echo ""
fi


usage(){ 
    cat <<EOF
Usage: $(basename "$0") [options]

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

EOF
}

scriptversion(){ 
    cat <<EOF
$script $scriptver - by 007revad

See https://github.com/$repo
EOF
    exit 0
}


autoupdate=""

# Check for flags with getopt
if options="$(getopt -o abcdefghijklmnopqrstuvwxyz0123456789 -l \
    autoupdate:,install:,help,version,log,debug -- "${args[@]}")"; then
    eval set -- "$options"
    while true; do
        case "${1,,}" in
            -h|--help)          # Show usage options
                usage
                exit
                ;;
            -v|--version)       # Show script version
                scriptversion
                ;;
            -l|--log)           # Log
                log=yes
                ;;
            -d|--debug)         # Show and log debug info
                debug=yes
                ;;
            --install)             # Specify pkgs to install or skip
                color=no        # Disable colour text in task scheduler emails
                if [[ ${2,,} == "all" ]]; then
                    auto="yes"
                    choice="Installing All"
                elif [[ ${2,,} == "novs" ]]; then
                    auto="yes"
                    no_vs="yes"
                    choice="Skipping Video Station"
                elif [[ ${2,,} == "noms" ]]; then
                    auto="yes"
                    no_ms="yes"
                    choice="Skipping Media Server"
                elif [[ ${2,,} == "onlyamc" ]]; then
                    auto="yes"
                    no_vs="yes"
                    no_ms="yes"
                    choice="Only installing Advanced Media Codecs"
                else
                    ding
                    echo -e "Missing argument to auto!\n"
                    usage
                    exit 2  # Missing argument
                fi
                shift
                ;;
            --autoupdate)       # Auto update script
                autoupdate=yes
                if [[ $2 =~ ^[0-9]+$ ]]; then
                    delay="$2"
                    shift
                else
                    delay="0"
                fi
                ;;
            --)
                shift
                break
                ;;
            *)                  # Show usage options
                ding
                echo -e "Invalid option '$1'\n"
                usage
                exit 2  # Invalid argument
                ;;
        esac
        shift
    done
else
    echo
    usage
    exit
fi

# Shell Colors
if [[ $color != "no" ]]; then
    #Black='\e[0;30m'   # ${Black}
    #Red='\e[0;31m'      # ${Red}
    #Green='\e[0;32m'   # ${Green}
    #Yellow='\e[0;33m'   # ${Yellow}
    #Blue='\e[0;34m'    # ${Blue}
    #Purple='\e[0;35m'  # ${Purple}
    Cyan='\e[0;36m'     # ${Cyan}
    #White='\e[0;37m'   # ${White}
    Error='\e[41m'      # ${Error}
    #Warn='\e[47;31m'   # ${Warn}
    Off='\e[0m'         # ${Off}
fi


#------------------------------------------------------------------------------
# Check latest release with GitHub API

# Save options used
args=("$@")

# Get latest release info
# Curl timeout options:
# https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout
release=$(curl --silent --connect-timeout 30 \
    "https://api.github.com/repos/$repo/releases/latest")

# Release version
tag=$(echo "$release" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
shorttag="${tag:1}"

# Get script location
# https://stackoverflow.com/questions/59895/
source=${BASH_SOURCE[0]}
while [ -L "$source" ]; do # Resolve $source until the file is no longer a symlink
    scriptpath=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
    source=$(readlink "$source")
    # If $source was a relative symlink, we need to resolve it
    # relative to the path where the symlink file was located
    [[ $source != /* ]] && source=$scriptpath/$source
done
scriptpath=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
scriptfile=$( basename -- "$source" )
echo "Running from: ${scriptpath}/$scriptfile"

#echo "Script location: $scriptpath"  # debug
#echo "Source: $source"               # debug
#echo "Script filename: $scriptfile"  # debug

#echo "tag: $tag"              # debug
#echo "scriptver: $scriptver"  # debug


cleanup_tmp(){ 
    # Delete downloaded .tar.gz file
    if [[ -f "/tmp/$script-$shorttag.tar.gz" ]]; then
        if ! rm "/tmp/$script-$shorttag.tar.gz"; then
            echo -e "${Error}ERROR${Off} Failed to delete"\
                "downloaded /tmp/$script-$shorttag.tar.gz!" >&2
        fi
    fi

    # Delete extracted tmp files
    if [[ -d "/tmp/$script-$shorttag" ]]; then
        if ! rm -r "/tmp/$script-$shorttag"; then
            echo -e "${Error}ERROR${Off} Failed to delete"\
                "downloaded /tmp/$script-$shorttag!" >&2
        fi
    fi
}


if ! printf "%s\n%s\n" "$tag" "$scriptver" |
        sort --check=quiet --version-sort >/dev/null ; then
    echo -e "\n${Cyan}There is a newer version of this script available.${Off}"
    echo -e "Current version: ${scriptver}\nLatest version:  $tag"
    scriptdl="$scriptpath/$script-$shorttag"
    if [[ -f ${scriptdl}.tar.gz ]] || [[ -f ${scriptdl}.zip ]]; then
        # They have the latest version tar.gz downloaded but are using older version
        echo "You have the latest version downloaded but are using an older version"
        sleep 10
    elif [[ -d $scriptdl ]]; then
        # They have the latest version extracted but are using older version
        echo "You have the latest version extracted but are using an older version"
        sleep 10
    else
        echo -e "${Cyan}Do you want to download $tag now?${Off} [y/n]"
        read -r -t 30 reply
        if [[ ${reply,,} == "y" ]]; then
            # Delete previously downloaded .tar.gz file and extracted tmp files
            cleanup_tmp

            if cd /tmp; then
                url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"
                if ! curl -JLO -m 30 --connect-timeout 5 "$url"; then
                    echo -e "${Error}ERROR${Off} Failed to download"\
                        "$script-$shorttag.tar.gz!"
                else
                    if [[ -f /tmp/$script-$shorttag.tar.gz ]]; then
                        # Extract tar file to /tmp/<script-name>
                        if ! tar -xf "/tmp/$script-$shorttag.tar.gz" -C "/tmp"; then
                            echo -e "${Error}ERROR${Off} Failed to"\
                                "extract $script-$shorttag.tar.gz!"
                        else
                            # Set script sh files as executable
                            if ! chmod a+x "/tmp/$script-$shorttag/"*.sh ; then
                                permerr=1
                                echo -e "${Error}ERROR${Off} Failed to set executable permissions"
                            fi

                            # Copy new script sh file to script location
                            if ! cp -p "/tmp/$script-$shorttag/${scriptname}.sh" "${scriptpath}/${scriptfile}";
                            then
                                copyerr=1
                                echo -e "${Error}ERROR${Off} Failed to copy"\
                                    "$script-$shorttag sh file(s) to:\n $scriptpath/${scriptfile}"
                            fi

                            # Copy new CHANGES.txt file to script location (if script on a volume)
                            if [[ $scriptpath =~ /volume* ]]; then
                                # Set permissions on CHANGES.txt
                                if ! chmod 664 "/tmp/$script-$shorttag/CHANGES.txt"; then
                                    permerr=1
                                    echo -e "${Error}ERROR${Off} Failed to set permissions on:"
                                    echo "$scriptpath/CHANGES.txt"
                                fi

                                # Copy new CHANGES.txt file to script location
                                if ! cp -p "/tmp/$script-$shorttag/CHANGES.txt"\
                                    "${scriptpath}/${scriptname}_CHANGES.txt";
                                then
                                    echo -e "${Error}ERROR${Off} Failed to copy"\
                                        "$script-$shorttag/CHANGES.txt to:\n $scriptpath"
                                else
                                    changestxt=" and changes.txt"
                                fi
                            fi

                            # Delete downloaded tmp files
                            cleanup_tmp

                            # Notify of success (if there were no errors)
                            if [[ $copyerr != 1 ]] && [[ $permerr != 1 ]]; then
                                echo -e "\n$tag ${scriptfile}$changestxt downloaded to: ${scriptpath}\n"

                                # Reload script
                                printf -- '-%.0s' {1..79}; echo  # print 79 -
                                exec "${scriptpath}/$scriptfile" "${args[@]}"
                            fi
                        fi
                    else
                        echo -e "${Error}ERROR${Off}"\
                            "/tmp/$script-$shorttag.tar.gz not found!"
                        #ls /tmp | grep "$script"  # debug
                    fi
                fi
                cd "$scriptpath" || echo -e "${Error}ERROR${Off} Failed to cd to script location!"
            else
                echo -e "${Error}ERROR${Off} Failed to cd to /tmp!"
            fi
        fi
    fi
fi

#------------------------------------------------------------------------------

# Check script is needed
if [[ $buildnumber -lt "72803" ]]; then
    echo -e "\nYour DSM version does not need this script"
    exit
fi

# Check model is supported
spks_list=("armada37xx" "armada38x" "armv7" "monaco" "rtd1296" "rtd1619b" "x86_64")
if [[ ${spks_list[*]} =~ $arch ]]; then
    cputype="$arch"
elif [[ ${spks_list[*]} =~ $platform_name ]]; then
    cputype="$platform_name"
elif [[ $platform_name == "alpine" || $platform_name == "alpine4k" ]]; then
    # DS1817, DS1517 and DS416
    cputype="armv7"
else
    echo -e "\nUnsupported or unknown CPU platform_name or architecture"
    echo "  - CPU type: $cputype"
    echo "  - Platform: $platform_name"
    echo -e "Please create an issue at:"
    echo -e "https://github.com/007revad/Video_Station_for_DSM_722/issues\n"
    exit
fi
echo "Using CPU type: $cputype"

#------------------------------------------------------------------------------

cleanup(){ 
    arg1=$?
    for s in /tmp/CodecPack-"${cputype}"-*.spk; do rm -f "$s"; done
    for s in /tmp/VideoStation-"${cputype}"-*.spk; do rm -f "$s"; done
    for s in /tmp/MediaServer-"${cputype}"-*.spk; do rm -f "$s"; done
    exit "${arg1}"
}

trap cleanup EXIT

progbar(){ 
    # $1 is pid of process
    # $2 is string to echo
    string="$2"
    local dots
    local progress
    dots=""
    while [[ -d /proc/$1 ]]; do
        dots="${dots}."
        progress="$dots"
        if [[ ${#dots} -gt "10" ]]; then
            dots=""
            progress="           "
        fi
        echo -ne "  ${2}$progress\r"; sleep 0.3
    done
}

progstatus(){ 
    # $1 is return status of process
    # $2 is string to echo
    # $3 line number function was called from
    local tracestring
    local pad
    tracestring="${FUNCNAME[0]} called from ${FUNCNAME[1]} $3"
    pad=$(printf -- ' %.0s' {1..80})
    [ "$trace" == "yes" ] && printf '%.*s' 80 "${tracestring}${pad}" && echo ""
    if [[ $1 == "0" ]]; then
        echo -e "$2            "
    else
        ding
        echo -e "Line ${LINENO}: ${Error}ERROR${Off} $2 failed!"
        echo "$tracestring"
        if [[ $exitonerror != "no" ]]; then
            exit 1  # Skip exit if exitonerror != no
        fi
    fi
    exitonerror=""
    #echo "return: $1"  # debug
}

package_status(){ 
    # $1 is package name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    /usr/syno/bin/synopkg status "${1}" >/dev/null
    code="$?"
    # DSM 7.2       0 = started, 17 = stopped, 255 = not_installed, 150 = broken
    # DSM 6 to 7.1  0 = started,  3 = stopped,   4 = not_installed, 150 = broken
    if [[ $code == "0" ]]; then
        #echo "$1 is started"  # debug
        return 0
    elif [[ $code == "17" ]] || [[ $code == "3" ]]; then
        #echo "$1 is stopped"  # debug
        return 1
    elif [[ $code == "255" ]] || [[ $code == "4" ]]; then
        #echo "$1 is not installed"  # debug
        return 255
    elif [[ $code == "150" ]]; then
        #echo "$1 is broken"  # debug
        return 150
    else
        return "$code"
    fi
}

check_pkg_installed(){ 
    # $1 is package
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    /usr/syno/bin/synopkg status "${1:?}" >/dev/null
    code="$?"
    if [[ $code == "255" ]] || [[ $code == "4" ]]; then
        return 1
    else
        return 0
    fi
}

package_is_running(){ 
    # $1 is package name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    /usr/syno/bin/synopkg is_onoff "${1}" >/dev/null
    code="$?"
    return "$code"
}

wait_status(){ 
    # Wait for package to finish stopping or starting
    # $1 is package
    # $2 is start or stop
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    local num
    if [[ $2 == "start" ]]; then
        state="0"
    elif [[ $2 == "stop" ]]; then
        state="1"
    fi
    if [[ $state == "0" ]] || [[ $state == "1" ]]; then
        num="0"
        package_status "$1"
        while [[ $? != "$state" ]]; do
            sleep 1
            num=$((num +1))
            if [[ $num -gt "20" ]]; then
                break
            fi
            package_status "$1"
        done
    fi
}

package_stop(){ 
    # $1 is package name
    # $2 is package display name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    timeout 5m /usr/syno/bin/synopkg stop "$1" >/dev/null &
    pid=$!
    #string="Stopping ${Cyan}${2}${Off}"
    string="Stopping ${2}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"

    # Allow package processes to finish stopping
    wait_status "$1" stop
}

package_start(){ 
    # $1 is package name
    # $2 is package display name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    timeout 5m /usr/syno/bin/synopkg start "$1" >/dev/null &
    pid=$!
    #string="Starting ${Cyan}${2}${Off}"
    string="Starting ${2}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"

    # Allow package processes to finish starting
    wait_status "$1" start
}

package_uninstall(){ 
    # $1 is package name
    # $2 is package display name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    /usr/syno/bin/synopkg uninstall "$1" >/dev/null &
    pid=$!
    string="Uninstalling ${Cyan}${2}${Off}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"
}

package_install(){ 
    # $1 is package filename
    # $2 is package display name
    # $3 is /volume2 etc
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    #/usr/syno/bin/synopkg install_from_server "$1" "$3" >/dev/null &
    /usr/syno/bin/synopkg install "/tmp/$1" "$3" >/dev/null &
    pid=$!
    if [[ $3 ]]; then
        string="Installing ${Cyan}${2}${Off} on ${Cyan}$3${Off}"
    else
        string="Installing ${Cyan}${2}${Off}"
    fi
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"
}

download_pkg(){ 
    # $1 is the package folder name
    # $2 is the package version to download
    # $3 is the package file to download
    
    # https://cndl.synology.cn/download/Package/spk/VideoStation/3.1.0-3153/VideoStation-x86_64-3.1.0-3153.spk
    # https://global.synologydownload.com/download/Package/spk/VideoStation/3.1.0-3153/VideoStation-x86_64-3.1.0-3153.spk

    local url
    language=$(synogetkeyvalue /etc/synoinfo.conf language)
    if [[ $language =~ chs|cht ]] && readlink -q /etc/localtime | grep -iq china;
    then
        # Use China only download site
        base="https://cndl.synology.cn/download/Package/spk/"
    else
        base="https://global.synologydownload.com/download/Package/spk/"
        # base2 currently unused
        base2="https://global.download.synology.com/download/Package/spk/"
    fi
    if [[ ! -f "/tmp/${3:?}" ]]; then
        url="${base}${1:?}/${2:?}/${3:?}"
        echo -e "\nDownloading ${Cyan}${3}${Off}"
        if ! curl -kL --connect-timeout 30 "$url" -o "/tmp/$3"; then
            ding
            echo -e "${Error}ERROR 2${Off} Failed to download ${3}!"
            exit 2
        fi
    fi
    if [[ ! -f "/tmp/${3:?}" ]]; then
        ding
        echo -e "${Error}ERROR 3${Off} Failed to download ${3}!"
        exit 3
    else
        echo ""
    fi
}


# Only install the packages the user wants
echo ""
if [[ $auto != "yes" ]]; then
    PS3="Select package(s) to install: "
    options=("Install All" "Only Advanced Media Codecs" "Skip Video Station" "Skip Media Server")
    TMOUT=20  # Timeout and install all if no choice made within 20 seconds (for task scheduler)
    select choice in "${options[@]}"; do
        case "$choice" in
            "Install All")
                break
            ;;
            "Skip Video Station")
                no_vs="yes"
                break
            ;;
            "Skip Media Server")
                no_ms="yes"
                break
            ;;
            "Only Advanced Media Codecs")
                no_vs="yes"
                no_ms="yes"
                break
            ;;
            "")
                echo "Invalid Choice!"
                ;;
            *)
                break
            ;;
        esac
    done
    unset TMOUT
    if [[ -z "$choice" ]]; then
        echo "No selection made. Installing all packages."
    else
        echo -e "You selected: ${Cyan}$choice${Off}"
    fi
else
    echo "$choice"
fi


# Backup synopackageslimit.conf if needed
if [[ ! -f /etc.defaults/synopackageslimit.conf.bak ]]; then
    cp -p /etc.defaults/synopackageslimit.conf /etc.defaults/synopackageslimit.conf.bak
fi

# Make DSM let us install the packages we want
/usr/syno/bin/synosetkeyvalue /etc.defaults/synopackageslimit.conf VideoStation "3.1.0-3153"
/usr/syno/bin/synosetkeyvalue /etc/synopackageslimit.conf VideoStation "3.1.0-3153"

/usr/syno/bin/synosetkeyvalue /etc.defaults/synopackageslimit.conf CodecPack "3.1.0-3005"
/usr/syno/bin/synosetkeyvalue /etc/synopackageslimit.conf CodecPack "3.1.0-3005"

/usr/syno/bin/synosetkeyvalue /etc.defaults/synopackageslimit.conf MediaServer "2.0.5-3152"
/usr/syno/bin/synosetkeyvalue /etc/synopackageslimit.conf MediaServer "2.0.5-3152"

# Get installed AME version
ame_version=$(/usr/syno/bin/synopkg version CodecPack)
if [[ ${ame_version:0:1} -gt "3" ]]; then
    # Uninstall AME v4
    echo ""
    package_uninstall CodecPack "Advanced Media Extensions"
fi

# Get installed VideoStation version
if [[ $no_vs != "yes" ]]; then
    vs_version=$(/usr/syno/bin/synopkg version VideoStation)
    #if check_pkg_installed VideoStation && [[ ${vs_version:0:2} != "30" ]]; then
    if check_pkg_installed VideoStation && [[ ${vs_version} != "30.1.0-3153" ]]; then
        # Uninstall VideoStation (wrong version)
        echo ""
        package_uninstall VideoStation "Video Station"
    fi
fi

# Get installed MediaServer version
if [[ $no_ms != "yes" ]]; then
    ms_version=$(/usr/syno/bin/synopkg version MediaServer)
    #if check_pkg_installed MediaServer && [[ ${ms_version:0:2} != "20" ]]; then
    if check_pkg_installed MediaServer && [[ ${ms_version} != "20.0.5-3152" ]]; then
        # Uninstall MediaServer (wrong version)
        echo ""
        package_uninstall MediaServer "Media Server"
    fi
fi

# CodecPack (Advanced Media Extensions)
if ! check_pkg_installed CodecPack && [[ $ame_version != "30.1.0-3005" ]]; then
    download_pkg CodecPack "3.1.0-3005" "CodecPack-${cputype}-3.1.0-3005.spk"
    package_install "CodecPack-${cputype}-3.1.0-3005.spk" "Advanced Media Extensions"
    package_stop CodecPack "Advanced Media Extensions"
    # Prevent package updating and "update available" messages
    echo "Preventing Advanced Media Extensions from auto updating"
    /usr/syno/bin/synosetkeyvalue /var/packages/CodecPack/INFO version "30.1.0-3005"
    package_start CodecPack "Advanced Media Extensions"
    rm -f "/tmp/CodecPack-${cputype}-3.1.0-3005.spk"
else
    echo -e "\n${Cyan}Advanced Media Extensions${Off} $ame_version already installed"
fi

# VideoStation
if [[ $no_vs != "yes" ]]; then
    if ! check_pkg_installed VideoStation && [[ $vs_version != "30.1.0-3153" ]]; then
        #download_pkg VideoStation "3.1.1-3168" "VideoStation-${cputype}-3.1.0-3168.spk"
        download_pkg VideoStation "3.1.0-3153" "VideoStation-${cputype}-3.1.0-3153.spk"
        #package_install "VideoStation-${cputype}-3.1.1-3168.spk" "Video Station"
        package_install "VideoStation-${cputype}-3.1.0-3153.spk" "Video Station"
        package_stop VideoStation "Video Station"
        # Prevent package updating and "update available" messages
        echo "Preventing Video Station from auto updating"
        #/usr/syno/bin/synosetkeyvalue /var/packages/VideoStation/INFO version "30.1.1-3168"
        /usr/syno/bin/synosetkeyvalue /var/packages/VideoStation/INFO version "30.1.0-3153"
        package_start VideoStation "Video Station"
        #rm -f "/tmp/VideoStation-${cputype}-3.1.0-3168.spk"
        rm -f "/tmp/VideoStation-${cputype}-3.1.0-3153.spk"
    else
        echo -e "\n${Cyan}Video Station${Off} $vs_version already installed"
    fi
fi

# MediaServer
if [[ $no_ms != "yes" ]]; then
    if ! check_pkg_installed MediaServer && [[ $ms_version != "20.0.5-3152" ]]; then
        download_pkg MediaServer "2.0.5-3152" "MediaServer-${cputype}-2.0.5-3152.spk"
        package_install "MediaServer-${cputype}-2.0.5-3152.spk" "Media Server"
        package_stop MediaServer "Media Server"
        # Prevent package updating and "update available" messages
        echo "Preventing Media Server from auto updating"
        /usr/syno/bin/synosetkeyvalue /var/packages/MediaServer/INFO version "20.0.5-3152"
        package_start MediaServer "Media Server"
        rm -f "/tmp/MediaServer-${cputype}-2.0.5-3152.spk"
    else
        echo -e "\n${Cyan}Media Server${Off} $ms_version already installed"
    fi
fi

# Start packages if needed (i.e. after DSM update)
if check_pkg_installed CodecPack; then
    if ! package_is_running CodecPack; then
        # Check if package is already starting
        synopkg status CodecPack >/dev/null
        code=$?
        if [[ $code != "55" ]]; then
            package_start CodecPack "Advanced Media Extensions"
        fi
    fi
fi
if check_pkg_installed VideoStation; then
    if ! package_is_running VideoStation; then
        # Check if package is already starting
        synopkg status VideoStation >/dev/null
        code=$?
        if [[ $code != "55" ]]; then
            package_start VideoStation "Video Station"
        fi
    fi
fi
if check_pkg_installed MediaServer; then
    if ! package_is_running MediaServer; then
        # Check if package is already starting
        synopkg status MediaServer >/dev/null
        code=$?
        if [[ $code != "55" ]]; then
            package_start MediaServer "Media Server"
        fi
    fi
fi

echo -e "\nFinished :)"

echo -e "\nTo enable HEVC decoding:"
echo " 1. Open Package Center > Installed"
echo " 2. Click Advanced Media Extensions"
echo " 3. Click on Open"
echo -e " 4. Click on Install then OK \n"

