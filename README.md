# fish_abbr_url

[Fish shell](https://fishshell.com/) plugin to handle terminal input:
    ``https://... or file``, e.g.,

type ``final.tex``  it will expand into:
``pdflatex final.tex; bibtex final.aux``

type an arxiv or youtube URL link, it will expand into commands to download the arxiv paper/video

Note: *Tested on WSL with Ubuntu; fish, version 3.7.1*, and macOS with homebrew (kitty, and iTerm2). 

- docx2pdf only works on macOS,  CS: 24 Oct 2024 17:22 


for macOS, iTerm2, turn on "advanced experimental feature: Escape file names with single quotes instead of backslashes"


## Install
1. Using [fundle](https://github.com/danhper/fundle):

Add this to your ``~/.config/fish/config.fish``
 or any file that you use to load fundle's plugins (in ``/etc/fish`` for example):
```sh
fundle plugin 'cshen/fish_abbr_url'
fundle init
``` 

2. Reload the shell and Run ``fundle install``



3. Run ``status features`` to check the flags, you must have 
```
qmark-noglob            on  3.0 ? no longer globs
```
See https://fishshell.com/docs/3.4/language.html#featureflags for details.

Or,  add this line into your ``config.fish``: 
```sh
    set -Ua fish_features qmark-noglob
```

Restart fish and check again.


## Requirements

[gum](https://github.com/charmbracelet/gum)
       
[avdl.sh](https://github.com/he2a/av-dl), downoad the script and rename it as ``avdl.sh``
       
[axs](https://github.com/cshen/arxiv_download) 


```sh
    pipx install git+https://github.com/cshen/arxiv_download
```
NOTE: Oct 2024, On macOS, pipx installing with python3.13 results in missing packages. With Python 3.12, it works
```sh
pipx install --python python3.12 git+https://github.com/cshen/arxiv_download
```

## Optional:
       win32yank.exe (for WSL), bat, pdflatex/bibtex (texlive)


