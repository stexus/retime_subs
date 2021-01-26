#!/bin/bash

set -euo pipefail
#-e : exit on error
#-u : error on non defined variable
#-o pipefail : saves error code of failed command in pipeline

#prompt user if multiple subtitle tracks
#option to only rename subtitles to match
#error catching with more video files than subtitle files
#automatic detection later
jp_ext="srt"
eng_ext="srt"
to_align=true
{ compgen -G "*.srt" >/dev/null && jp_ext="srt"; } || { compgen -G "*.ass" >/dev/null && jp_ext="ass"; } 
while getopts ":e:n" opt; do
        case ${opt} in
                e) jp_ext="${OPTARG}"
                        ;;
                n) to_align=false
                        ;;
                :) echo "Invalid option: $OPTARG requires an argument" 1>&2
                        ;;
                \?) echo "retime [-e] EXTENSION [-n]"
        esac
done
subs=(*.$jp_ext)
videos=(*.mkv)


#1 -> video
chosen_track=-1
prev_name=""
#todo: dont reprompt if chosen track and name are same | done
#todo: save all previous names, automatically choose correct track
prompt() {
        info=$(mkvinfo "$1")
        declare -A extracts
        declare -A codecs
        #declare an associative array with mkvextract # & name if applicable
        i=1
        while grep -w "Track number: $i" <<< $info > /dev/null; do
                curr=$(grep -w "Track number: $i" -A 10 <<< $info)
                if grep 'subtitles' <<< $curr > /dev/null; then
                        name=$(awk -F': ' '/Name/{print $2}' <<< $curr)
                        codec=$(awk -F'/' '/Codec ID/{print tolower($2)}' <<< $curr)
                        track=$((i - 1))
                        display_name=${name:-$track}
                        extracts[$track]=$display_name
                        codecs[$track]=$codec
                fi
                ((i++))
        done
        if ! [ ${extracts[$chosen_track]+1} ] || [ "$prev_name" != "${extracts[$chosen_track]}" ]; then
                for key in ${!extracts[@]}; do
                        #consider removing pgs entirely
                        printf "%s | %s (%s)\n" "$key" "${extracts[$key]}" "${codecs[$key]}"
                done | sort -n -k1
                chosen_track=-1
                while [ $chosen_track -lt 0 ]; do
                        read -p 'Enter track number: ' chosen_track
                        [ ${extracts[$chosen_track]+0} ] || { echo "Please enter a valid track" && chosen_track=-1; }
                done
                echo 
        fi
        eng_ext=${codecs[$chosen_track]}
        prev_name=${extracts[$chosen_track]}
}

#1 -> title
#2 -> subtitle to align
align() {
        prompt "${1}.mkv"
        title="$1"
        eng_sub="${title}.eng.${eng_ext}"
        untimed="$2"
        timed="${title}.retimed.${jp_ext}"
        mkvextract tracks "$1".mkv "$track":"$eng_sub"
        alass-cli "$eng_sub" "$untimed" "$timed"
        mv "$timed" "$untimed"
        rm "$eng_sub"
        #error checking
}

it=$((${#subs[@]} < ${#videos[@]} ? ${#subs[@]} : ${#videos[@]}))
#renaming
echo "${it} files"
for ((iter=0;iter<it;iter++)); do
        title=${videos[$iter]%.mkv}
        untimed="${title}.jp.${jp_ext}"
        mv "${subs[$iter]}" "$untimed" 2>/dev/null || true
        [ to_align ] && align "$title" "$untimed"
done
