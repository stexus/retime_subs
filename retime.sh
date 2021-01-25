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
align=true
while getopts ":e:n" opt; do
        case ${opt} in
                e) jp_ext="${OPTARG}"
                        ;;
                n) align=false
                        ;;
                :) echo "Invalid option: $OPTARG requires an argument" 1>&2 
                \?) echo "retime [-e] EXTENSION [-n]"
esac


#rename subs to match
subs=(*.$jp_ext)
#can only extract subtitles from mkv format
videos=(*.mkv)
it=$((${#subs[@]} < ${#videos[@]} ? ${subs[@] : ${#videos[@]}}))
for i in ((i=1;i<=it;i++)); do
        title=${${videos[i]}%.mkv}
        mv ${subs[i]} "${title}.${jp_ext}"
done

align && 

        echo "hi"

        





#mkvextract tracks "$MKV" $ENGLISH_SUB_TRACK:"$BASE.ENG.$ENG_EXT"
#alass-cli "$BASE.ENG.$ENG_EXT" "$UNTIMED_SUB" "$BASE.retimed.$JP_SUB_EXT"
#mv "$BASE.retimed.$JP_SUB_EXT" "$UNTIMED_SUB"



