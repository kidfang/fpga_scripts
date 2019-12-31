#!/bin/bash

## Test result save path ##

reboot_log=/root/fpga_reboot_default

## Test Device number
lsscsi_num=1  # Use lsscsi | wc -l to check
fpga_d_num=2  # fpga card number

## Enable ipmi module first ##

modprobe ipmi_si
modprobe ipmi_devintf

sleep 10

## value to identify the detected data ##

s=$( ipmitool sel list | grep -i interrupt )
t=$( ipmitool sel list | wc -l )
u=$( dmesg | grep -i corrected | wc -l )
v=$( ipmitool sel list | grep -i interrupt | wc -l )
w=$( lspci | grep -i 0b2b | wc -l ) 		     	    # Check fpga card number
x=$( lsscsi | wc -l )                			    # Need check yourself
y=$( cat $reboot_log/count.txt )			    # reboot count
z=$( ls $reboot_log | grep count.txt | wc -l )

## Detect the reboot count number ##

if [ $z -eq 0 ];then
	echo 0 > $reboot_log/count.txt
else
	echo "$y"
	y=$((y+1))
	echo $y > $reboot_log/count.txt
fi

## Detect the IPMI is fully logged and cleared ##

if [ $t -eq 1024 ];then
	ipmitool sel clear
else
	echo "continue"
fi

# the x can detect the SCSI device, which can be used for
# Virtual Media to disable the reboot process
# the w is reflecting the GPU detected amount, be warned with
# the consumer card with HDMI Audio device equipped.
# the u and v is reflecting the OS event & ipmi event for
# monitor the event listed the PCIe Error.
# command to Power Cycle is -> ipmitool chassis power cycle

if [ $x -eq $lsscsi_num ];then    			# Need check yourself
	if [ $w -eq $fpga_d_num ];then    		# Need check yourself
		if [ $v -eq 0 ] && [ $u -eq 0 ];then

			date | tee -a $reboot_log/rebootrec.txt
			echo PASS | tee -a $reboot_log/rebootrec.txt
	       		ipmitool chassis power cycle
		else
			echo $u | tee $reboot_log/OSevent.txt
			echo $s | tee $reboot_log/IPMIevent.txt
			dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" | tee $reboot_log/dmesg_error.txt
			dmesg | tee $reboot_log/dmesg_error_all.txt
			ipmitool sel list | tee $reboot_log/ipmi_eventlog.txt
			exit 0
		fi
	else
		echo $w | tee $reboot_log/FPGAcounterr.txt
		lspci | grep -i 0b2b | tee $reboot_log/FPGA_list.txt
		exit 0
	fi
else
	echo "Other error or stopped by user!!"
	dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" | tee $reboot_log/dmesg_reboot_done.txt
	dmesg | tee $reboot_log/dmesg_reboot_done_all.txt
	ipmitool sel list | tee $reboot_log/ipmi_reboot_done_eventlog.txt
	exit 0
fi
