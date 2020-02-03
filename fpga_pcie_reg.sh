#!/bin/bash

##########################################

result_path=/root
mkdir $result_path/fpga_pcie_reg

test_item=6
test1_times=100
test2_times=100
test3_times=100
test4_times=100
test5_times=100

### Be sure as follows path is correct ###

#Test Intel FPGA Stratix : /home/source/thermal_pcie_Test_4_29_2019/pcie_regression_test_scripts_v1p0
#Test intel FPGA Arria   : /home/source/pcie_regression_test_scripts_v1p0

##########################################

fpga_s=$( lspci | grep -i 0b2b | wc -l )
fpga_a=$( lspci | grep -i 09c4 | wc -l )


if [ $fpga_s -gt 0 ]; then
        cd /home/source/thermal_pcie_Test_4_29_2019/pcie_regression_test_scripts_v1p0
        fpga_d=0b2b
        fpga_n=$fpga_s

elif [ $fpga_a -gt 0 ]; then
        cd /home/source/pcie_regression_test_scripts_v1p0
        fpga_d=09c4
        fpga_n=$fpga_a

else
        echo "No FPGA device, can not test!!"
        exit
fi

##########################################

for (( i=1; i<=$fpga_n; i=i+1 ));

do

fpga_bp=$(lspci | grep $fpga_d | sed -n "$i"p | cut -f 1 -d " ")
fpga_fn=$(lspci | grep $fpga_d | sed -n "$i"p | cut -f 1 -d ":")

sudo -E python -u pcie_regression_test_scripts_v1p0.py << EOF | tee $result_path/fpga_pcie_reg/pcie_"$fpga_fn"_test_log.txt
$fpga_bp
$test_item
$test1_times
$test2_times
$test3_times
$test4_times
$test5_times
99
EOF

done
