#!/bin/bash
set -e
source ../functions.sh
DEMO=madlib
HOSTNAME=`hostname`
DATA_DIR=$1
DEMO_DIR=$2
GPFDIST_PORT=$3

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo ""
echo "############################################################################"
echo "Demo Configuration"
echo "############################################################################"
echo "DATA_DIR: $DATA_DIR"
echo "DEMO_DIR: $DEMO_DIR"
echo "GPFDIST_PORT: $GPFDIST_PORT"

if [ "$GPFDIST_PORT" == "" ]; then
	echo "Error: Unable to determine parameters for this script!"
	exit 1
fi

echo ""
echo "############################################################################"
echo "This is a demonstration of the Madlib"
echo "Steps:"
echo "1."
echo "2."
echo "3."
echo "4."
echo "5."
echo "############################################################################"
echo ""
read -p "Hit enter to continue..."
echo ""
source_bashrc
set_psqlrc
create_reports_schema "$PWD"
remove_old_log "$PWD"

echo "############################################################################"
echo "HAWQ Begin"
echo "############################################################################"
#HAWQ Tables
for i in $( ls *.hawq.sql ); do
	table_name=`echo $i | awk -F '.' ' { print $2 "." $3 } '`
	echo $i
	#begin time
	T="$(date +%s%N)"

	psql -a -P pager=off -f $i -v LOCATION=$LOCATION
	echo ""
	read -p "Hit enter to continue..."

	log
done
echo ""
echo "############################################################################"
echo "Completed HAWQ"
echo "############################################################################"
echo ""
echo "############################################################################"
echo "Results"
echo "############################################################################"
echo ""
psql -P pager=off -f report.sql
echo ""
echo "############################################################################"
echo ""
echo "Next, explore the scripts from this demo to better understand how this demo"
echo "was implemented: $PWD"
echo "############################################################################"
