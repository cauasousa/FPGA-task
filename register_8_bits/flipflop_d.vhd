library ieee;
use ieee.std_logic_1164.all;

entity flipflop_d is
    port (
        D     : in  std_logic;   -- Entrada de dados
        Clk   : in  std_logic;   -- Entrada de clock
        Q     : out std_logic;   -- Saída Q
        Q_n   : out std_logic    -- Saída Q' (complemento)
    );
end entity flipflop_d;

architecture behavioral of flipflop_d is
    signal Q_internal : std_logic := '0';
begin
    
    -- Processo para o flip-flop D
    process(Clk)
    begin
        if rising_edge(Clk) then
            Q <= D;
            Q_n <= not D;
        end if;
    end process;
    
end architecture behavioral;