@echo off
echo ========================================
echo Compilando light...
echo ========================================
ghdl -a light.vhd
ghdl -a tb_light.vhd
ghdl -e tb_light

echo ========================================
echo Executando simulação e gerando VCD...
echo ========================================
ghdl -r tb_light --vcd=light.vcd

echo ========================================
echo Abrindo no GTKWave...
echo ========================================
gtkwave light.vcd

del *.cf
pause