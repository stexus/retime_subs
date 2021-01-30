# retime_subs

Batch retime subtitles in a directory to internal subs

###Installation

1. Have bash installed.
2. Install [mkvtoolnix-cli](https://gitlab.com/mbunkus/mkvtoolnix#2-installation) for grabbing track information and extracting subtitles.
3. Install [alass](https://github.com/kaegi/alass) for retiming against the extracted subtitles (if on Arch-based system, consider the AUR).
4. Download and place `retime` into a folder in your PATH (i.e `/usr/local/bin`), or clone this repository and link the file to a folder in PATH.

###Usage

1. Navigate to a directory with untimed subtitles and videos to time against.
2. Run `retime`.

###Todos
