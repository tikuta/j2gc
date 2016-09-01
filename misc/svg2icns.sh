#/bin/sh -eu

if [ ! $# -eq 2 ]; then
	echo "Usage: $0 [.svg] [.icns]"
	exit 1
fi


(
mkdir "$2"
cd "$2"
for s in 16 32 64 128 256 512 1024; do
	NATIVE="icon_${s}x${s}.png"
	HALF=`expr ${s} / 2`
	RETINA="icon_${HALF}x${HALF}@2x.png"
	svg2png -w ${s} -h ${s} ../$1 ${NATIVE}

	case $s in
		16 ) :;;
		32 ) cp ${NATIVE} ${RETINA};;
		64 ) mv ${NATIVE} ${RETINA};;
		128 ) :;;
		256 ) cp ${NATIVE} ${RETINA};;
		512 ) cp ${NATIVE} ${RETINA};;
		1024 ) mv ${NATIVE} ${RETINA};;
	esac
done
)
