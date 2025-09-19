library ieee;
use ieee.std_logic_1164.all;

entity light is
    port (
        Clk     : in  std_logic;
        A       : in  std_logic;                     
        B       : in  std_logic;                     
        C       : in  std_logic;
        D       : in  std_logic;
        -- Saída da função booleana S = BCD + AC + AB
        S       : out std_logic
    );
end entity;

architecture behavioral of light is
begin

    process(Clk)
    begin
        if rising_edge(Clk) then
            S <= (B and C and D) or (A and C) or (A and B);
        end if;
    end process;
   

end behavioral;

