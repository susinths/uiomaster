#! /usr/bin/env bash
#Bash script to run tests and record results of RDMA b/w measurements + system resource usage
IF="ens9"
IP_SRV="192.168.100.1"
OUTFILE="/root/scripts/ib_send_bw.txt"
RUNTIME="30" # in seconds                                                                                                                                                     
MTU="1200"  
NETSTAT='cat /proc/net/dev | awk "/${IF}:/ {print \$1,\$2,\$10}"'
SLEEP="40"
HOSTNAME="vmc8"
WINSIZE="default" # in KB
THREADS="1"
CPUAFF="0"
#When collecting data from experiments run in the VM, specify the I/O virt used: paravirt/virtio, SR-IOV or novirt (bare metal).
IOVIRT="SR-IOV"
TESTFILENAME="$(date +%F_%H-%M-%S)_vmc8toc7_${HOSTNAME}_roce_mtu${MTU}_${IOVIRT}.txt"

echo -e "StartTime,StartEpoch,BW,EndTime,EndEpoch,CPULoad1m,CPULoad5m,CPULoad5m,NetDevRX,NetDevTX,IRQ0,IRQ1,IRQ2,IRQ3,user,nice,system,idle,iowait,irq,softirq,steal,guest,guest_nice,MemTotal,MemFree,MemAvailable,Buffers,Cached" > $TESTFILENAME
while true
do 
StartTime=$(echo -n "$(date +%F_%H-%M-%S.%N)")
StartEpoch=$(echo -n "$(date +%s.%N)")
BW=$(echo -n "$(taskset -c ${CPUAFF} ib_send_bw  -D ${RUNTIME} -m 1024 -d mlx4_0 ${IP_SRV} -F --report_gbits  --output=bandwidth)")
#BW=$(echo -n $(iperf -c $IP_SRV -t 30  -y C | awk -F',' '{print $9}'))
#For P2/3/4, the output is different than for single thread!!! one line for each thread + a summary line
#BW=$(echo -n $(iperf -c $IP_SRV -t 30 -w ${WINSIZE} -P ${THREADS} -y C | tail -n1| awk -F',' '{print $9}'))
#BW=$(echo -n $(taskset -c ${CPUAFF} iperf -c $IP_SRV -t 30  -y C | awk -F',' '{print $9}'))
CPULoad=$(echo -n  $(awk '{print $1 "," $2 "," $3}' /proc/loadavg))
##We are done with running the command
EndTime=$(echo -n "$(date +%F_%H-%M-%S.%N)")
EndEpoch=$(echo -n "$(date +%s.%N)")
NetDevRX=$(echo -n $(cat /proc/net/dev | awk "/${IF}:/ {print \$2}"))
NetDevTX=$(echo -n $(cat /proc/net/dev | awk "/${IF}:/ {print \$10}"))     
#IRQconfig=$(echo  -n $(awk '/.*virtio4-config$/ {print $4}  ' /proc/interrupts)) 
#IRQinput=$(echo  -n $(awk '/.*virtio4-input.0$/ {print $5}  ' /proc/interrupts))
#IRQoutput=$(echo  -n $(awk '/.*virtio4-output.0$/ {print $3}  ' /proc/interrupts))
IRQconfig=$(echo  -n $(awk '/.*ens9d1-0$/ {print $2}  ' /proc/interrupts))                                                                                                                                       
IRQinput=$(echo  -n $(awk '/.*ens9d1-1$/ {print $3}  ' /proc/interrupts))                                                                                                                                        
IRQoutput=$(echo  -n $(awk '/.*ens9d1-2$/ {print $4}  ' /proc/interrupts))                                                                                                                                       
IRQ4=$(echo  -n $(awk '/.*ens9d1-3$/ {print $5}  ' /proc/interrupts))              

ProcStats=$(echo  -n $(awk '/^cpu .*/ {print $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 "," $9 "," $10 "," $11 }' /proc/stat))
MemTotal=$(echo  -n $(awk '/^MemTotal/ {print $2}'  /proc/meminfo))
MemFree=$(echo  -n $(awk '/^MemFree/ {print $2}'  /proc/meminfo))
MemAvailable=$(echo  -n $(awk '/^MemAvailable/ {print $2}'  /proc/meminfo))
Buffers=$(echo  -n $(awk '/^Buffers/ {print $2}'  /proc/meminfo))
Cached=$(echo  -n $(awk '/^Cached/ {print $2}'  /proc/meminfo))
echo -e "${StartTime},${StartEpoch},${BW},${EndTime},${EndEpoch},${CPULoad},${NetDevRX},${NetDevTX},${IRQconfig},${IRQinput},${IRQoutput},${IRQ4}${ProcStats},${MemTotal},${MemFree},${MemAvailable},${Buffers},${Cached}"  >> $TESTFILENAME
done





