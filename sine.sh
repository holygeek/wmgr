width=1920
height=1080

x_o=0
y_o=$(($height / 2))

# 2*pi=360
# # 1 rad =180deg/pi
pi=3.1428571428
deg2rad() {
    echo "$1 / 180 * $pi"|bc -l
}
for x in `seq $x_o 2 $width`; do
    x_rad=`deg2rad $x`
    y=`echo "$y_o + $height / 4 * s($x_rad) "|bc -l|sed -e 's/\..*//'`
    # On wayland use ydotool https://github.com/ReimuNotMoe/ydotool
    xdotool mousemove $x $y
done
