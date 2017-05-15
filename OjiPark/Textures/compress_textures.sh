FILES="ground.jpg ground.normal.jpg skybox_left.png skybox_right.png skybox_top.png skybox_down.png skybox_front.png skybox_back.png"

BPP=4
OPTS="-e PVRTC --channel-weighting-perceptual --bits-per-pixel-$BPP --alpha-is-opacity -f PVR -m"
#FILES="ground.jpg"

for FILE in $FILES; 
do

echo $FILE

NAME=${FILE:0:${#FILE}-4}
EXT=${FILE:(-3)}

texturetool $OPTS -o ${NAME}.pvrtc -p ${NAME}.pvrtc.png $FILE

done
