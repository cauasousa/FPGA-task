@echo off
echo ========================================
echo Simulacao do Registrador Paralelo 8 bits
echo ========================================
echo.

REM Compilar os arquivos VHDL
echo Compilando ...
ghdl -a flipflop_d.vhd
ghdl -a register_8bit.vhd
ghdl -a tb_register_8bit.vhd
ghdl -e tb_register_8bit

echo.
echo Executando simulacao...
ghdl -r tb_register_8bit --vcd=register_8bit_simulation.vcd


echo ========================================
echo Abrindo no GTKWave...
echo ========================================
gtkwave register_8bit_simulation.vcd


del *.cf
pause