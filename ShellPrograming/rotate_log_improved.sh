#!/bin/bash
# Backup old log file and create new log
# By Noel Yang, Jan 21st, 2016

# Transform long options to short ones
# This part could also be done with getopt command 
# However, there are multiple versions of getopt on different OS
# Thus, for compatibility concern, this dirty-but-quick method was applied here
for arg in "$@"
do
	case "$arg" in
		"--mode")	set -- "$@" "-m" ;;
		"--size")	set -- "$@" "-s";;
		*)			set -- "$@" "$arg";;
	esac
	shift
done

# Default behavior of the script
scriptName=`basename $0`
backupMethod="moveBackup"
noBackup=false

# Function printing help info
printHelp () {
	echo "This is a script to rotate log files. Old log files will be renamed and archived."
	echo "Usage: $scriptName [OPTIONS] logfile"
	echo ""
	echo "Available options: "
	echo " -n:        No real backup will be made, but other options will work normally."
	echo ' -m/--mode: Backup mode, you can choose from "move" / "copytruncate":'
	echo '            move:  Use "mv" and "touch" command to backup and create new log.'
	echo '            copytruncate: Use "cp" and "truncate" command to do the job.'
	echo " -s/--size: Backup size threshold:
	    Log file will not be backed up if it is smaller than given size.
	    Default in bytes, formats like '5M/m\300K/k' are also supported (up to G/g)."
	echo " -z:        Compress count X. Old backup files whose numbers are higher than 
	    X will be compressed with gunzip and archived."
	echo " -h:        Show this info"
	echo ""
}

# Function telling user to read help ;)
readHelp () {
	echo "Use $scriptName -h to get help."
}

# Functions doing the real stuffs
# Function checking the size of current log file, work with -s option
checkSize () {
	# Get the size of current log file
	local fileSize=`ls -1l | grep "$1\$" | gawk '{print $5}'`
	# Convert the unit of --size parameter to bytes
	local minSizeUnit=`echo $2 | sed 's/[0-9]//g'`
	local minSizeNum=`echo $2 | sed 's/[KMGkmg]//g'`
	case $minSizeUnit in
		K|k) local convertMinSize=$[ $minSizeNum * 1024 ];;
		M|m) local convertMinSize=$[ $minSizeNum * 1024 * 1024 ];;
		G|g) local convertMinSize=$[ $minSizeNum * 1024 * 1024 *1024 ];;
		*)  local convertMinSize=$minSizeNum;;
	esac
	# Check if the logfile is too small to backup
	if [ $fileSize -lt $convertMinSize ]
	then
		echo "Current logfile is smaller than given size: $minSize"
		echo "ATTENTION: No backup and no modification to old backups were made!"
		exit 0
	else
		return 0
	fi
}


# Function recursively processing files
# $1 file prefix, $2 command
recurFile () {
	local error=false
	# Get file list and the latest file number
	local fileList=`ls | grep $1 | grep -v gz | sort -t'.' -k 2 -nr`
	local fileCount=`echo $fileList | awk '{print $1}' | sed "s/$1\.\?//"`
	
	# Check if the structure of log files is correct
	for file in $fileList
	do
		
		# Add correct files to a list of files going to be processed later
		if [ -e $1".$fileCount" ] || [ $fileCount -eq 0 ]
		then
			local procFile=$procFile" $file"
		
		# If log file doesn't exist but its archive does, tell user to upzip it first
		elif [ -e $1".$fileCount.gz" ]
		then
			error=true
			echo "ATTENTION: Log file $1.$fileCount is missing!"
			echo "ATTENTION: Log file $1.$fileCount's archive is found!"
			# Here, according to the original requirements, some errors might be found.
			# With rule #4, after multiple times of backup, the filename in the archived file
			# will be different with the archive file. For example, after 2 times of backing up with
			# low z value, the file in filename.n.gz might actually be filename.n-1, instead of
			# filename.n
			echo "ERROR: Unzip $1.$fileCount.gz first!(Mind the file name)"
		
		# If the log file and its archive were both missing, set $error as true
		else
			error=true
			echo "ERROR: Nethier log file $1.$fileCount or its archive was found!"
			echo "ERROR: Check your log files!"
			echo "ERROR: You can remove files older than the missing one and try again."
		fi
		fileCount=$[ $fileCount - 1 ]
	done

	# If errors were detected, exit and notify user
	if $error
	then
		echo "ERROR: No changes were made to the log files!"
		readHelp
		exit 1

	# If no error was detected, do normal backup
	else 
		for file in $procFile
		do
			local number=`echo $file | sed "s/$1\.\?//"`
			local newNumber=$[ $number + 1 ]
			local newName=$1".$newNumber"
			$2 $file $newName
		done
	fi
}	

# Function backing up the current files with mv and touch
# $1 file prefix
moveBackup () {
	# Change names of log files
	recurFile $1 mv
	# Create new log file with touch
	touch $1
	echo "Log files were backed up with move method!"
}

# Function backing up the current files with cp and truncate
# $1 file prefix
trunBackup () {
	# Copy old log files
	recurFile $1 cp
	# Empty new log file with truncate
	truncate -s 0 $1
	echo "Log files were backed up with copytruncate method!" 
}


# Function compress the old files
# If -n is specified, current log files will be compressed according to given -z parameter
# $1: file prefix, $2: compress count value
compLog () {
	# get latest file number
	local fileNum=`ls | grep "$1" | grep -v "gz" | wc -l`
	# Calculate true file number n
	fileNum=$[ $fileNum - 1 ]
	
	# Compare  file number and given compress count
	# if n < count-1, no compression will be done
	if [ $fileNum -lt $[ $2 - 1 ] ]
	then
		echo "ATTENTION: No files were compressed due to high -z parameter."
		exit 0

	# If n >= count, compress all the current log file whose number is larger than $count-1
	# All the .gz file whose number is smaller than $count -1 will be removed
	else
		# Working from the file with the largest n
		for (( i=$[ $fileNum ]; i >= $2; i-- ))
		do
			# Generate file names
			local file=$1".$i"
			# If current log file exists, compress the current log file
			if [ -e $file ]
			then
				tar -czf $file".gz" $file
			# If current log file was missing, exit with error
			else
				echo "ERROR: Backup file $file is missing!"
				exit 1
			fi
		done

		# Remove old archive files to keep files organised
		for (( i=1; i<$2; i++ ))
		do
			# Generate file names
			local file=$1".$i.gz"
			# If old archive files whose number is smaller than $count exist, remove them
			if [ -e $file ]
			then
				rm $file
				echo "ATTENTION: Old archived log file $file was removed due to speicified -z value"
			fi
		done
	fi
}


# Parse transformed short options
OPTIND=1
while getopts "nm:s:z:h" opt
do
	case "$opt" in
		n)	noBackup=true;;
		# Check validity of -m/--mode option parameter
		m)	if [ "$OPTARG" = "move" ]
			then
				backupMethod="moveBackup"
			elif [ "$OPTARG" = "copytruncate" ]
			then
				backupMethod="trunBackup"
			else
				echo 'Error: -m/--mode must be "move" or "copytruncate"!'
				readHelp
				exit 1
			fi;;
		# Check validity of -s/--size option parameter
		s)	if [ `echo "$OPTARG" | grep -e "^[0-9]\+[KMGkmg]\?\$"` ]
			then
				minSize=$OPTARG
			else
				echo "Error: Wrong format for -s/--size option!"
				readHelp
				exit 1
			fi;;
		# Check validity of -z option parameter
		z)	if [ `echo "$OPTARG" | grep -e "[^0-9]"` ] && [ $OPTARG -le 0 ]
			then
				echo "Error: Wrong format for -z option! Only positive integer supported!"
				readHelp
				exit 1
			else
				count=$OPTARG
			fi;;
		h)	printHelp
			exit 0;; 
		*)	echo "!! Unknow option: $opt";;
	esac
done

# Remove processed parameters and get the filename (last parameter)
shift $[ $OPTIND - 1 ]
if [ $# -eq 1 ]
	then
		filename=$1
		# "." was used as separater to sort the filenames in recurFile function
		# Filename with "." will break the function.
		if [ `echo $filename | grep '\.'` ]
		then
			echo 'ERROR: File name with "." is not supported.'
			readHelp
			exit 1
		fi
	# if no file name was given, show the usage info
	else	
		echo -e "Error: no filename specified!" 
		readHelp
		exit 1
fi

# if -s/--size option was specified, run checkSize function
if [ -n "$minSize" ]
then
	checkSize $filename $minSize
fi

# if -n option was specified, no backup will be made, notify user
if $noBackup
then
	echo "ATTENTION: No backup was made!"
	# if -z option was specified, compress current log files
	if [ -n "$count" ]
	then
		compLog $filename $count $noBackup
	else
		echo "ATTENTION: No compression was done as no -z option was specified!"
		readHelp
		exit 0
	fi
else
	$backupMethod $filename	
	if [ -n "$count" ]
	then
		compLog $filename $count $noBackup
	else
		echo "ATTENTION: No compression was done as no -z option was specified!"
	fi
fi
