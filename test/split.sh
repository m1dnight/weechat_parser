#!/bin/bash 

source=$1
target="$source/split"

rm -rf "${target}"
mkdir "${target}" 

for f in "${1}"/*.weechatlog;  do 
    tmp="${target}/log.txt"

    cp "$f" "$tmp"

    echo "$f"

    # outgoing
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t<--\t' "$tmp" >> "${target}"/outgoing.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t<--\t.*/d' "$tmp"

    # action
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t<--\t' "$tmp" >> "${target}"/outgoing.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t<--\t.*/d' "$tmp"

    # incoming
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t-->\t' "$tmp" >> "${target}"/incoming.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t-->\t.*/d' "$tmp"

    # server
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t--\t' "$tmp" >> "${target}"/server.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t--\t.*/d' "$tmp"

    # join
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t-->\t.*has joined.*' "${target}"/incoming.txt >> "${target}"/join.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t-->\t.*has joined.*/d' "${target}"/incoming.txt


    # leave
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t<--\t.*has quit.*' "${target}"/outgoing.txt >> "${target}"/quit.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t<--\t.*has quit.*/d' "${target}"/outgoing.txt

    # leave
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t<--\t.*has left.*' "${target}"/outgoing.txt >> "${target}"/leave.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t<--\t.*has left.*/d' "${target}"/outgoing.txt


    # kicks
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t<--\t.*has kicked.*' "${target}"/outgoing.txt >> "${target}"/kicks.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t<--\t.*has kicked.*/d' "${target}"/outgoing.txt

    # back on server 
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t-->\t.*is back on server.*' "${target}"/server.txt >> "${target}"/server.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t-->\t.*is back on server.*/d' "${target}"/incoming.txt

    # now known as
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t--\t.*is now known as.*' "${target}"/server.txt >> "${target}"/nickchange.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t--\t.*is now known as.*/d' "${target}"/server.txt

    # actions
    grep -aE '^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\t\s\*\t.*' "${tmp}" >> "${target}"/actions.txt 
    sed -i '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\t\s\*\t.*/d' "${tmp}"

    # now known as
    cat "${tmp}" >>  "${target}/chat.txt"
done

