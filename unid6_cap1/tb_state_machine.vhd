library ieee;
use ieee.std_logic_1164.all;

entity tb_state_machine is
end;

architecture sim of tb_state_machine is
   -- sinais de estímulo
  signal clk              : std_logic := '0';
  signal rst_n            : std_logic := '0';
  signal sensor           : std_logic := '0';
  signal fechar_manual    : std_logic := '0';
  signal fim_curso_aberta : std_logic := '0';
  signal fim_curso_fechada: std_logic := '1';

  -- saídas do DUT
  signal motor_abrir      : std_logic;
  signal motor_fechar     : std_logic;

begin
  DUT: entity work.state_machine
    port map (
      clk              => clk,
      rst_n            => rst_n,
      sensor           => sensor,
      fechar_manual    => fechar_manual,
      fim_curso_aberta => fim_curso_aberta,
      fim_curso_fechada=> fim_curso_fechada,
      motor_abrir      => motor_abrir,
      motor_fechar     => motor_fechar
    );


  clk <= not clk after 10 ns;

  stim_proc: process
  begin
    -- Reset inicial
    rst_n <= '0';
    wait for 30 ns;
    rst_n <= '1';
    wait for 30 ns;

    -- Pessoa detectada => porta começa a abrir
    sensor <= '1';
    wait for 30 ns;
    
    -- Simula porta saindo da posição fechada
    fim_curso_fechada <= '0';
    wait for 30 ns;

    -- Porta chegou no fim de curso aberta
    fim_curso_aberta <= '1';
    wait for 30 ns;

    -- Pessoa sai => porta fecha
    sensor <= '0';
    wait for 30 ns;
    
    -- Simula porta saindo da posição aberta
    fim_curso_aberta <= '0';
    wait for 30 ns;
    
    -- Porta voltou ao fim de curso fechada
    fim_curso_fechada <= '1';
    wait for 30 ns;

    -- Novo ciclo: presença novamente
    sensor <= '1';
    wait for 30 ns;
    fim_curso_fechada <= '0';
    wait for 30 ns;
    fim_curso_aberta <= '1';
    wait for 30 ns;

    -- Fechamento manual
    fechar_manual <= '1'; 
    wait for 30 ns;
    fechar_manual <= '0';
    fim_curso_aberta <= '0';
    wait for 30 ns;
    fim_curso_fechada <= '1';
    wait for 30 ns;

    wait;
  end process;
end architecture;
