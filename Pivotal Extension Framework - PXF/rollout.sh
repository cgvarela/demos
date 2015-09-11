#!/bin/bash
set -e
DEMO=pxf
HOSTNAME=`hostname`

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WHOAMI=`whoami`
PXF_DATA_DIR=/user/$WHOAMI/sample
NN_PORT=50070

source_bashrc()
{
	source ~/.bashrc
}

set_psqlrc()
{
	echo "\timing" > ~/.psqlrc
	
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

hadoop_init()
{
	sudo -u hdfs hdfs dfs -rm -f -r -skipTrash \"$PXF_DATA_DIR\"
}

echo ""
echo "############################################################################"
echo "This is a demonstration of Pivotal HAWQ Pivotal Extenstion Frameworkd (PXF)"
echo "Steps:"
echo "1." 
echo "2."
echo "3."
echo "4."
echo "5."
echo ""
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
echo "Init Hadoop"
echo "############################################################################"
hadoop_init
echo ""
echo "############################################################################"
echo "HAWQ Begin"
echo "############################################################################"
#HAWQ Tables
for i in $( ls *.sql ); do
	table_name=`echo $i | awk -F '.' ' { print $2 "." $3 } '`
	echo $i
	#begin time
	T="$(date +%s%N)"

	LOCATION="'pxf://$HOSTNAME:$NN_PORT$PXF_DATA_DIR?profile=HdfsTextSimple'"
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
echo "Results"
echo "############################################################################"
echo ""
psql -f report.sql
echo ""
echo "############################################################################"
echo "Explore the scripts from this demo to better understand how HAWQ works:."
echo "$PWD"
echo "############################################################################"