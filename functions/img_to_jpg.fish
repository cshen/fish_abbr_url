#!/usr/bin/env fish


# Define a function to convert HEIC to JPEG
function img_to_jpeg
    if not set -q argv[1] # Check if an argument is provided
        echo "Usage: img_to_jpeg <image file>"
        return 1
    end

    set img_file "$argv[1]"

    if not test -f "$img_file"                    # Check if the file exists
        echo "$img_file does not exist"
        return 1
    end

    set ext (ext_name $img_file) 
    test $ext = "jpg" && return 1
    
    set jpeg_file (remove_ext_name $img_file).jpg
    echo ... process $img_file
    magick  "$img_file"  "$jpeg_file"              # Convert using ImageMagick's convert command
end


command_exist magick || exit 1

# Check if there is one input argument
if test -z $argv[1] 

    echo "Usage: an input file or directory needed"
    # Get the current directory
    exit 1
    
else
    # Get the directory argument
    
    if test -f $argv[1] 
        img_to_jpeg $argv[1] 
        exit 0
    end

    set directory $argv[1]

    # Check if the directory exists
    if not test -d "$directory"
        echo "Error: Directory or file $directory does not exist."
        exit 1
    else
        
        for f in ( find . -type f | grep -e \.png -e \.heic 2> /dev/null )
            img_to_jpeg "$f"
        end
    end

end







