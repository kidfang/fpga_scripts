#############################################################

result_p=/root

#############################################################

mkdir $result_p/fpga_diag >/dev/null 2>&1
mkdir $result_p/fpga_diag/Diag_AFU >/dev/null 2>&1
mkdir $result_p/fpga_diag/Diag_nlb_mode_3 >/dev/null 2>&1

fpga_s=$( lspci | grep -i 0b2b | wc -l )
fpga_a=$( lspci | grep -i 09c4 | wc -l )

if [ $fpga_s -gt 0 ]; then
        tool_p=/home/d5005
        fpga_d=0b2b
        fpga_n=$fpga_s
        fpga_parm=B
        w=$fpga_s
        afu=2
        afu_hpage=1048576
        afu_check=Bandwidth

elif [ $fpga_a -gt 0 ]; then
        tool_p=/home/a10gx
        fpga_d=09c4
        fpga_n=$fpga_a
        fpga_parm=b
        w=1
        afu=20
        afu_hpage=2048
        afu_check=bandwidth

else
        echo "No FPGA device, can not test!!"
        exit
fi

#############################################################

for (( i=1; i<=$fpga_n; i=i+1 ));
        do
                bus_n=$(lspci | grep $fpga_d | sed -n "$i"p)
                bus_p=$(lspci | grep $fpga_d | sed -n "$i"p | cut -f 1 -d ":")

                ### Diagnostics with nlb_mode_3 ###

                hu_nu=$((20*$w))
                source $tool_p/intelrtestack/init_env.sh >/dev/null 2>&1
                sudo sh -c "echo $hu_nu > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"

                sudo fpgabist -"$fpga_parm" "$bus_p" $OPAE_PLATFORM_ROOT/hw/samples/nlb_mode_3/bin/nlb_mode_3.gbs | tee $result_p/fpga_diag/Diag_nlb_mode_3/diag_"$bus_p"_dma_nlb_mode_3_log.txt

                ### Diagnostics with AFU ###

                source $tool_p/intelrtestack/init_env.sh >/dev/null 2>&1
                sudo sh -c "echo $afu > /sys/kernel/mm/hugepages/hugepages-"$afu_hpage"kB/nr_hugepages"

                sudo fpgabist -"$fpga_parm" "$bus_p" $OPAE_PLATFORM_ROOT/hw/samples/dma_afu/bin/dma_afu.gbs | tee $result_p/fpga_diag/Diag_AFU/diag_"$bus_p"_dma_fau_log.txt

                echo $bus_n | tee -a $result_p/fpga_diag/Diag_AFU/fpga_dma_fau_check.txt
                cat $result_p/fpga_diag/Diag_AFU/diag_"$bus_p"_dma_fau_log.txt | grep -i $afu_check | tee -a $result_p/fpga_diag/Diag_AFU/fpga_dma_fau_check.txt

       done
