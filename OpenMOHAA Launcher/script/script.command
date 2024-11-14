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

function validate() {

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

function init() {

if [ ! -d "/Users/$USER/Library/Application Support/openmohaa" ]; then
    mkdir "/Users/$USER/Library/Application Support/openmohaa"
fi

}
function start() {

    screen_width=$( _helpDefaultRead "Resolution" | sed 's/x.*//g' |xargs )
    screen_height=$( _helpDefaultRead "Resolution" | sed -e 's/.*x//g' -e 's/*//g' |xargs )
    gametype=$( _helpDefaultRead "GameType" )
    gamevalid=$( _helpDefaultRead "GameValid" )

    cd ../bin

    if [[ "$gametype" = "0" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/main/configs/omconfig.cfg"
        ./openmohaa +set com_target_game 0
    elif [[ "$gametype" = "1" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/mainta/configs/omconfig.cfg"
        ./openmohaa +set com_target_game 1
    elif [[ "$gametype" = "2" ]] && [[ "$gamevalid" = "1" ]]; then
        sed -i '' '/r_mode/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_customwidth/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        sed -i '' '/r_customheight/d' "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo 'seta r_mode "-1"' >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_customwidth \"$screen_width\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        echo "seta r_customheight \"$screen_height\"" >> "/Users/$USER/Library/Application Support/openmohaa/maintt/configs/omconfig.cfg"
        ./openmohaa +set com_target_game 2
    fi
    
}

$1
