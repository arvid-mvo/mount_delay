#!/bin/bash



#sudo mount -t cifs -o username=seisan,password=mont-serrat //172.20.0.53/DVG_Data/WEBOBS_DATA mvohvs3

# Date and time when the script is executed
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Ceate a logfile. For debugging and error checking

# Create log directory in /var/log
# Log directory name is name of script being executed: mountdelay
LOG=mountdelay # --> mountdelay
LOGDIR=/var/log/$LOG
# Lets create the LOG directory if it does not exist
if [ ! -d $LOGDIR ]
then
	mkdir $LOGDIR
fi

# LOGFILE format: date_mountdelay.log
LOGFILE=${DATE}_${LOG}.log

# LOGGING complete path to our logfile
LOGGING=${LOGDIR}/${LOGFILE}

echo "Beginning mount delay script @ $DATE" >> $LOGGING
echo " " >> $LOGGING
echo " " >> $LOGGING

# If network is reachable: NETWORK = 1
# If network is unreachable: NETWORK = 0
NETWORK=0

# COUNTER keeps track of how many times we check for valid network connection
COUNTER=0

# How many times to test network connection
TRIES=100

# Delay in seconds between each network test
DELAY=2 # seconds

# url to test network connection
TEST_URL=http://www.google.com

# Test url for network connection using curl.
# If no connection after TRIES, NETWORK=0
# If connection after n TRIES, NETWORK=1 --> we can proceed to mounting network drives
until [ $COUNTER -eq $TRIES ]
do	
	# Update counter
	let COUNTER=COUNTER+1
	
	echo "`date`: Testing network connection on $TEST_URL ........" >> $LOGGING
	# Get url response
	URL_RESP=$(curl -vs -o /dev/null $TEST_URL 2>&1 | grep -c connection)
	
	# If resp is 0, url can be reached therefore network is up
	if [ $URL_RESP -eq 0 ] 
	then
		NETWORK=1
		COUNTER=$TRIES
		echo " " >> $LOGGING
		echo "`date`: Network connected !" >> $LOGGING
	else	
		sleep $DELAY
	fi

done

# Try mounting network drives here
echo " " >> $LOGGING
echo -e "`date`: Mounting network drives......\n" >> $LOGGING

if [ $NETWORK -eq 1 ]
then
	echo "Mounting RainfallpH from mvofls3/WEBOBS_DATA/Rainfallph to /mnt/RainfallpH" >> $LOGGING
	RET=$(mount -t cifs -o username=seisan,password=mont-serrat //172.20.0.53/DVG_Data/WEBOBS_DATA/RainfallpH /mnt/RainfallpH)
	echo $RET >> $LOGGING
else
	echo "`date`: Exiting.. Many failed tries!"
	exit
fi
