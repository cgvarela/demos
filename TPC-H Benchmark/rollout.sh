#!/bin/bash
set -e
DEMO=tpch
HOSTNAME=`hostname`
DATA_DIR=$1
DEMO_DIR=$2
GPFDIST_PORT=$3

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo ""
echo "############################################################################"
echo "Demo Configuration"
echo "############################################################################"
echo "GPFDIST_PORT: $GPFDIST_PORT"

if [ "$GPFDIST_PORT" == "" ]; then
	echo "Error: Unable to determine parameters for this script!"
	exit 1
fi

source_bashrc()
{
	source ~/.bashrc
}

set_psqlrc()
{
	echo "\timing" > ~/.psqlrc
	
}

start_gpfdist()
{
	local count=`ps -ef | grep gpfdist | grep $GPFDIST_PORT | grep -v grep | wc -l`
	if [ "$count" -eq "1" ]; then
		gpfdist_pid=`ps -ef | grep gpfdist | grep $GPFDIST_PORT | grep -v grep | awk -F ' ' '{print $2}'`
		if [ "$gpfdist_pid" != "" ]; then
			echo "Stopping gpfdist on pid: $gpfdist_pid"
			kill $gpfdist_pid
			sleep 2
		fi
	else
		echo "Starting gpfdist port $GPFDIST_PORT"
		echo "Diretory for gpfdist: \"/$DATA_DIR/$DEMO_DIR\"
		echo "gpfdist -d \"/$DATA_DIR/$DEMO_DIR\" -p $GPFDIST_PORT >> /dev/null 2>&1 < /dev/null &"
		gpfdist -d /$DATA_DIR/$DEMO_DIR -p $GPFDIST_PORT >> /dev/null 2>&1 < /dev/null &
		gpfdist_pid=$!

		# check gpfdist process was started
		if [ "$gpfdist_pid" -ne "0" ]; then
			sleep 0.4
			count=`ps -ef 2> /dev/null | grep -v grep | awk -F ' ' '{print $2}' | grep $gpfdist_pid | wc -l`
			if [ "$count" -eq "1" ]; then
				echo "gpfdist started on port $GPFDIST_PORT"
			else
				echo "ERROR: gpfdist couldn't start on port $GPFDIST_PORT"
				exit 1
			fi
		fi
	fi
}

stop_gpfdist()
{
	if [ "$gpfdist_pid" != "" ]; then
		echo "Stopping gpfdist on pid: $gpfdist_pid"
		kill $gpfdist_pid
	fi
}

log()
{
	#duration
	T="$(($(date +%s%N)-T))"

	id=`echo $i | awk -F '.' ' { print $1 } '`

	# seconds
	S="$((T/1000000000))"
	# milliseconds
	M="$((T/1000000))"

	printf "$id|$table_name|%02d:%02d:%02d.%03d\n" "$((S/3600%24))" "$((S/60%60))" "$((S%60))" "${M}" >> rollout.log
}

create_reports_schema()
{
	local schema_count=`psql -A -t -c "SELECT count(*) from pg_namespace WHERE nspname = 'reports'"`
	if [ "$schema_count" -eq "0" ]; then
		psql -c "CREATE SCHEMA reports;"
	fi

	local table_count=`psql -A -t -c "SELECT count(*) from pg_namespace n JOIN pg_class c ON c.relnamespace = n.oid  WHERE n.nspname = 'reports' AND c.relname = '$DEMO' AND relstorage = 'x'"`
	if [ "$table_count" -eq "0" ]; then
		psql -c "CREATE EXTERNAL WEB TABLE reports.$DEMO (id int, table_name varchar, duration time) EXECUTE 'cat \"$PWD/rollout.log\"' ON MASTER FORMAT 'TEXT' (DELIMITER '|');"
	fi
}

echo ""
echo "############################################################################"
echo "This is a demonstration of the performance and SQL compliance of Pivotal"
echo "HAWQ using the TPC-H benchmark. The size of the benchmark is 1GB which was"
echo "chosen to work on a single node VM.  Also, the tables are stored in the"
echo "parquet format using snappy compression." 
echo "The TPC-H benchmark has defined queries with parameters that should be"
echo "chosen at random.  To simplify this demo, the \"query validation\""
echo "parameters were used for all queries instead of picking a value at random."
echo "Steps:"
echo "1. Create a \"reports\" schema in HAWQ to store execution times"
echo "2. Load 1GB of TPC-H data into HAWQ"
echo "3. Create and load tables into HAWQ"
echo "4. Execute TPC-H SELECT statements with HAWQ"
echo "5. Capture performance metrics for each step with the grand total"
echo "############################################################################"
echo ""
read -p "Hit enter to continue..."
echo ""
echo "############################################################################"
echo "Source .bashrc"
echo "############################################################################"
source_bashrc
echo ""
echo "############################################################################"
echo "Set the .psqlrc file"
echo "############################################################################"
set_psqlrc
echo ""
echo "############################################################################"
echo "Start gpfdist process"
echo "############################################################################"
start_gpfdist
echo ""
echo "############################################################################"
echo "Create reporting schema for later analysis of HAWQ"
echo "############################################################################"
create_reports_schema
echo ""
echo "############################################################################"
echo "Remove old logs"
echo "############################################################################"
rm -f rollout.log
echo ""
echo "############################################################################"
echo "HAWQ Begin"
echo "############################################################################"
#HAWQ Tables
for i in $( ls *.hawq.sql ); do
	table_name=`echo $i | awk -F '.' ' { print $2 "." $3 } '`
	echo $i
	#begin time
	T="$(date +%s%N)"

	#check to see if there are more than one file for this table
	count=`ls \"$PWD/data/\"$table_name.* 2> /dev/null | wc -l`

	if [ "$count" -ge "1" ]; then
		LOCATION="'gpfdist://$HOSTNAME:$GPFDIST_PORT/$table_name.*'"
	else
		LOCATION="'gpfdist://$HOSTNAME:$GPFDIST_PORT/$table_name'"
	fi
	psql -a -P pager=off -f $i -v LOCATION=$LOCATION
	echo ""

	log
done
echo ""
echo "############################################################################"
echo "Completed HAWQ"
echo "############################################################################"
echo ""
echo "############################################################################"
echo "Stop gpfdist process"
echo "############################################################################"
stop_gpfdist
echo ""
echo "############################################################################"
echo "Results"
echo "############################################################################"
echo ""
psql -P pager=off -f report.sql
echo ""
echo "############################################################################"
echo "Notice the Average Load Time, Average Query Time, and Total Time."
echo "Next, explore the scripts from this demo to better understand how this demo"
echo "was implemented: $PWD"
echo "############################################################################"
