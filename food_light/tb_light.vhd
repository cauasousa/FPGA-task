library ieee;
use ieee.std_logic_1164.all;

entity tb_light is
end entity;

architecture sim of tb_light is
  -- Sinais para testar a função booleana S = BCD + AC + AB
  signal Clk : std_logic := '0';
  signal A   : std_logic := '0';
  signal B   : std_logic := '0';
  signal C   : std_logic := '0';
  signal D   : std_logic := '0';
  signal S   : std_logic;

  component light
    port (
      Clk : in  std_logic;
      A   : in  std_logic;
      B   : in  std_logic;
      C   : in  std_logic;
      D   : in  std_logic;
      S   : out std_logic
    );
  end component;

begin

  -- Instância do componente para testar a função S = BCD + AC + AB
  uut: light port map(
    Clk => Clk,
    A   => A,
    B   => B,
    C   => C,
    D   => D,
    S   => S
  );

  -- Geração de clock: 10 ns de período
  clk_process: process
  begin
    while now < 320 ns loop
      Clk <= not Clk;
      wait for 20 ns;
    end loop;
    wait;
  end process;

  -- Processo de teste para todas as combinações de A, B, C e D
  stim_proc: process
  begin
    
    -- A=0, B=0, C=0, D=0 -> S deve ser 0
    A <= '0'; B <= '0'; C <= '0'; D <= '0';
    wait for 20 ns;
    
    -- A=0, B=0, C=0, D=1 -> S deve ser 0
    A <= '0'; B <= '0'; C <= '0'; D <= '1';
    wait for 20 ns;
    
    -- A=0, B=0, C=1, D=0 -> S deve ser 0
    A <= '0'; B <= '0'; C <= '1'; D <= '0';
    wait for 20 ns;
    
    -- A=0, B=0, C=1, D=1 -> S deve ser 0
    A <= '0'; B <= '0'; C <= '1'; D <= '1';
    wait for 20 ns;
    
    -- A=0, B=1, C=0, D=0 -> S deve ser 0
    A <= '0'; B <= '1'; C <= '0'; D <= '0';
    wait for 20 ns;

    -- A=0, B=1, C=0, D=1 -> S deve ser 0
    A <= '0'; B <= '1'; C <= '0'; D <= '1';
    wait for 20 ns;
    
    -- A=0, B=1, C=1, D=0 -> S deve ser 0
    A <= '0'; B <= '1'; C <= '1'; D <= '0';
    wait for 20 ns;
    
    -- A=0, B=1, C=1, D=1 -> S deve ser 1
    A <= '0'; B <= '1'; C <= '1'; D <= '1';
    wait for 20 ns;
    
    -- A=1, B=0, C=0, D=0 -> S deve ser 0
    A <= '1'; B <= '0'; C <= '0'; D <= '0';
    wait for 20 ns;
    
    -- A=0, B=0, C=0, D=1 -> S deve ser 0
    A <= '1'; B <= '0'; C <= '0'; D <= '1';
    wait for 20 ns;
    
    -- A=1, B=0, C=1, D=0 -> S deve ser 1
    A <= '1'; B <= '0'; C <= '1'; D <= '0';
    wait for 20 ns;
    
    -- A=1, B=0, C=1, D=1 -> S deve ser 1
    A <= '1'; B <= '0'; C <= '1'; D <= '1';
    wait for 20 ns;
    
    -- A=1, B=1, C=0, D=0 -> S deve ser 1
    A <= '1'; B <= '1'; C <= '0'; D <= '0';
    wait for 20 ns;
    
    -- A=1, B=1, C=0, D=1 -> S deve ser 1
    A <= '1'; B <= '1'; C <= '0'; D <= '1';
    wait for 20 ns;
    
    -- A=1, B=1, C=1, D=0 -> S deve ser 1
    A <= '1'; B <= '1'; C <= '1'; D <= '0';
    wait for 20 ns;
    
    -- A=1, B=1, C=1, D=1 -> S deve ser 1
    A <= '1'; B <= '1'; C <= '1'; D <= '1';
    wait for 20 ns;
    
    

    wait;
  end process;

end architecture;
