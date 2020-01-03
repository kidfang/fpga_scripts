##############################################

fpga_stress_percent=20
fpga_d=0b2b
fpga_tool_path=/root/fpga_scripts    # Be sure this path have fpga_single_stress.sh

##############################################

fpga_n=$( lspci | grep -i $fpga_d | wc -l )

for (( i=1; i<=$fpga_n; i=i+1 ));

	do
		fpga_bp=$(lspci | grep $fpga_d | sed -n "$i"p | cut -f 1 -d " ")
		gnome-terminal -t "$fpga_bp" -- $fpga_tool_path/fpga_single_stress.sh $fpga_bp $fpga_stress_percent
	done
