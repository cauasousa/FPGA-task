@echo off
ghdl -a state_machine.vhd
ghdl -a tb_state_machine.vhd
ghdl -e tb_state_machine
ghdl -r tb_state_machine --vcd=state_machine.vcd
gtkwave state_machine.vcd

pause
del *.cf
