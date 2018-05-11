#! /usr/bin/env bash                                                                                                                                          
#Bash script to run tests and record resulsts + system resource usage                                                                                        
IF="ens2"
IP_SRV="192.168.100.1"
OUTFILE="/root/scripts/ib_send_bw.txt"
RUNTIME="90" # in seconds                                                                                                                                    \
                                                                                                                                                              
#PERFCMD="perf stat -e  cpu-migrations,context-switches,task-clock,cycles,instructions,cache-references,cache-misses"                                         
#RPERFCMD="rperf -c $IP_SERVER -p 5001 -H -G pw -l 500M -i 2 -t $RUNTIME"                                                                                     
NETSTAT='cat /proc/net/dev | awk "/${IF}:/ {print \$1,\$2,\$10}"'
SLEEP="40"
HOSTNAME="compute7"
TESTFILENAME="test_$(date +%F_%H-%M-%S)_compute8tocompute7_$HOSTNAME.txt"

#while true; do echo -n "$(rperf   -c 192.168.100.1 -p 5001 -H -G pw -l 500M -y C) " >> test1_bm_to_bm.txt && cat /proc/loadavg >> test1_bm_to_bm.txt; done   
while true
#do ib_send_bw -D 90 -m 4096
do ib_send_bw  -m 4096
done
