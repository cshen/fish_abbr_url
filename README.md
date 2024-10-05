# fish_abbr_url

Fish shell plugin to handle terminal input:

    ``https://... or file'', e.g.,

type ``final.tex''  it will expand into:
 
``pdflatex final.tex; bibtex final.aux''

type an arxiv or youtube URL link, it will expand into commands to download the arxiv paper/video


Note: *Only tested on WSL with Ubuntu; fish, version 3.7.1*
I will port to macOS once I get time

## Install
1. Using [fundle](https://github.com/danhper/fundle):

Add this to your ``~/.config/fish/config.fish''
 or any file that you use to load fundle's plugins (in ``/etc/fish'' for example):
```sh
fundle plugin 'cshen/fish_abbr_url'
fundle init
``` 

2. Reload the shell and Run ``fundle install''

3. Add this line into your ``config.fish'': 
```sh
    set -Ua fish_features qmark-noglob
```
See https://fishshell.com/docs/3.4/language.html#featureflags for details


## Requirements

[gum](https://github.com/charmbracelet/gum)
       
[avdl.sh](https://github.com/he2a/av-dl), downoad the script and rename it as `avdl.sh'
       
[axs](https://github.com/cshen/arxiv_download) 
            ```sh
            pipx install git+https://github.com/cshen/arxiv_download
```

## Optional:
       win32yank.exe (for WSL), bat, pdflatex/bibtex (texlive)


