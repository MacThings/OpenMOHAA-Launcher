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
    gametype=$( _helpDefaultRead "GameType" )
    gamevalid=$( _helpDefaultRead "GameValid" )
    gameconsole=$( _helpDefaultRead "Console" )
    bloodmod=$( _helpDefaultRead "BloodMod" )
    anisotropic=$( _helpDefaultRead "Anisotropic" )
    multisample=$( _helpDefaultRead "Multisample" )
    fps=$( _helpDefaultRead "FPS" )
    maxfps=$( _helpDefaultRead "MaxFPS" )
    
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
         
    console_on='echo "+set developer 2 +set thereisnomonkey 1 +set cheats 1 +set ui_console 1c"'
    console_off='echo "+set developer 0 +set thereisnomonkey 0 +set cheats 0 +set ui_console 1c"'

    cd ../bin

    if [[ "$gametype" = "0" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        
        echo "seta r_ext_multisample \"$multisample\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta fps \"$fps\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        
        
        if [[ "$gameconsole" = "0" ]]; then
            ./openmohaa +set com_target_game 0 "$console_off"
        else
            ./openmohaa +set com_target_game 0 "$console_on"
        fi
    elif [[ "$gametype" = "1" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"

        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_ext_multisample \"$multisample\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta fps \"$fps\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"

        if [[ "$gameconsole" = "0" ]]; then
            ./openmohaa +set com_target_game 1 "$console_off"
        else
            ./openmohaa +set com_target_game 1 "$console_on"
        fi
    elif [[ "$gametype" = "2" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_ext_multisample/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_ext_texture_filter_anisotropic/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/seta\ fps/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/com_maxfps/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"

        echo "seta r_ext_multisample \"$multisample\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_ext_texture_filter_anisotropic \"$anisotropic\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta fps \"$fps\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta com_maxfps \"$maxfps\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"

        if [[ "$gameconsole" = "0" ]]; then
            ./openmohaa +set com_target_game 2 "$console_off"
        else
            ./openmohaa +set com_target_game 2 "$console_on"
        fi
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
    fi

}



$1
