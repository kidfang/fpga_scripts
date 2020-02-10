set_type=$1

###########################################################################

remove ()

{

list=$( bwconfig --list | awk '{print $2}' | wc -l )
list_n=$(($list-3))
j=0

for (( i=1; i<=$list_n; i=i+1 ));
        do
		remove_pra=$(($i-$j+3))
		remove_id=$( bwconfig --list | awk '{print $2}' | sed -n "$remove_pra"p )

		if [ $remove_id -ge 0 ] 2>/dev/null ; then
		xxx=pass
		else
		remove_id=$( bwconfig --list | awk '{print $3}' | sed -n "$remove_pra"p )
		fi

		bwconfig --remove=$remove_id
		j=$(($j+1))	
	done
	
echo -e "Remove all the device completed ! \n"

bwconfig --list

}

###########################################################################

add_device ()

{

if [ $1 = usb ]; then
	add_vender=2528
else
	add_vender=12ba
fi

add_n=$( bwconfig --scan=$1 | grep -i $add_vender |awk '{print $1}' | wc -l )

for (( i=1; i<=$add_n; i=i+1 ));
        do
		add_result=$( bwconfig --scan=$1 | grep -i $add_vender | awk '{print $1}' | sed -n "$i"p | cut -f 2 -d "[" | cut -f 1 -d "]" )
		bwconfig --add=$1 --result=$add_result >/dev/null 2>&1
	done

echo -e "\n----------------------------------------------------\n"

echo -e "Add Intel PAC $1 to BittWorks device completed\n"

bwconfig --list

echo -e "\nPlease check all the Intel PAC $1 you installed already in the above list"
#read -n 1 -p "Press Enter to next step or Press Ctrl + C to Stop! ..."

}

###########################################################################

stress_load ()

{

# Stress Load design

fpga_d=09c4
fpga_n=$( lspci | grep -i $fpga_d | wc -l )

for (( i=1; i<=$fpga_n; i=i+1 ));
        do
		cd /home/source
		bus_p=$( lspci | grep $fpga_d | sed -n "$i"p  | cut -f 1 -d " " )
		sudo fpgaflash user a10gx_pac_stress_load.rpd $bus_p
	done

echo -e "\n----------------------------------------------------\n"

echo -e "Set Stress Load design completed, Please do Power cycle, thx! \n"

}

SDRAM ()

{

fpga_d=0041
fpga_n=$( lspci | grep -i $fpga_d | wc -l )

for (( i=1; i<=$fpga_n; i=i+1 ));
        do
		fpga_p=$(lspci | grep -i $fpga_d | awk '{print $1}' | sed -n "$i"p)
		fpga_id=$(bwconfig --list | grep -i $fpga_p | awk '{print $3}')

	 	bwconfig --dev=$fpga_id --type=bar --index=2 --poke=0x2024 --newvalue=0x000000aa
		bwconfig --dev=$fpga_id --type=bar --index=2 --poke=0x2020 --newvalue=0x00000"$1"01
		bwconfig --dev=$fpga_id --type=bar --index=2 --poke=0x2020 --newvalue=0x00000"$1"00
		bwconfig --dev=$fpga_id --type=bar --index=2 --poke=0x2024 --newvalue=0x00aa00aa
		bwconfig --dev=$fpga_id --type=bar --index=2 --poke=0x2020 --newvalue=0x00000"$1"01
		bwconfig --dev=$fpga_id --type=bar --index=2 --poke=0x2020 --newvalue=0x00000"$1"00
	done
}

Restore_Mask ()

{

fpga_d=0041
fpga_n=$( lspci | grep -i $fpga_d | wc -l )

for (( i=1; i<=$fpga_n; i=i+1 ));
        do
		echo -e "\n Enter the Root port ID: "
		read root_f

		setpci -s $root_f ECAP_AER+0x08.L=0x$1 >/dev/null 2>&1
		setpci -s $root_f ECAP_AER+0x14.L=0x$1 >/dev/null 2>&1

		echo -e "\nPress Enter to set next Root port or type end to skip: "
                read Event

                if [ "$Event" = "end" ]; then
                	echo "Skip to set Root port!"
			break
                elif [ "$Event" = "" ]; then
                        echo "Set next Root port ...."
                        continue
                fi
		
	done

for (( j=1; j<=$fpga_n; j=j+1 ));
        do
		fpga_p=$(lspci | grep -i $fpga_d | awk '{print $1}' | sed -n "$j"p)

		setpci -s $fpga_p ECAP_AER+0x08.L=0x$1 >/dev/null 2>&1
		setpci -s $fpga_p ECAP_AER+0x14.L=0x$1 >/dev/null 2>&1
	done

}

Restore_image ()

{

source /home/a10gx/intelrtestack/init_env.sh
cd $OPAE_PLATFORM_ROOT/hw/blue_bits/
export QUARTUS_HOME=/home/a10gx/intelrtestack/intelFPGA_pro/qprogrammer

cable_n=$($QUARTUS_HOME/bin/quartus_pgm -l | grep -i A10SA4 | wc -l)

for (( i=1; i<=$cable_n; i=i+1 ));
        do
		cable_id=$($QUARTUS_HOME/bin/quartus_pgm -l | grep -i A10SA4 | cut -f 1 -d ")" | sed -n "$i"p)
		sudo $QUARTUS_HOME/bin/quartus_pgm -c $cable_id -m JTAG -o 'pvbi;dcp_1_1.jic'
	done
}

###########################################################################
###########################################################################
###########################################################################

case ${set_type} in
	"0")
		remove
		;;
        "1")		
		add_device usb		
		;;
	"2")
		stress_load
		;;
        "3")
                add_device pci
                ;;
	"4")
		SDRAM 1
		;;
	"5")
                SDRAM 0
                ;;
        "6")
                Restore_Mask FFFFFFFF
                ;;
	"7")
		Restore_image
		;;
	"8")
		Restore_Mask 00000000
		;;
	*)
		echo "
		(0), Remove all device at BittWorks device list
		(1), Add Intel PAC USB to BittWorks device list (for detect Device temperature)
		(2), Stress Load design
		(3), Add Intel PAC as a BittWorks PCIe device
		(4), SDRAM Test Enabled
		(5), SDRAM Test Disabled
		(6), Mask uncorrectable errors and correctable errors
		(7), Restore Acceleration Stack Image
		(8), Unmask uncorrectable errors and correctable errors
		"
		;;
esac
