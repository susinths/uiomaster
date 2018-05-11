#! /usr/bin/env bash
#Bash script to run tests and record resulsts + system resource usage
IF="ens9"
IP_SRV="192.168.100.1"
OUTFILE="/root/scripts/ib_send_bw.txt"
RUNTIME="90" # in seconds                                                                                                                                                     
MTU="9900"                       
#PERFCMD="perf stat -e  cpu-migrations,context-switches,task-clock,cycles,instructions,cache-references,cache-misses"
#RPERFCMD="rperf -c $IP_SERVER -p 5001 -H -G pw -l 500M -i 2 -t $RUNTIME"
NETSTAT='cat /proc/net/dev | awk "/${IF}:/ {print \$1,\$2,\$10}"'
SLEEP="40"
HOSTNAME="vmc8"
WINSIZE="default" # in KB
THREADS="1"
CPUAFF="3"
#When collecting data from experiments run in the VM, specify the I/O virt used: paravirt/virtio, SR-IOV or novirt (bare metal).                                                   
IOVIRT="SR-IOV"
TESTFILENAME="$(date +%F_%H-%M-%S)_vmc8toc7_${HOSTNAME}_iperf_mtu${MTU}_${IOVIRT}.txt"


#while true; do echo -n "$(rperf   -c 192.168.100.1 -p 5001 -H -G pw -l 500M -y C) " >> test1_bm_to_bm.txt && cat /proc/loadavg >> test1_bm_to_bm.txt; done
#echo -e "Timestamp\t CPULoad1m CPULoad5m CPULoad5m NetDevRX NetDevTX IRQens2-0 IRQens2-1 IRQens2-2 IRQens2-3 IRQens2-4 IRQens2-5 IRQens2-6 IRQens2-7 user nice system idle iowait irq softirq steal guest guest_nice   " > $TESTFILENAME 
echo -e "StartTime,StartEpoch,BW,EndTime,EndEpoch,CPULoad1m,CPULoad5m,CPULoad5m,NetDevRX,NetDevTX,IRQconfig,IRQinput,IRQoutput,user,nice,system,idle,iowait,irq,softirq,steal,guest,guest_nice,MemTotal,MemFree,MemAvailable,Buffers,Cached" > $TESTFILENAME
while true
do 
StartTime=$(echo -n "$(date +%F_%H-%M-%S.%N)")
StartEpoch=$(echo -n "$(date +%s.%N)")
#echo -n "$(ib_send_bw   -m 4096 -d mlx4_0 -i 1 -F --report_gbits  $IP_SRV --output=bandwidth)," >> $TESTFILENAME  
#BW=$(echo -n $(iperf -c $IP_SRV -t 30  -y C | awk -F',' '{print $9}'))
#For P2/3/4, the output is different than for single thread!!! one line for each thread + a summary line
#BW=$(echo -n $(iperf -c $IP_SRV -t 30 -w ${WINSIZE} -P ${THREADS} -y C | tail -n1| awk -F',' '{print $9}'))
BW=$(echo -n $(taskset -c ${CPUAFF} iperf -c $IP_SRV -t 30  -y C | awk -F',' '{print $9}'))
CPULoad=$(echo -n  $(awk '{print $1 "," $2 "," $3}' /proc/loadavg))
##We are done with running the command
EndTime=$(echo -n "$(date +%F_%H-%M-%S.%N)")
EndEpoch=$(echo -n "$(date +%s.%N)")
NetDevRX=$(echo -n $(cat /proc/net/dev | awk "/${IF}:/ {print \$2}"))
NetDevTX=$(echo -n $(cat /proc/net/dev | awk "/${IF}:/ {print \$10}"))     
IRQconfig=$(echo  -n $(awk '/.*virtio4-config$/ {print $4}  ' /proc/interrupts)) 
IRQinput=$(echo  -n $(awk '/.*virtio4-input.0$/ {print $5}  ' /proc/interrupts))
IRQoutput=$(echo  -n $(awk '/.*virtio4-output.0$/ {print $3}  ' /proc/interrupts))

ProcStats=$(echo  -n $(awk '/^cpu .*/ {print $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 "," $9 "," $10 "," $11 }' /proc/stat))
MemTotal=$(echo  -n $(awk '/^MemTotal/ {print $2}'  /proc/meminfo))
MemFree=$(echo  -n $(awk '/^MemFree/ {print $2}'  /proc/meminfo))
MemAvailable=$(echo  -n $(awk '/^MemAvailable/ {print $2}'  /proc/meminfo))
Buffers=$(echo  -n $(awk '/^Buffers/ {print $2}'  /proc/meminfo))
Cached=$(echo  -n $(awk '/^Cached/ {print $2}'  /proc/meminfo))
echo -e "${StartTime},${StartEpoch},${BW},${EndTime},${EndEpoch},${CPULoad},${NetDevRX},${NetDevTX},${IRQconfig},${IRQinput},${IRQoutput},${ProcStats},${MemTotal},${MemFree},${MemAvailable},${Buffers},${Cached}"  >> $TESTFILENAME
done


##TODO store the values in variables and then at the end write to the file
# Give 1s for the server to re-spawn
#sleep 1

#    sleep 30





#IRQs awk '/.*0$/ {print $2}  ' /proc/interrupts

#TODO add capture of cat /proc/net/dev | awk "/${IF}:/ {print \$1},${\$2},${\$10}"


#Start the "server" with 'while true; do ib_send_bw -D 90  -m 4096; done
