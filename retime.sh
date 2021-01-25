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
to_align=1
while getopts ":e:n" opt; do
        case ${opt} in
                e) jp_ext="${OPTARG}"
                        ;;
                n) to_align=0
                        ;;
                :) echo "Invalid option: $OPTARG requires an argument" 1>&2 
                \?) echo "retime [-e] EXTENSION [-n]"
esac
#rename subs to match
subs=(*.$jp_ext)
#can only extract subtitles from mkv format
#1 -> video
prompt() {
        info=$(mkvinfo "$1")
        declare -A extracts
        #declare an associative array with mkvextract # & name if applicable
        i=1
        # probably clean up the grep mess here
        while grep "Track number: $i" -A 10 <<< $info > /dev/null; do
                if grep "Track number: $i" -A 10 <<< $info | grep 'subtitles' > /dev/null; then
                        name=$(grep "Track number: $i" -A 10 <<< $info| grep 'Name' | cut -d' ' -f5-)
                        display_name=${name:-$i}
                        echo $display_name
                        track=$((i - 1))
                        extracts[$track]=$display_name
                fi
                ((i++))
        done
        for i in ${!extracts[@]}; do
                echo $i
        done
}
#1 -> video to extract from
#2 -> subtitle to align
align() {

}

videos=(*.mkv)
it=$((${#subs[@]} < ${#videos[@]} ? ${subs[@] : ${#videos[@]}}))
for i in ((i=1;i<=it;i++)); do
        title=${${videos[i]}%.mkv}
        mv ${subs[i]} "${title}.${jp_ext}"
        to_align && align ${videos[i]} ${title}.${jp_ext}
done


align && 
for v in ${videos[@]}; do
        #extract 


        





#mkvextract tracks "$MKV" $ENGLISH_SUB_TRACK:"$BASE.ENG.$ENG_EXT"
#alass-cli "$BASE.ENG.$ENG_EXT" "$UNTIMED_SUB" "$BASE.retimed.$JP_SUB_EXT"
#mv "$BASE.retimed.$JP_SUB_EXT" "$UNTIMED_SUB"



