###############################

fpga_dev=0b2b

###############################

fpga_01_check=$( lspci | grep -i $fpga_dev | grep -i "rev 01" | wc -l )

if [ $fpga_01_check -eq 0 ];then

	echo -e "\nCPL has been programmed in FPGA and CPL initialization is not required; skip to Adjusting Board Power"
	echo -e "Can start to test Stress Load, thx!\n"
	
else

	### Stress Load Setting ###
	
	echo -e "\nSetting ... Please wait .... \n"

	cd /home/source/thermal/QuartusProProgrammer/
	./QuartusProProgrammerSetup-18.1.2.277-linux.run --mode unattended --installdir . --accept_eula 1
	export PATH=`pwd`/qprogrammer/bin/:$PATH >/dev/null 2>&1

	jtagconfig --debug

	echo -e "Verify the number of PACs connected to the JTAG Server," 
	read -n 1 -p "if fpga card can be detect normally and the amount as expected, Press Enter to next step or Press Ctrl + C to Stop! ..."
	echo -e "\n"

	### Adjusting Power ###
	
	#fpga_01_num=$( lspci | grep -i $fpga_dev | grep -i "rev 01" | wc -l )
	usb_detect=$( jtagconfig --debug | grep -i Stratix10 | wc -l )

	for (( i=1; i<=$usb_detect; i=i+1 ));
        	do
			jtagconfig --setparam $i JtagClock 6m
		done

	jtagconfig --debug

	read -n 1 -p "Check speed change sucess => JTAG speed to 6 MHz, Press Enter to next step or Press Ctrl + C to Stop! ..."
	echo -e "\n"

	cd /home/source/thermal/scripts
	python AER_disable.py 0b2b
	cd /home/source/thermal/cpl_pac_design

        for (( j=1; j<=$usb_detect; j=j+1 ));
                do
			quartus_pgm -c $j -m JTAG -o "p;./cpl_sa_dc_0b2b_X16_400MHz_M2200_D1100_F100_190327_1604.sof"
		done

	echo -e "\nStress Load Setting completed, please reboot system, thx!\n"
fi
