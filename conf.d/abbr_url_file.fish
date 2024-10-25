
# See https://fishshell.com/docs/3.4/language.html#featureflags for details.
set -Ua fish_features qmark-noglob

function __is_WSL
    return (uname -a | grep -q WSL)
end

function __is_mac
    return (test $(uname) = 'Darwin')
end

# it's WSL
__is_WSL && set OPEN_CMD explorer.exe
__is_mac && set OPEN_CMD open

# requirements:
#       gum (https://github.com/charmbracelet/gum)
#       avdl.sh (https://github.com/he2a/av-dl, downoad the script and rename it as `avdl.sh')
#                Recommend to use the avdl.sh provided in the `tool' directory, which is heavily modified for the purpose of this script
#       axs (pipx install git+https://github.com/cshen/arxiv_download)
#
# Optional:
#       win32yank.exe (for WSL), pdflatex/bibtex (texlive) 
#       docx2pdf, (pipx install docx2pdf), otherwise the script falls back to open the word doc only


#-------------------------------------------------
# When type a certain type of file names in the command line, automatically call appropriate software
#-------------------------------------------------
# CS: 2-Oct-2024 16:56, drag a file in Windows into Windows Termial (fish) and a corresponding abbr, if any, will be called  
# Escaped file name supported too

function _vim_edit
    echo gvim $argv
end

function _cat_file
    if type -q bat 
        echo 'bat ' $argv
    else
        echo 'cat ' $argv
    end
end

function _img_file
    set -l act $( gum choose "1. open the image?" "2. convert the image to jpeg?" "3. abort" )
    if string match -q "1*" $act
        echo open "$argv"
        return 0
    end

    if string match -q "2*" $act
        echo img_to_jpg  "$argv"
        return 0
    end

    echo "#  ... nothing to do."
end

abbr -a vim_edit_texts --position command --regex ".+\.(txt|conf|config)" --function _vim_edit
abbr -a vim_edit_texts --position command --regex "config.*" --function _vim_edit

abbr -a cat_texts --position command --regex ".+\.(md|MD|jemdoc|config|vim)" --function _cat_file
abbr -a img_file --position command --regex ".+\.(png|PNG|HEIC|heic)\"?\'?" --function _img_file

function _compile_latex
    #
    # For input like "xxxx", we need to remove the double quotes
    # CS: 25 Oct 2024 16:10 in fish, string unescape can do the following which is much simpler
    # I will clean up the code once I have time. For now the poor man's solution just works
    set PDFCMD pdflatex
    type -q pdflatex-quiet && set PDFCMD pdflatex-quiet 

    set -l first_char $( echo $argv | string trim | string sub -s 1 -e 1 )
    set -l last_char $( echo $argv | string trim | string sub -s -1 )
    if [ $first_char = "\"" -a $last_char = "\"" ]
        set myargv (echo $argv | string sub -s 2 -e -1 )
    else if [ $first_char = "'" -a $last_char = "'" ]
        set myargv (echo $argv | string sub -s 2 -e -1 )
    else
        set myargv $argv
    end
    
    __is_WSL && set -l F $( wslpath -a -u $myargv ) || \
    set -l F "$myargv"
    
    set -l MDIR $(path dirname $F  )
    set -l TEXFILE $(path basename  $F  )
    set -l AUXFILE $( basename "$TEXFILE" .tex ).aux

    echo -n "# Changing dir from: $(pwd) --> "
    builtin cd $MDIR
    echo "$(pwd)"

    # echo "# Current dir: " $(pwd)
    echo "for i in 1 2"
    echo "    $PDFCMD $TEXFILE"
    echo "    bibtex" "$AUXFILE"
    echo end
    echo ""
end
# abbr -a compile_latex --position command --regex ".+\.(tex|TEX)" --function _compile_latex
abbr -a compile_latex --position command --regex ".+\.(tex|TEX)\"?\'?" --function _compile_latex


function _docx2pdf
    
    set -l DOCX_CMD $OPEN_CMD
    type -q docx2pdf && set DOCX_CMD  docx2pdf 

    
    set -l first_char $( echo $argv | string trim | string sub -s 1 -e 1 )
    set -l last_char $( echo $argv | string trim | string sub -s -1 )
    if [ $first_char = "\"" -a $last_char = "\"" ]
        set myargv (echo $argv | string sub -s 2 -e -1 )
    else if [ $first_char = "'" -a $last_char = "'" ]
        set myargv (echo $argv | string sub -s 2 -e -1 )
    else
        set myargv $argv
    end
    
    __is_WSL && set -l F $( wslpath -a -u $myargv ) || \
    set -l F "$myargv"
    
    set -l MDIR $(path dirname $F  )
    set -l DOCXFILE $(path basename  $F  )
    # set -l AUXFILE $( basename "$TEXFILE" .docx ).pdf

    echo -n "# Changing dir from: $(pwd) --> "
    builtin cd $MDIR
    echo "$(pwd)"

    # echo "# Current dir: " $(pwd)
   
    echo "    $DOCX_CMD $DOCXFILE"

end
abbr -a docx_to_pdf --position command --regex ".+\.(docx|DOCX)\"?\'?" --function _docx2pdf


# The following function is not used for now
function mypdflatex

    set -l F "$argv"
    __is_WSL && set -l F $( wslpath -a -u "$argv" )
    
    set -l MDIR $(path dirname "$F"  )
    set -l TEXFILE $(path basename  "$F"  )
    set -l AUXFILE $( basename "$TEXFILE" .tex ).aux
    set -l PDFFILE $( basename "$TEXFILE" .tex ).pdf

    set PDFCMD pdflatex
    type -q pdflatex-quiet && set PDFCMD pdflatex-quiet 

    builtin cd $MDIR
    pwd
    for i in 1 2
        $PDFCMD $TEXFILE
        bibtex $AUXFILE
    end

    echo "... open $PDFFILE to view the PDF file"
    
    # copy to clipboard   
    if type -q win32yank.exe 
        echo "open $PDFFILE" | win32yank.exe -i
    end

end


# https://github.com/fish-shell/fish-shell/issues/9411
# function git_c
#    string match --quiet 'git c ' -- (commandline -j); or return 1
#    echo checkout
# end
# abbr -a git_c --position anywhere --regex c --function git_c

function _open_file
    # set -l cmd (commandline --current-buffer)
    # if it's quoted already, echo the string directly.
    set -l first_char $( echo $argv | string trim | string sub -s 1 -e 1 )
    set -l last_char $( echo $argv | string trim | string sub -s -1 )
    if [ $first_char = "\"" -a $last_char = "\"" ]
        echo $OPEN_CMD "$argv"
    else
        echo $OPEN_CMD \"$argv\"
    end
end
abbr -a open_file --position command --regex ".+\.(pdf|PDF)\"?" --function _open_file

# function range_expansion
#    # Replace all non-digits with spaces, then split on whitespace.
#    set -l values (echo $argv | tr -cs '[:digit:]' ' ' | string split ' ' --no-empty)
#    echo "(seq $values[1] $values[2])"
# end
# abbr --add range_expand_abbr --position anywhere --regex "\{\d+\.\.\d+\}" --function range_expansion

function _youtube_download
    echo avdl.sh $argv
end
# abbr -a youtube_download --position command --regex "https:\/\/www\.youtube.*" --function _youtube_download
# abbr -a xiaohongshu_download --position command --regex "https:\/\/www\.xiaohongshu.*" --function _youtube_download
#
# CS: 24 Oct 2024 14:43, URL may start with " or ' in the terminal
abbr -a youtube_download --position command --regex "\"?\'?https:\/\/www\.youtube.*" --function _youtube_download
abbr -a xiaohongshu_download --position command --regex "\"?\'?https:\/\/www\.xiaohongshu.*" --function _youtube_download

function _arxiv_download
    # extract arxiv id
    # https://arxiv.org/pdf/2410.00890
    # https://arxiv.org/abs/2410.00890
    set -l ID $( echo $argv | rev | awk -F/ '{print $1}' | rev )

    # When the URL is quoted with " or ', the above will have " or ' at the tail, remove it
    set -l ID $( echo $ID | sed 's/"//g' | sed 's/\'//g' )  
    
    mkdir -p $HOME/Downloads/_arXiv

    # using axs to download. Install:  pipx install git+https://github.com/cshen/arxiv_download   
    echo "axs get -d $HOME/Downloads/_arXiv $ID; arxiv_bib $ID $HOME/Downloads/_arXiv/_cs_arxiv.bib"
    
    # ls -l --color -t $HOME/Downloads/_arXiv
    # type -d detox && detox $HOME/Downloads/_arXiv/*
end
abbr -a arxiv_download --position command --regex "\"?\'?https:\/\/arxiv.*" --function _arxiv_download
#-------------------------------------------------


function _extract_compression 
    set -l EXT_CMD $OPEN_CMD
    type -q dtrx && set EXT_CMD  "dtrx -v --one inside"

    set -l first_char $( echo $argv | string trim | string sub -s 1 -e 1 )
    set -l last_char $( echo $argv | string trim | string sub -s -1 )
    if [ $first_char = "\"" -a $last_char = "\"" ]
        set myargv (echo $argv | string sub -s 2 -e -1 )
    else if [ $first_char = "'" -a $last_char = "'" ]
        set myargv (echo $argv | string sub -s 2 -e -1 )
    else
        set myargv $argv
    end
    
    __is_WSL && set -l F $( wslpath -a -u $myargv ) || \
    set -l F "$myargv"
    
    set -l MDIR $(path dirname $F  )
    set -l MYFILE $(path basename  $F  )

    echo -n "# Changing dir from: $(pwd) --> "
    builtin cd $MDIR
    echo "$(pwd)"

    # echo "# Current dir: " $(pwd)
   
    echo "    $EXT_CMD  $MYFILE"

end 
abbr -a extract_me --position command --regex ".+\.(7z|Z|bz2|cpio|gz|jar|lzma|rar|tar|taz|tb2|tbz|tbz2|tgz|txz|xz|zip|zst|zstd)\"?\'?" --function _extract_compression

# supported extensions
# 
# 7z, Z, arj, br, bz2, cab, cpio, crx, gz, jar, lha, lrz, lz, lzh, lzma, rar, tar, taz, tb2, tbz, tbz2, tgz, tlz, txz, xz, zip, zst, zstd
#
