#!/usr/bin/env bash
#
# Revised from: https://github.com/he2a/av-dl
#
# Ver:
# 11 Aug. 2024. CS: Change default output video file to MP4
#
# Download the best video available but no better than 1080p,
# or the worst video if there is no video under 1080p
#
CS_VID_QUALITY='bestvideo[height<=1080][ext=mp4]+bestaudio/best[height<=1080]'

YTDLP_CMD="$(which yt-dlp)"

# echo $YTDLP_CMD

[ -f ~/bin/yt-dlp ] && YTDLP_CMD="$HOME/bin/yt-dlp"

[ -z "$YTDLP_CMD" ] && echo "yt-dlp not found!" && exit 1

# CS_VID_QUALITY='bestvideo+bestaudio/best'

# Temporary UI bugfix. Change delay if glitchy UI
sleep 0.1

# ---------------------------------------------------------------------------------
# A simple    yt-dlp script for downloading songs or video off youtube and other sites
# ---------------------------------------------------------------------------------

# Set output path for music.
music=~/Downloads/_music

# Set output path for video.
video=~/Downloads/_movies

mkdir -p $music
mkdir -p $video

# Number of retry attempts.
attempt=3

# Force default choice of download. Set to 'audio' for audio / 'video' for video / blank for manual choice.
defchoice=

# Set true to embed cover for audio download.
embedcover=true

# Set true to use thumbnail as cover for audio download or false to use default cover.
coverthumb=true

# Link to the cover image for use as default cover, including https:// part.
thumblink=

# Set true to autotrim cover to square for audio download.
autotrimthumb=false

# Set true to embed subtitles for video download.
embedsubs=true

# Set true to embed auto translated subtitles for youtube videos.
autosubs=false

# Set false to show a text instead of logo.
showlogo=false

# Set true to enable verbose mode mainly for debugging the script.
verbose=true

# 18:37 07/September/24 CS: By default we don't convert MP4 to MOV
DO_MP4_TO_MOV=false

# ----------------------------------------------------------------------------

RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
NORMAL="\033[0;39m"
DEFIMG=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
WIDTHW=$(stty size | sed 's/.* //g')

function WARN() {
	if [ "$verbose" = true ]; then
		echo -e "${YELLOW}[WARN]${NORMAL} $1"
	fi
}

function INFO() {
	if [ "$verbose" = true ]; then
		echo -e "${BLUE}[INFO]${NORMAL} $1"
	fi
}

function ENDP() {
	if [ "$verbose" = true ]; then
		echo -ne "${RED}[KILL]${NORMAL} "
		read -n 1 -s -r -p "Script Terminated."
	fi
	exit
}

function ERRR() {
	if [ "$verbose" = true ]; then
		echo -e "${RED}[KILL]${NORMAL} $1"
	else
		echo -e "${RED}ERROR:${NORMAL} $1"
	fi
	ENDP
}

function SUCC() {
	if [ "$verbose" = true ]; then
		echo -e "${GREEN}[SUCCESS]${NORMAL} $1"
	fi
}

function CTXT() {
	echo -e "$1" | sed -e :a -e "s/^.\{1,$WIDTHW\}$/ & /;ta" | tr -d '\n' | head -c "$WIDTHW"
}

function checkchoicetwo() {
	case $1 in
	$2) return 1 ;;
	$3) return 1 ;;
	*) return 0 ;;
	esac
}

function loop() {
	local i=1
	local j=$2

	while [ $i -le $j ]; do
		$1
		if [ $? -eq 1 ]; then
			return 1
			break
		else
			i=$((i + 1))
		fi
	done
	return 0
}

function init-all() {
	checkchoicetwo $verbose "true" "false"
	if [ $? -eq 0 ]; then
		verbose=false
	fi

	INFO "Initializing script."

	if [ -z "$music" ] || [ -z "$video" ]; then
		ERRR "Default download directory not specified."
	fi

	if [ -z "$1" ]; then
		INFO "No URL detected."
	else
		url=$(echo $1 | egrep -o 'https?://[^ ]+')
		if [ -z "$url" ]; then
			ERRR "Invalid URL."
		fi
	fi

	checkchoicetwo $defchoice "audio" "video"
	if [ $? -eq 1 ]; then
		cho=$defchoice
	else
		WARN "Invalid or no default choice of video detected."
		cho=n
	fi

	#
	# C. Shen 1:45:39 pm ACDT 2023-10-22
	# Now support to pass a second input argument as either --audio or --video
	# which must be after the URL input
	# avdl.sh URL --audio
	# avdl.sh URL --video
	#
	if echo "$@" | grep -E -i -q " -audio"; then
		cho=audio
	fi

	if echo "$@" | grep -E -i -q " -a"; then
		cho=audio
	fi

	if echo "$@" | grep -E -i -q " -video"; then
		cho=video
	fi

	if echo "$@" | grep -E -i -q " -v"; then
		cho=video
	fi

	if echo "$@" | grep -E -i -q " -mov"; then
		cho=video
        DO_MP4_TO_MOV=true
	fi

	checkchoicetwo $embedcover "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of embed cover image detected."
		embedcover=true
	fi

	checkchoicetwo $coverthumb "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of use thumbnail as cover detected."
		embedcover=true
	fi

	checkchoicetwo $autotrimthumb "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of auto trim thumbnail detected."
		embedcover=true
	fi

	checkchoicetwo $embedsubs "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of embed subtitles detected."
		embedcover=true
	fi

	checkchoicetwo $autosubs "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of embed auto generated subtitles detected."
		embedcover=true
	fi

	checkchoicetwo $showlogo "true" "false"
	if [ $? -eq 0 ]; then
		WARN "Invalid choice of show logo detected."
		showlogo=true
	fi

	if [ -z "$(echo $thumblink | grep -E -o 'https?://[^ ]+')" ]; then
		WARN "Invalid or no default thumbnail link detected."
		unset thumblink
	fi

	case $attempt in
	'' | *[!0-9]*)
		WARN "Invalid value for attempt detected."
		attempt=1
		;;
	*)
		if [ $attempt -le 0 ]; then
			WARN "Invalid value for attempt detected."
			attempt=1
		fi
		;;
	esac
	SUCC "Initialization completed."
}

function logo() {
	if [ "$showlogo" = true ] && [ "$verbose" = false ]; then
		echo -ne "${RED}"
		CTXT "AVDL, video dowloader"
		echo -e " "
		echo -ne "${NORMAL}"
		CTXT "A simple audio/video downloader."
		printf '%.s─' $(seq 1 $(stty size | sed 's/.* //g'))
	else
		printf '%.s─' $(seq 1 $(stty size | sed 's/.* //g'))
		echo -ne "${RED}"
		CTXT "av-dl - A simple audio/video downloader."
		echo -ne "${NORMAL}"
		printf '%.s─' $(seq 1 $(stty size | sed 's/.* //g'))
	fi
}

function getTitle() {
	INFO "Fetching title of media."
	title=$($YTDLP_CMD --get-title $url)
	if [ -z "$title" ]; then
		WARN "Title fetch failed."
		return 0
	else
		title=$(echo "$title" | tr -d "'\`\:\"\\\/\|")
		SUCC "Title fetch successful."
		return 1
	fi
}

function getAudio() {
	INFO "Fetching audio of media."
	$YTDLP_CMD --concurrent-fragments 8 -f 'bestaudio' --extract-audio --audio-format wav -o "temp_ytdl/audio.wav" $url
	if [ -f 'temp_ytdl/audio.wav' ]; then
		SUCC "Audio fetch successful."
		return 1
	else
		WARN "Audio fetch failed."
		return 0
	fi
}

function getCover() {
	INFO "Fetching album cover."
	curl "$thumblink" --create-dirs --output 'temp_ytdl/thumb_temp.tmp'
	if [ -f temp_ytdl/thumb_temp.tmp ]; then
		SUCC "Cover fetch successful."
		return 1
	else
		WARN "Cover fetch failed."
		return 0
	fi
}

function getThumb() {
	INFO "Fetching album cover."
	$YTDLP_CMD --write-thumbnail --skip-download -o 'temp_ytdl/thumb_temp' $url
	if [ -f temp_ytdl/thumb_temp.* ]; then
		SUCC "Cover fetch successful."
		return 1
	else
		WARN "Cover fetch failed."
		return 0
	fi
}

function defThumb() {
	mkdir -p temp_ytdl
	if [ -z "$thumblink" ]; then
		INFO "Writing embedded cover."
		base64 -d <<<"$DEFIMG" >temp_ytdl/thumb_temp.png
	else
		loop "getCover" $attempt
		if [ $? -eq 0 ]; then
			WARN "Default cover fetch failed. Using embedded cover."
			base64 -d <<<"$DEFIMG" >temp_ytdl/thumb_temp.png
		fi
	fi
}

function trmThumb() {
	INFO "Cropping cover."
	mv temp_ytdl/thumb_temp.* temp_ytdl/thumb_raw
	ffmpeg -hide_banner -loglevel error -i 'temp_ytdl/thumb_raw' -vf "crop=w='min(iw\,ih)':h='min(iw\,ih)',setsar=1" -q:v 2 'temp_ytdl/thumb001.jpg'

	cp temp_ytdl/thumb001.jpg temp_ytdl/thumb002.jpg
	cp temp_ytdl/thumb001.jpg temp_ytdl/thumb003.jpg

	crop=$(ffmpeg -i 'temp_ytdl/thumb%3d.jpg' -vf "cropdetect=32:1:0" -f null - 2>&1 | egrep -o "crop=[^ ]+")
	ffmpeg -y -hide_banner -loglevel error -i 'temp_ytdl/thumb001.jpg' -vf "$crop,crop=w='min(iw\,ih)':h='min(iw\,ih)',setsar=1" -q:v 2 'temp_ytdl/cover.jpg'
}

function jpgThumb() {
	INFO "Converting cover to jpeg."
	mv temp_ytdl/thumb_temp.* temp_ytdl/thumb_raw
	ffmpeg -y -hide_banner -loglevel error -i 'temp_ytdl/thumb_raw' -q:v 2 'temp_ytdl/cover.jpg'
}

# Sept. 2024 CS: Convert MP4 video to MOV
function mp4_2_mov() {

	if [ "$DO_MP4_TO_MOV" = false ]; then
		return 1
	fi

	input_file="$1"
	output_file=$(basename "$input_file" .mp4).mov
	INFO "Converting MP4 video to MOV."
	TIMEFORMAT='It took %R seconds to convert the MP4 video to MOV.'
	time {
        ffmpeg -i "$input_file".mp4 -c:v libx264 -c:a copy -f mov "$output_file"
		# H265 encoding  20:05 07/September/24 iPhone 15 doesn't support H265 encoding
		# ffmpeg -i "$input_file".mp4 -vcodec hevc_videotoolbox -q:v 60 -f mov "$output_file"
	}
}

# -----------------------------------------------------------------------------------------------

init-all $*
logo

if [ -z "$1" ]; then
	if [ "$verbose" = true ]; then
		echo -e "${BLUE}[INFO]${NORMAL} URL:"
	else
		echo "URL: "
		echo
	fi

	#read url

	url=$(gum input --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "> " --placeholder "Please input a valid URL" --width 80)

	echo

	if [ -z "$(echo $url | egrep -o 'https?://[^ ]+')" ]; then
		ERRR "Invalid URL. Make sure to include the https:// part too."
	fi
else
	if [ "$verbose" = true ]; then
		echo -e "${BLUE}[INFO]${NORMAL} URL: $url"
	else
		echo -e "URL: $url"
	fi
fi

loop "getTitle" $attempt

if [ $? -eq 0 ]; then
	WARN "Title fetch failed. Using media ID from URL."
	title=$(echo $url | sed 's/^.*v=//')
fi

title=$(echo "$title" | tr -d "'\`\"\\\/\|")
if [ "$verbose" = true ]; then
	echo -e "${BLUE}[INFO]${NORMAL} Title: $title"
else
	echo -e "Title: $title"
fi

if [ "$cho" == "n" ]; then
	echo -n -e "Media type ${GREEN}(a)${NORMAL}udio or ${GREEN}(v)${NORMAL}ideo: "
	echo

	cho=$(gum choose "audio" "video")
	# if gum is not installed, using the following
	# read cho

	echo ''
fi

case $cho in
a | A | audio | Audio | AUDIO | 1)
	cd "$music" || return 1

	loop "getAudio" $attempt

	if [ $? -eq 0 ]; then
		ERRR "Audio fetch failed."
	fi

	if [ "$embedcover" = true ]; then
		if [ "$coverthumb" = true ]; then
			loop "getThumb" $attempt
			if [ $? -eq 0 ]; then
				WARN "Thumbnail fetch failed. Using default cover."
				defThumb
			fi
		else
			defThumb
		fi
		if [ "$autotrimthumb" = true ]; then
			trmThumb
		else
			jpgThumb
		fi
		INFO "Writing audio file."
		ffmpeg -hide_banner -loglevel error -stats -i 'temp_ytdl/audio.wav' -i 'temp_ytdl/cover.jpg' -map 0:0 -map 1:0 -acodec libmp3lame -q:a 0 -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "$title.mp3"
	else
		INFO "Writing audio file."
		ffmpeg -hide_banner -loglevel error -stats -i 'temp_ytdl/audio.wav' -acodec libmp3lame -q:a 0 "$title.mp3"
	fi
	INFO "Deleting temporary files."
	rm -rf temp_ytdl

	echo "." && ls -l "$music"

	;;

v | V | video | Video | VIDEO | 2)
	cd "$video" || return 1
	if [ "$embedsubs" = true ]; then
		if [ "$autosubs" = true ]; then
			INFO "Writing video file."
			#	   $YTDLP_CMD  --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' \
			#        --merge-output-format mkv --write-sub --write-auto-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url

			# CS:
			$YTDLP_CMD --concurrent-fragments 8 -f "$CS_VID_QUALITY" \
				--no-mtime -S ext:mp4:m4a --write-sub --write-auto-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url &&
				mp4_2_mov "$title"
			echo "." && ls -l "$video"

		else
			INFO "Writing video file."

			#       $YTDLP_CMD  --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' \
			#        --merge-output-format mkv --write-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url

			$YTDLP_CMD --concurrent-fragments 8 -f "$CS_VID_QUALITY" \
				--no-mtime -S ext:mp4:m4a --write-sub --sub-lang en --embed-subs -o "$title.%(ext)s" $url &&
				mp4_2_mov "$title" &&
				echo "." && ls -l "$video"

		fi
	else
		INFO "Writing video file."
		#    $YTDLP_CMD  --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' --merge-output-format mkv -o "$title.%(ext)s" $url
		#

		$YTDLP_CMD --no-mtime --concurrent-fragments 8 -f "$CS_VID_QUALITY" -S ext:mp4:m4a \
			-o "$title.%(ext)s" $url && mp4_2_mov "$title" &&
			echo "." && ls -l "$video"

	fi
	;;

*)
	cd "$video" || return 1
	WARN "Invalid choice. Using generic settings."
	$YTDLP_CMD --no-mtime --concurrent-fragments 8 -f 'bestvideo+bestaudio/best' -S ext:mp4:m4a \
		-o "$title.%(ext)s" "$url" && mp4_2_mov "$title" &&
		echo "." && ls -l "$video"
	;;
esac
