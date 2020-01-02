#############################################################

fpga_d=0b2b
result_p=/root

#############################################################

mkdir $result_p/fpga_diag >/dev/null 2>&1
mkdir $result_p/fpga_diag/Diag_AFU >/dev/null 2>&1
mkdir $result_p/fpga_diag/Diag_nlb_mode_3 >/dev/null 2>&1

w=$( lspci | grep -i $fpga_d | wc -l )

for (( i=1; i<=$w; i=i+1 ));
	do
		bus_n=$(lspci | grep $fpga_d | sed -n "$i"p)
                bus_p=$(lspci | grep $fpga_d | sed -n "$i"p | cut -f 1 -d ":")

		### Diagnostics with AFU ###

                source /home/d5005/intelrtestack/init_env.sh >/dev/null 2>&1
                sudo sh -c "echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"

                sudo fpgabist -B "$bus_p" $OPAE_PLATFORM_ROOT/hw/samples/dma_afu/bin/dma_afu.gbs | tee $result_p/fpga_diag/Diag_AFU/diag_"$bus_p"_dma_fau_log.txt
		
                echo $bus_n | tee -a /root/fpga_dma_fau_check.txt
                cat $result_p/Diag_AFU/diag_"$bus_p"_dma_fau_log.txt | grep -i Bandwidth | tee -a $result_p/fpga_diag/Diag_AFU/fpga_dma_fau_check.txt

		### Diagnostics with nlb_mode_3 ###

		hu_nu=$((20*$w))
		source /home/d5005/intelrtestack/init_env.sh >/dev/null 2>&1
		sudo sh -c "echo $hu_nu > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
		
		sudo fpgabist -B "$bus_p" $OPAE_PLATFORM_ROOT/hw/samples/nlb_mode_3/bin/nlb_mode_3.gbs | tee $result_p/fpga_diag/Diag_nlb_mode_3/diag_"$bus_p"_dma_nlb_mode_3_log.txt

       done


