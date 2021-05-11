#!/bin/ksh
# Copies directory structure and lowercase names and contents of text files
DIRUP=`dirname $PWD`
DIRNAM=`basename $PWD`
NDIR=`echo "$DIRUP/${DIRNAM}new" | tr "[:upper:]" "[:lower:]"`
mkdir $NDIR
for i in `du -a | cut -f2- -d"."`
do
	DDD=`dirname .$i | sed "s/\.//"`
	DDD=`echo $DDD | tr "[:upper:]" "[:lower:]"`
	if [ ! -d $NDIR$DDD ]
	then 
		echo "making dir $NDIR$DDD"
		mkdir $NDIR$DDD
	fi
	newi=`echo $i | tr "[:upper:]" "[:lower:]"`
	echo "$i --> $newi"
	if [ -f .$i ]
	then 
		IST=`file .$i | fgrep 'text'`
		if [ "$IST" ]
		then tr '[:upper:]' '[:lower:]' < .$i > $NDIR$newi
		else cp .$i $NDIR$newi
		fi
	fi
done
