#############################################################

fpga_d=0b2b
#fpga_d=09c4
result_p=/root

#############################################################

mkdir $result_p/fpga_diag >/dev/null 2>&1
mkdir $result_p/fpga_diag/Diag_AFU >/dev/null 2>&1
mkdir $result_p/fpga_diag/Diag_nlb_mode_3 >/dev/null 2>&1

tool_p=/home/d5005
#tool_p=/home/a10gx

w=$( lspci | grep -i $fpga_d | wc -l )
#w=1

for (( i=1; i<=$w; i=i+1 ));
	do
		bus_n=$(lspci | grep $fpga_d | sed -n "$i"p)
                bus_p=$(lspci | grep $fpga_d | sed -n "$i"p | cut -f 1 -d ":")

		### Diagnostics with nlb_mode_3 ###

		hu_nu=$((20*$w))
		source $tool_p/intelrtestack/init_env.sh >/dev/null 2>&1
		sudo sh -c "echo $hu_nu > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
		
		sudo fpgabist -B "$bus_p" $OPAE_PLATFORM_ROOT/hw/samples/nlb_mode_3/bin/nlb_mode_3.gbs | tee $result_p/fpga_diag/Diag_nlb_mode_3/diag_"$bus_p"_dma_nlb_mode_3_log.txt

		### Diagnostics with AFU ###

                source $tool_p/intelrtestack/init_env.sh >/dev/null 2>&1
		
		########################## Block below command when test arria fpga card #################
                sudo sh -c "echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"
		##########################################################################################
		
                sudo fpgabist -B "$bus_p" $OPAE_PLATFORM_ROOT/hw/samples/dma_afu/bin/dma_afu.gbs | tee $result_p/fpga_diag/Diag_AFU/diag_"$bus_p"_dma_fau_log.txt
		
                echo $bus_n | tee -a $result_p/fpga_diag/Diag_AFU/fpga_dma_fau_check.txt
                cat $result_p/Diag_AFU/diag_"$bus_p"_dma_fau_log.txt | grep -i Bandwidth | tee -a $result_p/fpga_diag/Diag_AFU/fpga_dma_fau_check.txt

       done
