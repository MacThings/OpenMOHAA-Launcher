#!/bin/bash
#
#

ScriptHome=$(echo $HOME)
MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

mohaa_folder="/Users/$USER/Library/Application Support/openmohaa"

function _helpDefaultRead()
{
    VAL=$1
    
    if [ ! -z "$VAL" ]; then
    defaults read "${ScriptHome}/Library/Preferences/sl-soft.openmohaa-launcher.plist" "$VAL"
    fi
}

function _helpDefaultWrite()
{
    VAL=$1
    local VAL1=$2
    
    if [ ! -z "$VAL" ] || [ ! -z "$VAL1" ]; then
    defaults write "${ScriptHome}/Library/Preferences/sl-soft.openmohaa-launcher.plist" "$VAL" "$VAL1"
    fi
}

function init()
{
    if [ ! -d "$mohaa_folder" ]; then
        mkdir "$mohaa_folder"
    fi
}

function validate_gamefiles()
{
    gametype=$( _helpDefaultRead "GameType" )
    all_files_exist=true

    for i in {0..5}; do
        if [[ ! -f "$mohaa_folder/main/Pak${i}.pk3" || ! -d "$mohaa_folder/main/sound" || ! -d "$mohaa_folder/main/video" ]]; then
            all_files_exist=false
            break
        fi
    done

    for i in {1..5}; do
        if [[ ! -f "$mohaa_folder/mainta/pak${i}.pk3" || ! -d "$mohaa_folder/mainta/sound" || ! -d "$mohaa_folder/mainta/video" ]]; then
            all_files_exist=false
            break
        fi
    done

    for i in {1..4}; do
        if [[ ! -f "$mohaa_folder/maintt/pak${i}.pk3" || ! -d "$mohaa_folder/maintt/sound" || ! -d "$mohaa_folder/maintt/video" ]]; then
            all_files_exist=false
            break
        fi
    done

    if $all_files_exist; then
        _helpDefaultWrite "GameValid" "1"
    else
        _helpDefaultWrite "GameValid" "0"
    fi
}

function checksum_gog_installer() {
    gog_installer=$( _helpDefaultRead "GOGInstaller" )
    gog_checksum=$( sha256 "$gog_installer" | sed 's/.*=//g' | xargs )
    
    if [[ "$gog_checksum" = "89f482cb7a169b74a957c8176d2618df614c47e83cfa3ae615af5b196c2118a7" ]]; then
        _helpDefaultWrite "GOGChecksumOk" "1"
    else
        _helpDefaultWrite "GOGChecksumOk" "0"
    fi
}

function gog_install()
{
    gog_installer=$( _helpDefaultRead "GOGInstaller" )

    TEMP_DIR="/private/tmp/mohaa"
    mkdir "$TEMP_DIR"
    
    ../bin/innoextract/./innoextract --extract --include "app/main" --include "app/mainta" --include "app/maintt" "$gog_installer" -d "$TEMP_DIR" >/dev/null 2>&1

    for folder in main mainta maintt; do
        if [ -d "$TEMP_DIR/app/$folder" ]; then
            mv "$TEMP_DIR/app/$folder" "$mohaa_folder"
        else
            echo "Fehler: Der Ordner 'app/$folder' wurde nicht gefunden."
        fi
    done
    
    rm -rf "$TEMP_DIR"
}

function gog_already_installed()
{
    gog_already_installed=$( _helpDefaultRead "GOGAlreadyInstalled" )
    
    if [[ -d "$mohaa_folder"/main ]]; then
        exit
    fi
    
    if [[ "$gog_already_installed" != "" ]]; then
        rsync -ra "$gog_already_installed"/* "$mohaa_folder"/
    fi
}

function start()
{
    screen_width=$( _helpDefaultRead "Resolution" | sed 's/x.*//g' |xargs )
    screen_height=$( _helpDefaultRead "Resolution" | sed -e 's/.*x//g' -e 's/*//g' |xargs )
    resolution=$( _helpDefaultRead "Resolution" )
    gametype=$( _helpDefaultRead "GameType" )
    gamevalid=$( _helpDefaultRead "GameValid" )
    gameconsole=$( _helpDefaultRead "Console" )
    cheats=$( _helpDefaultRead "Cheats" )
    bloodmod=$( _helpDefaultRead "BloodMod" )
    anisotropic=$( _helpDefaultRead "Anisotropic" )
    multisample=$( _helpDefaultRead "Multisample" )
    showfps=$( _helpDefaultRead "ShowFPS" )
    maxfps=$( _helpDefaultRead "MaxFPS" )
    vsync=$( _helpDefaultRead "VSync" )
    refreshrate=$( _helpDefaultRead "RefreshRate" )
    screenmode=$( _helpDefaultRead "ScreenMode" )
    grabmouse=$( _helpDefaultRead "GrabMouse" )

    if [[ "$screenmode" = "1" ]]; then
        screenmode="0"
    else
        screenmode="1"
    fi
    
    if [[ "$resolution" = "Desktop" ]]; then
        screen_width=$( _helpDefaultRead "CurrentResolution" | sed 's/x.*//g' |xargs )
        screen_height=$( _helpDefaultRead "CurrentResolution" | sed -e 's/.*x//g' -e 's/*//g' |xargs )
    fi
    
    if [[ "$vsync" = "1" ]]; then
        maxfps="$refreshrate"
    fi
    
    if [[ "$vsync" = "1" ]]; then
        maxfps="$refreshrate"
    fi
    
    if [[ "$grabmouse" = "1" ]]; then
        grabmouse="0"
    else
        grabmouse="1"
    fi
    
    if [[ "$bloodmod" = "1" ]]; then
        if [ -d "$mohaa_folder/main" ] && [ ! -f "$mohaa_folder/main/zzz_BloodMod.pk3" ]; then
            cp ../bin/mods/zzz_BloodMod.pk3 "$mohaa_folder/main/"
        fi
    else
        if [ -d "$mohaa_folder/main" ] && [ -f "$mohaa_folder/main/zzz_BloodMod.pk3" ]; then
            rm "$mohaa_folder/main/zzz_BloodMod.pk3"
        fi
    fi
    
    if [[ "$gametype" = "0" ]]; then
        folder="main"
    elif [[ "$gametype" = "1" ]]; then
        folder="mainta"
    elif [[ "$gametype" = "2" ]]; then
        folder="maintt"
    fi

    cd ../bin

    if [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/seta\ r_fullscreen/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        sed -i '' '/seta\ in_nograb/d' "$mohaa_folder/$folder/configs/omconfig.cfg"
        
        echo "seta r_ext_multisample \"$multisample\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta fps \"$showfps\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta r_fullscreen \"$screenmode\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta r_fullscreen \"$screenmode\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"
        echo "seta in_nograb \"$grabmouse\"" >> "$mohaa_folder/$folder/configs/omconfig.cfg"

        ./openmohaa +set com_target_game "$gametype" +set thereisnomonkey "$cheats" +set cheats $cheats +set developer "$gameconsole" +set ui_console 1c &
    fi
}

function start_server()
{
    check_task=$( ps ax | grep -v grep | grep "omohaaded" )
    
    if [[ "$check_task" = "" ]]; then
        ../bin/./omohaaded > /dev/stdout 2>&1
    else
        echo -e "\nError! Server already running.\n"
    fi
}

function stop_server()
{
    pkill -f omohaaded
    if [[ "$?" = "1" ]]; then
        echo "Server is not running."
    else
        echo -e "\nServer stopped."
    fi
}

$1
