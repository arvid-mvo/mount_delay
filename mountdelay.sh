#!/bin/bash


#sudo mount -t cifs -o username=seisan,password=mont-serrat //172.20.0.53/DVG_Data/WEBOBS_DATA mvohvs3

# Date and time when the script is executed
DATE=$(date +%Y-%m-%d_%H-%M-%S)

echo -e "Beginning mount delay script @ $DATE\n"

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

echo "Number of tries: $TRIES"
echo "Delay between each try: $DELAY"
echo "Test URL: $TEST_URL"
echo -e "\n"

# Test url for network connection using curl.
# If no connection after TRIES, NETWORK=0
# If connection after TRIES, NETWORK=1 --> we can proceed to mounting network drives
until [ $COUNTER -eq $TRIES ]
do	
	# Update counter
	let COUNTER=COUNTER+1
	
	echo -e "Testing network connection on $TEST_URL ........"
	# Get url response
	URL_RESP=$(curl -vs -o /dev/null $TEST_URL 2>&1 | grep -c connection)
	echo "URL Response: $URL_RESP"
	# If resp is 0, url can be reached therefore network is up
	if [ $URL_RESP -eq 0 ] 
	then
		NETWORK=1
		COUNTER=$TRIES
		echo "Network connected !"
	else	
		sleep $DELAY
	fi

done

echo -e "\n"

# Try mounting network drives here

if [ $NETWORK -eq 1 ]
then
	echo -e "Network connected. Trying to mount network drives.\n"
	
	# mvofls2 (172.17.102.66)/Seismic_Data --> /mnt/mvofls2/Seismic_Data 
	echo "Mounting /mvofls2/Seismic_Data to /mnt/mvofls2/Seismic_Data"
	RET=$(mount -t cifs -o auto,username=seisan,password=mont-serrat,uid=1000,gid=100,domain=MVO,vers=2.1,noperm //172.17.102.66/Seismic_Data /mnt/mvofls2/Seismic_Data)
	echo "$RET"
	
	echo -e "\n"
	
	# earthworm03 (172.17.102.62)/monitoring_data --> /mnt/earthworm3/monitoring_data 
	echo "Mounting /earthworm03/monitoring_data to /mnt/earthworm3/monitoring_data"
	RET=$(mount -t cifs -o defaults,username=seisan,password=mont-serrat,uid=1003,gid=10003,domain=MVO,vers=2.0 //172.17.102.62/monitoring_data /mnt/earthworm3/monitoring_data)
	echo "$RET"
	
	echo "Finished mounting network drives. Exiting script..........."
else
	echo "Exiting script.... Many failed tries!"
	exit
fi


