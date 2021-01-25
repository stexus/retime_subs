#!/bin/bash

set -euo pipefail
#-e : exit on error
#-u : error on non defined variable
#-o pipefail : saves error code of failed command in pipeline

#prompt user if multiple subtitle tracks
#extract subtitle given track
#align via alass
#delete extracted, rename aligned
#option to only rename subtitles to match
#error catching with more video files than subtitle files
jp_ext="srt"
eng_ext="srt"
to_align=true
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

#rename subs to match
subs=(*.$jp_ext)
#can only extract subtitles from mkv format
videos=(*.mkv)


#1 -> video
chosen_track=-1
prompt() {
        info=$(mkvinfo "$1")
        declare -A extracts
        declare -A codecs
        #declare an associative array with mkvextract # & name if applicable
        i=1
        while grep -w "Track number: $i" -A 10 <<< $info > /dev/null; do
                curr=$(grep -w "Track number: $i" -A 10 <<< $info)
                if grep -w "Track number: $i" -A 10 <<< $info | grep 'subtitles' > /dev/null; then
                        name=$(grep "Track number: $i" -A 10 <<< $info| grep 'Name' | cut -d' ' -f5-)
                        codec=$(awk -F'/' '/Codec ID/{print tolower($2)}' <<< $curr)
                        display_name=${name:-$i}
                        #echo $display_name
                        track=$((i - 1))
                        extracts[$track]=$display_name
                        codecs[$track]=$codec
                fi
                ((i++))
        done
        for i in ${!extracts[@]}; do
                #consider removing pgs entirely
                printf "%s | %s (%s)\n" "$i" "${extracts[$i]}" "${codecs[$i]}"
        done | sort -n -k1
        while [ $chosen_track -lt 0 ]; do
                read -p 'Enter track number: ' chosen_track
                [ ${extracts[$chosen_track]+1} ] || { echo "Please enter a valid track" && chosen_track=-1; }
                eng_ext=${codecs[$chosen_track]}
        done
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
for ((i=0;i<it;i++)); do
        title=${videos[$i]%.mkv}
        untimed="${title}.jp.${jp_ext}"
        mv "${subs[$i]}" "$untimed" 2>/dev/null || true
        echo "working"
        [ to_align ] && align "$title" "$untimed"
done
