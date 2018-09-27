
#!/bin/bash

# zenity Stuff ...
TOPMARGIN=27
RIGHTMARGIN=10
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
W=$(( $SCREEN_WIDTH / 2 - $RIGHTMARGIN ))