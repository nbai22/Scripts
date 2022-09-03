#!/bin/bash
source ./scan.lib

while getopts "m:i" OPTION;
	do case $OPTION in
		m) MODE=$OPTARG
			;;
		i) INTERACTIVE=true
			;;
	esac
done
scan_domain(){
	DOMAIN=$1
	DIRECTORY=${DOMAIN}_recon

	echo "Creating directory $DIRECTORY"
	mkdir $DIRECTORY
	case $MODE in
		nmap) nmap_scan
			;;
		dirsearch) dirsearch_scan
			;;
		crt) crt_scan
			;;
		*) nmap_scan
			sleep 3
			dirsearch_scan
			sleep 3
			crt_scan
			;;
	esac
}

report_domain(){
	DOMAIN=$1
	DIRECTORY=${DOMAIN}_recon
	echo "Generating recon report for $DOMAIN..."
	TODAY=$(date)
	echo "This scan was created on $TODAY" > $DIRECTORY/report
	if [ -f $DIRECTORY/nmap ];
		then
		echo "Results for Nmap:" >> DIRECTORY/report
		grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
	fi
	if [ -f $DIRECTORY/dirsearch ];
		then
		echo "Results for Dirsearch:" >> $DIRECTORY/report
		cat $DIRECTORY/dirsearch/dirsearch.txt >> $DIRECTORY/report
	fi
	if [ -f $DIRECTORY/crt ];
		then
		echo "Results for crt.sh:" >> $DIRECTORY/report
		jq -r ".[] | .name_value" $DIRECTORY/crt | sort -u >> $DIRECTORY/report
	fi
}

if [ INTERACTIVE ];
	then
	INPUT="BLANK"
	while [ $INPUT != "quit" ];
		do
		echo "Please enter a domain: "
		read INPUT
			if [ $INPUT != "quit" ];
				then
				scan_domain $INPUT
				report_domain $INPUT
			fi
	done
else
	for i in "${@:$OPTIND:$#}";
		do
		scan_domain $i
		report_domain $i
	done
fi
