#!/bin/bash
#
#

ScriptHome=$(echo $HOME)
MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

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
    if [ ! -d "/Users/$USER/Library/Application Support/openmohaa" ]; then
        mkdir "/Users/$USER/Library/Application Support/openmohaa"
    fi
}

function validate()
{
    gametype=$( _helpDefaultRead "GameType" )

    if [[ "$gametype" = "0" ]]; then
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/main" ]; then
            _helpDefaultWrite "GameValid" "1"
        else
            _helpDefaultWrite "GameValid" "0"
        fi
    fi
        
    if [[ "$gametype" = "1" ]]; then
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/mainta" ] && [ -d "/Users/$USER/Library/Application Support/openmohaa/main" ]; then
            _helpDefaultWrite "GameValid" "1"
        else
            _helpDefaultWrite "GameValid" "0"
        fi
    fi
    
    if [[ "$gametype" = "2" ]]; then
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/maintt" ] && [ -d "/Users/$USER/Library/Application Support/openmohaa/main" ]; then
            _helpDefaultWrite "GameValid" "1"
        else
            _helpDefaultWrite "GameValid" "0"
        fi
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
    
    if [[ "$bloodmod" = "1" ]]; then
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/main" ] && [ ! -f "/Users/$USER/Library/Application Support/openmohaa/main/zzz_BloodMod.pk3" ]; then
            cp ../bin/mods/zzz_BloodMod.pk3 "/Users/$USER/Library/Application Support/openmohaa/main/"
        fi
        
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/mainta" ] && [ ! -f "/Users/$USER/Library/Application Support/openmohaa/mainta/zzz_BloodMod.pk3" ]; then
            cp ../bin/mods/zzz_BloodMod.pk3 "/Users/$USER/Library/Application Support/openmohaa/mainta/"
        fi
        
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/maintt" ] && [ ! -f "/Users/$USER/Library/Application Support/openmohaa/maintt/zzz_BloodMod.pk3" ]; then
            cp ../bin/mods/zzz_BloodMod.pk3 "/Users/$USER/Library/Application Support/openmohaa/maintt/"
        fi
    else
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/main" ] && [ -f "/Users/$USER/Library/Application Support/openmohaa/main/zzz_BloodMod.pk3" ]; then
            rm "/Users/$USER/Library/Application Support/openmohaa/main/zzz_BloodMod.pk3"
        fi
        
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/mainta" ] && [ -f "/Users/$USER/Library/Application Support/openmohaa/mainta/zzz_BloodMod.pk3" ]; then
            rm "/Users/$USER/Library/Application Support/openmohaa/mainta/zzz_BloodMod.pk3"
        fi
        
        if [ -d "/Users/$USER/Library/Application Support/openmohaa/maintt" ] && [ -f "/Users/$USER/Library/Application Support/openmohaa/maintt/zzz_BloodMod.pk3" ]; then
            rm "/Users/$USER/Library/Application Support/openmohaa/maintt/zzz_BloodMod.pk3"
        fi
    fi
    
    if [[ "$gameconsole" = "0" ]]; then
        console='echo "+set developer 0 +set ui_console 1c"'
    else
        console='echo "+set developer 1 +set ui_console 1c"'
    fi

    if [[ "$cheats" = "0" ]]; then
        cheats='echo "+set thereisnomonkey 0 +set cheats 0"'
    else
        cheats='echo "+set thereisnomonkey 1 +set cheats 1"'
    fi

    cd ../bin

    if [[ "$gametype" = "0" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/seta\ r_fullscreen/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        
        echo "seta r_ext_multisample \"$multisample\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta fps \"$showfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_fullscreen \"$screenmode\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"

        ./openmohaa +set com_target_game 0 "$cheats" "$console" &

    elif [[ "$gametype" = "1" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/seta\ r_fullscreen/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"

        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_ext_multisample \"$multisample\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta fps \"$showfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_fullscreen \"$screenmode\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"

        ./openmohaa +set com_target_game 1 "$cheats" "$console" &
        
    elif [[ "$gametype" = "2" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/seta\ r_fullscreen/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"

        echo "seta r_ext_multisample \"$multisample\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta fps \"$showfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_fullscreen \"$screenmode\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"

        ./openmohaa +set com_target_game 2 "$cheats" "$console" &
         
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
