#!/usr/bin/gnuplot

set xrange [240:1280+256]
set yrange [-5:110]

set terminal png size 1200,650 enhanced font "Roboto, 24"
set origin 0,0
set size 1,0.7

set format y "%g%%"
set ylabel "Failure rate"
set xlabel "IP datagram size [bytes]"

set output '42-failure-vs-datagram-size.png'

set grid mxtics
set xtics 256
set mxtics 4
set grid mxtics xtics ytics 
set grid mxtics lt 0 lw 0.5 lc rgb "light-gray"

set style line 4 dt 2 lw 2 lc rgb "black"

set arrow 1 from 301,70 to 365,70 heads filled lw 2 lc rgb "web-green" front
set arrow 2 from 256,105 to screen 0.151,0.897 nohead lc rgb "gray" back
set arrow 3 from 512,95 to screen 0.93,0.75 nohead lc rgb "gray" back

set label 1 "64" at 327,77 textcolor rgb "web-green" center
set object 1 rectangle from 256,95 to 512,105 \
	fillcolor rgb "cyan" \
	fillstyle solid 0.1 \
	border lc rgb "#707070"

set multiplot

plot '42-failure-vs-datagram-size.dat' \
	using 1:($1 < 1492 ? $2 : NaN) \
	with linespoints \
	linecolor rgb 'blue' \
	pointtype 5 pointsize .5 \
	notitle


# Inset plot - zoomed in
set origin 0.05,0.65
set size 0.93,0.3

set border lc rgb "#707070"
set xtics textcolor rgb "#707070"
set ytics textcolor rgb "#707070"

unset arrow 1
unset arrow 2
unset arrow 3
unset label 1
unset object 1

set object 4 rectangle \
	from graph 0,0 \
	to graph 1,1 \
	fillcolor rgb "cyan" \
	fillstyle solid 0.1 \
	behind

set arrow 4 from 301,101 to 365,101 heads filled lw 2 lc rgb "web-green" front
set label 2 "64" at 333,103 textcolor rgb "web-green" center

unset mxtics
set xtics 64
set ytics 10
set xrange [256:512]
set yrange [95:105]

unset xlabel
unset ylabel

plot '42-failure-vs-datagram-size.dat' \
	using 1:($1 < 1492 ? $2 : NaN) \
	with linespoints \
	linecolor rgb 'blue' \
	pointtype 5 pointsize .5 \
	notitle

unset multiplot
set output