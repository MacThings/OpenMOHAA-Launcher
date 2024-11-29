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

function validate()
{
    gametype=$( _helpDefaultRead "GameType" )

    if [[ "$gametype" = "0" ]]; then
        if [ -d "$mohaa_folder/main" ]; then
            _helpDefaultWrite "GameValid" "1"
        else
            _helpDefaultWrite "GameValid" "0"
        fi
    fi
        
    if [[ "$gametype" = "1" ]]; then
        if [ -d "$mohaa_folder/mainta" ] && [ -d "$mohaa_folder/main" ]; then
            _helpDefaultWrite "GameValid" "1"
        else
            _helpDefaultWrite "GameValid" "0"
        fi
    fi
    
    if [[ "$gametype" = "2" ]]; then
        if [ -d "$mohaa_folder/maintt" ] && [ -d "$mohaa_folder/main" ]; then
            _helpDefaultWrite "GameValid" "1"
        else
            _helpDefaultWrite "GameValid" "0"
        fi
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
        
        #if [ -d "$mohaa_folder/mainta" ] && [ ! -f "/Users/$USER/Library/Application #Support/openmohaa/mainta/zzz_BloodMod.pk3" ]; then
        #    cp ../bin/mods/zzz_BloodMod.pk3 "$mohaa_folder/mainta/"
        #fi
        
        #if [ -d "$mohaa_folder/maintt" ] && [ ! -f "$mohaa_folder/maintt/zzz_BloodMod.pk3" ]; then
       #     cp ../bin/mods/zzz_BloodMod.pk3 "$mohaa_folder/maintt/"
        #fi
    else
        if [ -d "$mohaa_folder/main" ] && [ -f "$mohaa_folder/main/zzz_BloodMod.pk3" ]; then
            rm "$mohaa_folder/main/zzz_BloodMod.pk3"
        fi
        
        #if [ -d "$mohaa_folder/mainta" ] && [ -f "$mohaa_folder/mainta/zzz_BloodMod.pk3" ]; then
        #    rm "$mohaa_folder/mainta/zzz_BloodMod.pk3"
        #fi
        
        #if [ -d "$mohaa_folder/maintt" ] && [ -f "$mohaa_folder/maintt/zzz_BloodMod.pk3" ]; then
        #    rm "$mohaa_folder/maintt/zzz_BloodMod.pk3"
        #fi
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
