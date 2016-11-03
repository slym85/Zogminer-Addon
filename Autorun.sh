 #!/bin/bash
 ### You need script , screen and moreutils - run this :
 ###  sudo apt-get update && sudo apt-get install typescript moreutils screen

WALLET=$( echo "t1RVpR7U9ZA5SU94tXzEu7sLBtZrBkq4Vrf")  ### YOUR WALLET 
 ### Input your pool 
POOL=$(echo '"stratum+tcp://us1-zcash.flypool.org:3333"') ### YOUR POOL - please use the double   '"   and   "'   !!

GPU=6  ### How many GPU's you have 

 ### Maxtime is the maximum lag time allowed before restarting the miner .. 
 ### Be aware there is some lag from the time the miner executes hashes and the time the script writes it in the file.
 ### I have a good result with 300 sec
 
MAXTIME=300
DONNATE=1    ### To enable donations 
DONNWALLET=$(echo "t1MEUYR6yu9hYQ31ECWmijVwx9R6pAXQSTy")
 ### If you want to give some love back - Only GPU 0 will mine in this wallet - given your pool needs only a wallet as username
 ### This is where you want to donate : 
 
	### @omaralvarez
	### ZEC: t1MEUYR6yu9hYQ31ECWmijVwx9R6pAXQSTy

	### @nginnever
	### ZEC: t1PGgRgVQ14utsD7mp2dzGdykTDFUCKzPQ5

	### @AgeManning
	### ZEC: t1MfAaj8YDwiwFb6RAnNtW4EtzvTvkFGBvV

 ############## Script ###################

ZZ=$(echo '"')
RUNSLOOP=$GPU
until [  $RUNSLOOP = 0 ]; do
RUNSLOOP=$(expr $RUNSLOOP - 1 )

  if [ $DONNATE = 1 ] ; then 
	if [ $RUNSLOOP = 0 ] ; then WALLET=$DONNWALLET ; fi ; fi
 ### 1rst instance 
echo " #!/bin/bash
 WALLET=$WALLET 
export GPU_SINGLE_ALLOC_PERCENT=100 
export GPU_MAX_ALLOC_PERCENT=99 
export GPU_MAX_HEAP_SIZE=100 
export GPU_USE_SYNC_OBJECTS=1 " > Ist$RUNSLOOP.T1.sh
echo 'echo $$ > '"$RUNSLOOP.T1PID" >> Ist$RUNSLOOP.T1.sh
echo " script Ist$RUNSLOOP.T1 -c $ZZ./src/zcash-miner -G -stratum=$POOL  -user=$WALLET.Rig -S=$RUNSLOOP | ts $ZZ
  " >> Ist$RUNSLOOP.T1.sh
chmod +x Ist$RUNSLOOP.T1.sh
screen -dmS Zcash$RUNSLOOP.T1 ./Ist$RUNSLOOP.T1.sh
 sleep 0.5

 
 ### 2nd instance 
 if [ $DONNATE = 1 ] ; then 
	if [ $RUNSLOOP = 0 ] ; then WALLET=$DONNWALLET ; fi ; fi
 echo " #!/bin/bash
 WALLET=$WALLET 
export GPU_SINGLE_ALLOC_PERCENT=100 
export GPU_MAX_ALLOC_PERCENT=99 
export GPU_MAX_HEAP_SIZE=100 
export GPU_USE_SYNC_OBJECTS=1 " > Ist$RUNSLOOP.T2.sh
echo 'echo $$ > '"$RUNSLOOP.T2PID" >> Ist$RUNSLOOP.T2.sh
echo "script Ist$RUNSLOOP.T2 -c $ZZ./src/zcash-miner -G -stratum=$POOL  -user=$WALLET.Rig -S=$RUNSLOOP | ts $ZZ
 " >> Ist$RUNSLOOP.T2.sh
chmod +x Ist$RUNSLOOP.T2.sh
screen -dmS Zcash$RUNSLOOP.T2 ./Ist$RUNSLOOP.T2.sh
 sleep 0.5

done ### we have built 2 instances per GPU .. moving on ...

echo " Threads have been built ... waiting 60 sec to start monitoring" 
sleep 55
echo " Starting monitoring " 
sleep 5

while :
do
 ### Entering the script loop
 echo " "
RUNSLOOP=$GPU
      until [  $RUNSLOOP = 0 ]; do ### Numbering loop 
      RUNSLOOP=$(expr $RUNSLOOP - 1 )

#####################################################################################################################
 ### For instace one  

	NAME=$(echo "Ist$RUNSLOOP.T1")
	### This is the time of hash vs current date calculator 
	### Need variables 
	date_a=$(date +"%H:%M:%S") ### This is current time 
	CAL=$(cat $NAME | tail --lines=4 | grep 'Kernel' |  awk '{print $3}' | tail --lines=1)
        ### Prototype : Need to see the diff from the timestamp and the date 
	old=$CAL
	new=$(date +"%H:%M:%S")
	#echo " $new - the time "  ### DEBUGG
	#echo " $old - the timestamp " ### DEBUGG
	### feeding variables by using read and splitting with IFS
	IFS=: read old_hour old_min old_sec <<< "$old"
	IFS=: read hour min sec <<< "$new"
	### convert hours to minutes and seconds
	### the 10# is there to avoid errors with leading zeros
	### by telling bash that we use base 10
	total_old_minutes=$((10#$old_hour*60 + 10#$old_min*60 + 10#$old_sec))
	total_minutes=$((10#$hour*60 + 10#$min*60 + 10#$sec))
	sleep 1
	  DIFF=$(echo "$((total_minutes - total_old_minutes))")
	  if [ $DIFF -gt $MAXTIME ] ### How many seconds to wait before restarting thread
	      then 
		SICK=1
		 echo " ============================= "
		echo " GPU $RUNSLOOP :" 
		echo " there is a $DIFF sec lag on hash check - GPU is sick ! " ###  Here we have declared the GPU sick 
	
		### ACTION HERE - We have a lag on the miner thread
		 LINES=$(cat $NAME | wc -l)
		
		 if [ $LINES -gt 150 ] ; then  
			PID=$(cat $RUNSLOOP.T1PID)
			kill $PID
			screen -dmS Zcash$RUNSLOOP.T1 ./Ist$RUNSLOOP.T1.sh
			echo " Retarted Ist$RUNSLOOP.T1.sh | Reason : Lag found "
			sleep 2
			else 
			echo " Not restarting GPU $RUNSLOOP T1 | Reason - Not enough data yet"
			fi
	      else 
	      echo " ============================= "
		echo " GPU $RUNSLOOP is OK :" 
		echo " Thread 01  the difference is $((total_minutes - total_old_minutes)) sec " ### Normal condition : Hashes are running
	  fi
	### Sleep and time here 
	sleep 0.5
############################################################################################################################

 ### For instance 2 check 
	NAME=$(echo "Ist$RUNSLOOP.T2")
	### This is the time of hash vs current date calculator 
	### Need variables 
	date_a=$(date +"%H:%M:%S") ### This is current time 
	CAL=$(cat $NAME | tail --lines=4 | grep 'Kernel' |  awk '{print $3}' | tail --lines=1)
        ### Prototype : Need to see the diff from the timestamp and the date 
	old=$CAL
	new=$(date +"%H:%M:%S")
	#echo " $new - the time "  ### DEBUGG
	#echo " $old - the timestamp " ### DEBUGG
	### feeding variables by using read and splitting with IFS
	IFS=: read old_hour old_min old_sec <<< "$old"
	IFS=: read hour min sec <<< "$new"
	### convert hours to minutes and seconds
	### the 10# is there to avoid errors with leading zeros
	### by telling bash that we use base 10
	total_old_minutes=$((10#$old_hour*60 + 10#$old_min*60 + 10#$old_sec))
	total_minutes=$((10#$hour*60 + 10#$min*60 + 10#$sec))
	sleep 1
	DIFF=$(echo "$((total_minutes - total_old_minutes))")
	if [ $DIFF -gt $MAXTIME ] ### How many seconds to wait before restarting thread
	      then 
		SICK=1
		echo " there is a $DIFF sec lag on hash check - GPU is sick ! " ###  Here we have declared the GPU sick 
	
		 ### ACTION HERE - We have a lag on the miner thread
		 LINES=$(cat $NAME | wc -l)
		
		 if [ $LINES -gt 150 ] ; then  
			PID=$(cat $RUNSLOOP.T2PID)
			kill $PID
			screen -dmS Zcash$RUNSLOOP.T2 ./Ist$RUNSLOOP.T2.sh
			echo " Retarted Ist$RUNSLOOP.T2.sh | Reason : Lag found "
			sleep 2
			else 
			echo " Not restarting GPU $RUNSLOOP T2 | Reason - Not enough data yet"
			fi
	      else 
		echo " Thread 02 the difference is $((total_minutes - total_old_minutes)) sec" ### Normal condition : Hashes are running
	fi
	sleep 0.1

    done ### Done
done ### The script loop

