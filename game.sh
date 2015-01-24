#!/bin/bash

#display welcome info
function dis_welcome()
{
	declare -r str='0000000010000000000000000000000000000010000100000000000000100000
0000000010000000001000001000000000100001000100000000000000101000
1111110010000000000100110011110000010001000100000000000000100100
0000010011111100000100100010010000010111101111100111111000100100
0000010100000100000000100010010010000010001000000000001000100000
0100100100001000000000100010010001000010010000000000001000111110
0010101001000000111100100010010001000011101111000010010111100000
0001010001000000000100100010010000010010100001000001010000100100
0001000001000000000100100010010000010010100010000000100000100100
0010100010100000000100101011010000100010100010000000100000101000
0010010010100000000100110010100011100010101111100001010000101000
0100010100010000000100100010000000100010100010000001001000010000
1000000100010000000100000010000000100100100010000010001000110010
0000001000001000001010000010000000100100100010000100000001001010
0000010000000100010001111111111000101001101010000000000010000110
0000100000000010000000000000000000010000000100000000000100000010'
	declare -i j=0
	declare -i row=4
	char_per_line=65
	
	echo -ne "\033[37;40m\033[5;3H"

	for ((i=0; i<${#str}; i++)); do
		if [ "$[i%char_per_line]" -eq "0" ]; then
			row=$row+1
			echo -ne "\033["$row";3H"
		fi
		if [ "${str:$i:1}" == "0" ]; then
			echo -ne "\033[37;40m "
		elif [ "${str:$i:1}" == "1" ]; then
			echo -ne "\033[31;40m%"
		fi
	done
	echo -e "\033[0m"
}

function mode_choose()
{
	clear
	echo -e "\033[8;30H1) easy mode"
	echo -e "\033[9;30H2) difficult mode"
	echo -ne "\033[22;2HPlease input your choice: "
	while [ 1 ]
	do
		read -s -n 1 mode
		case $mode in
			"1" )
				main 1
				break
				;;
			"2" )
				main 2
				;;
			*	)
				echo -ne "\033[22;2HYour choice is wrong, please try again"
		esac
	done
}

#draw a rectangular border, row first
#eg: draw_border 1 1 5 5
function draw_border()
{
	local -i i
	local -i width=$4 height=$3

	echo -e "\033[37;40m"
	for (( i=$1; i<=$height; i=i+1 )); do
		for (( j=$2; j<=$width; j=j+1 )); do
			echo -e "\033["$i";"$j"H "
		done
	done
	for (( i=$2; i<=$width; i=i+1 )); do
		echo -e "\033[$1;"$i"H-"
		echo -e "\033["$height";"$i"H-"
	done
	for (( i=$1; i<=$height; i=i+1)); do
		if [ $i == $1 -o $i == $height ]; then
				echo -e "\033["$i";$2H+"
				echo -e "\033["$i";"$width"H+"

		else
				echo -e "\033["$i";$2H|"
				echo -e "\033["$i";"$width"H|"
		fi
	done
}

function clear_all_area()
{
	local -i i j
	local -i width=$BORDER_W-2 height=$BORDER_H-2
	for (( i=5; i <=$height; i++ )); do
		for (( j=3; j <=$width; j++ )); do
			echo -e "\033[44m\033["$i";"$j"H "
		done
	done
	echo -e "\033[37;40m"
}

#display a word
#Parameters: word horizontal_coordinate vertical_coordinate matched_length
function dis_word()
{
	local i
	for (( i=0; i<${#1}; i++ )); do
		word=$1
		if [ "$3" -lt 21 ]; then
			#wrong
			#echo -e "...${1[$i]}"
			if [ "$i" -lt "$4" ]; then
				echo -e "\033[35;44m\033["$[$3+1]";"$[$2+$i]"H${word:$i:1}\033[37;40m"
			else
				echo -e "\033[37;44m\033["$[$3+1]";"$[$2+$i]"H${word:$i:1}\033[37;40m"
			fi
		fi
		if [ "$3" != 4 ]; then
		echo -e "\033[44m\033["$3";"$[$2+$i]"H \033[37;40m"
		fi
	done
}

#display game info
function dis_info()
{
	echo -e "\033[2;2HPlease enter the words before it disappear! "

	echo -e "\033[3;2HGame time:	"
	curtime=`date +%s`
	gamedonetime=$curtime-$gamestarttime
	echo -e "\033[31;40m\033[3;15H$gamedonetime s\033[37;40m"
	echo -e "\033[3;60HLife：\033[31;26m$life\033[37;40m"
	echo -e "\033[3;30HPoint：   \033[31;40m$[rightnum*10*DIF_RATE] \033[37;40m"
}

#finish typing a word
function match_word()
{
	local i
	for (( i=0; i<${#words[$1]}; i++ ))
	do
		echo -e "\033[44m\033["${wordsy[$1]}";"$[${wordsx[$1]}+$i]"H \033[37;40m"
	done
	words[$1]=""
	rightnum=$rightnum+1
}	

function game_over()
{
	draw_border $[$BORDER_H/2-2] $[$BORDER_W/2-14] $[$BORDER_H/2] $[$BORDER_W/2+14]
	echo -e "\033[$[$BORDER_H/2-1];$[$BORDER_W/2-13]HGame over, retry(Y/N)? "
	while [ 1 ]	
	do
		read -n 1 -s c 
		if [ "$c" == "y" -o "$c" == "Y" -o "$c" == "n" -o "$c" == "N" ]

		then
			break
		fi	
	done
	case $c in
		"Y"|"y"	)
			main $DIF_RATE
			;;
		"n"|"N"	)
			menu
			;;
		*		)
			;;
	esac
}

function menu()
{
	clear
	echo -e "\033[8;30H1) start gamee"
	echo -e "\033[9;30H2) rank"
	echo -e "\033[10;30H3) quit game"
	echo -ne "\033[22;2HPlease input your choice: "
	while [ 1 ]
	do
		read -s -n 1 mode
		case $mode in
			"1" )
				mode_choose 
				break
				;;
			"2" )
				exit 0
				;;
			"3" )
				do_exit 0
				;;
			*	)
				echo -ne "\033[22;2HYour choice is wrong, please try again"
		esac
	done
}

function main()
{
	declare -ir DIF_RATE=$1
	declare -i gamestarttime=0 gamedonetime=0 curtime
	declare -i rightnum=0 totnum=0
	
	local i
	declare -i timecnt1 timecnt2 
	declare -i life=$[6/DIF_RATE]
	declare -a words wordsx wordsy wordsmatch

	gamestarttime=`date +%s`
	#read words from file
	exec 4<&-
	exec 4<words.txt

	#init array
	for (( i=0; i<10; i++ ))
	do
		words[i]=""
		wordsmatch[i]=0
	done

	draw_border 1 1 $BORDER_H $BORDER_W
	clear_all_area

	while [ 1 ]
	do
		timecnt1=$timecnt1+1
		dis_info 		

		#check input 0.1s a time
		if read -n 1 -t 0.1 -s tmp; then
			#check if tmp is part of a word
			for(( i=0; i<$MAX_WORDS; i++ )); do
				word=${words[$i]}
				if [ "$word" == "" ]; then
					continue	
				fi

				if [ "$tmp" == ${word:${wordsmatch[$i]}:1} ]; then	
					wordsmatch[$i]=$[${wordsmatch[$i]}+1]	
					if [ ${wordsmatch[$i]} == ${#word} ]; then
						#finish a word
						match_word $i
					fi
				else
					wordsmatch[$i]=0
				fi
			done
		fi

		#Every 10 timecnt1(1s) move words 
		if [ "$[timecnt1%(10/DIF_RATE)]" == 0 ]; then
			timecnt2=$timecnt2+1
			#every 20 timecnt1(2s) add a new word
			if [ "$[timecnt2%2]" == 0 ]; then
				#add new words
				for (( i=0; i<$MAX_WORDS; i++ )); do
					if [ "${words[$i]}" == "" ]; then
						read -u 4 words[$i]
						wordsx[$i]=$[$RANDOM%40+10]
						wordsy[$i]=4
						wordsmatch[$i]=0
						break
					fi
				done
			fi
			#move words
			for (( i=0; i<10; i++ )); do
				if [ "${words[$i]}" != "" ]; then
					if [ "${wordsy[$i]}" == 22 ]; then
						#lose life 
						words[$i]=""
						life=$life-1
						dis_info
						if [ "$life" == 0 ]; then
							#end game
							game_over 
						fi
					else
						dis_word ${words[$i]} ${wordsx[$i]} ${wordsy[$i]} ${wordsmatch[$i]}		
						wordsy[$i]=$[${wordsy[$i]}+1]
					fi
				fi
			done
		fi

#		sleep 0.1
	done
			
}

function do_exit()
{
	clear
	echo -e "\033[37;40m\033[?25h\033[u"	
	exit $1 
}

#hide cursor
echo -e "\033[?25l"
#declare border size
declare -ir BORDER_W=79 BORDER_H=23
#Max number of words could exist at one time
declare -ir MAX_WORDS=20
#force exit
trap " do_exit 1 " 2
#log error info
echo `date +%F`>>error.log 
exec 2>>error.log
clear
dis_welcome
sleep 1
menu

