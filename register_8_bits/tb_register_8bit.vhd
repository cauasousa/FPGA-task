library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_register_8bit is
end entity tb_register_8bit;

architecture sim of tb_register_8bit is
    
    -- Sinais para conectar ao registrador
    signal clk  : std_logic := '0';
    signal D    : std_logic_vector(7 downto 0) := (others => '0');
    signal Q    : std_logic_vector(7 downto 0);
    signal Q_n  : std_logic_vector(7 downto 0);
    
    -- Declaração do componente registrador
    component register_8bit
        port (
            D     : in  std_logic_vector(7 downto 0);
            Clk   : in  std_logic;
            Q     : out std_logic_vector(7 downto 0);
            Q_n   : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- Constante para período do clock
    constant clk_period : time := 20 ns;
    
begin
    
    -- Instanciação do registrador sob teste
    uut: register_8bit port map (
        D   => D,
        Clk => clk,
        Q   => Q,
        Q_n => Q_n
    );
    
    -- Processo para geração do clock
    clk_process: process
    begin
        while now < 220 ns loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    -- Processo de estimulos para testar o registrador
    stimulus_process: process
    begin
        -- Aguardar um pouco antes de iniciar os testes
        -- wait for 10 ns;
        
        -- Teste 1: Carregar valor 00000000
        D <= "00000000";
        wait for clk_period;

        D <= "00000001";  -- 1
        wait for clk_period;
        
        D <= "00000010";  -- 2
        wait for clk_period;
        
        D <= "00000100";  -- 4
        wait for clk_period;
        
        D <= "00001000";  -- 8
        wait for clk_period;
        
        D <= "00010000";  -- 16
        wait for clk_period;
        
        D <= "00100000";  -- 32
        wait for clk_period;
        
        D <= "01000000";  -- 64
        wait for clk_period;
        
        D <= "10000000";  -- 128
        wait for clk_period;
        
        wait;
        
    end process;
   
    
end architecture sim;