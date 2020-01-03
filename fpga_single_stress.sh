#!/usr/bin/expect -f

set fpga_pci	 [lindex $argv 0 ]
set fpga_sram_percent [lindex $argv 1 ]
set fpga_dsp_percent [lindex $argv 2 ]
set fpga_fabric_percent [lindex $argv 3 ]

cd /home/source/thermal/Drop_190218

spawn ./run_cpl.sh

expect "please enter the B:D.F -->"
send "$fpga_pci\r"

expect "Please type index of control  to tweak:"
send "4\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "5\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "6\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "7\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "8\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "9\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "10\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "11\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "12\r"
expect "Please enter \\\"0: off\\\" or \\\"1: on\\\":"
send "1\r"

expect "Please type index of control  to tweak:"
send "1\r"
expect "Please enter percentage of sram to be activated (eg, enter 20 for 20%):"
send "$fpga_sram_percent\r"

expect "Please type index of control  to tweak:"
send "2\r"
expect "Please enter percentage of dsp to be activated (eg, enter 20 for 20%):"
send "$fpga_dsp_percent\r"

expect "Please type index of control  to tweak:"
send "3\r"
expect "Please enter percentage of fabric to be activated (eg, enter 20 for 20%):"
send "$fpga_fabric_percent\r"

expect "Please type index of control  to tweak:"
send "99\r"
expect "please enter the delaytime (Range available: 1 to n sec) -->"
send "1\r"

interact
