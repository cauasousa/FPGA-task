library ieee;
use ieee.std_logic_1164.all;

entity register_8bit is
    port (
        D     : in  std_logic_vector(7 downto 0);  -- Dados de entrada paralelos (8 bits)
        Clk   : in  std_logic;                     -- Clock comum para todos os flip-flops
        Q     : out std_logic_vector(7 downto 0);  -- Saídas Q (8 bits)
        Q_n   : out std_logic_vector(7 downto 0)   -- Saídas Q' (8 bits)
    );
end entity register_8bit;

architecture structural of register_8bit is
    
    -- Declaração do componente flip-flop D
    component flipflop_d
        port (
            D     : in  std_logic;
            Clk   : in  std_logic;
            Q     : out std_logic;
            Q_n   : out std_logic
        );
    end component;
    
begin
    
    -- Instanciação de 8 flip-flops D
    -- Cada bit do registrador é implementado com um flip-flop D
    
    FF0: flipflop_d port map (
        D   => D(0),
        Clk => Clk,
        Q   => Q(0),
        Q_n => Q_n(0)
    );
    
    FF1: flipflop_d port map (
        D   => D(1),
        Clk => Clk,
        Q   => Q(1),
        Q_n => Q_n(1)
    );
    
    FF2: flipflop_d port map (
        D   => D(2),
        Clk => Clk,
        Q   => Q(2),
        Q_n => Q_n(2)
    );
    
    FF3: flipflop_d port map (
        D   => D(3),
        Clk => Clk,
        Q   => Q(3),
        Q_n => Q_n(3)
    );
    
    FF4: flipflop_d port map (
        D   => D(4),
        Clk => Clk,
        Q   => Q(4),
        Q_n => Q_n(4)
    );
    
    FF5: flipflop_d port map (
        D   => D(5),
        Clk => Clk,
        Q   => Q(5),
        Q_n => Q_n(5)
    );
    
    FF6: flipflop_d port map (
        D   => D(6),
        Clk => Clk,
        Q   => Q(6),
        Q_n => Q_n(6)
    );
    
    FF7: flipflop_d port map (
        D   => D(7),
        Clk => Clk,
        Q   => Q(7),
        Q_n => Q_n(7)
    );
    
end architecture structural;