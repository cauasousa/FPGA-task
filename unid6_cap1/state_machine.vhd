library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_machine is
  port (
    clk   : in std_logic;  -- clock do sistema
    rst_n : in std_logic;  -- reset assíncrono ativo-baixo
    sensor : in std_logic;  -- detecta presença (1 = pessoa detectada)
    fechar_manual : in std_logic;  -- botão de fechamento antecipado
    fim_curso_aberta : in std_logic;  -- sensor indica porta totalmente aberta
    fim_curso_fechada : in std_logic;  -- sensor indica porta totalmente fechada
    motor_abrir      : out std_logic;  -- ativa o motor no sentido de abrir
    motor_fechar     : out std_logic   -- ativa o motor no sentido de fechar
  );
end entity;

architecture rtl of state_machine is
-- begin

  type state_type is (FECHADA, ABRINDO, ABERTA, FECHANDO);
  signal state, next_state : state_type;
  constant T_ABERTA_MAX : integer := 6;  -- contador maior
  signal timer_cnt : integer range 0 to 6 := 0;
  
begin
    process(clk, rst_n)
    begin
      if rst_n = '0' then
        state <= FECHADA;
        timer_cnt <= 0;
      elsif rising_edge(clk) then
        state <= next_state;

        -- temporizador de 4 bits para estado ABERTA
        if state = ABERTA then
        -- Durante ABERTA, se sensor=1, reinicia temporizador
          if sensor = '1' then
            timer_cnt <= 0;  -- reinicia enquanto há presença
          elsif timer_cnt < T_ABERTA_MAX then
            timer_cnt <= timer_cnt + 1;
          end if;
        else
          timer_cnt <= timer_cnt + 1;  
        end if;
      end if;

    end process;

    process(state, sensor, fechar_manual, fim_curso_aberta, fim_curso_fechada, timer_cnt)
    begin
        -- valores padrão
        next_state   <= state;
        motor_abrir  <= '0';
        motor_fechar <= '0';

        case state is
            
            ----------------------------------------------------------------
            when FECHADA =>
              -- Estado: FECHADA — porta fechada, motores desligados
              -- Transição: FECHADA → ABRINDO quando sensor=1
              motor_abrir  <= '0';
              motor_fechar <= '0';
              if sensor = '1' then
                next_state <= ABRINDO;
              end if;

            ----------------------------------------------------------------
            when ABRINDO =>
              -- Estado: ABRINDO — motor_abrir ligado até porta abrir completamente
              -- Transição: ABRINDO → ABERTA quando fim_curso_aberta=1
              motor_abrir  <= '1';
              motor_fechar <= '0';
              if fim_curso_aberta = '1' then
                next_state <= ABERTA;
              end if;

            ----------------------------------------------------------------
            when ABERTA =>
              -- Estado: ABERTA — porta aberta, aguarda tempo T_ABERTA sem presença
              -- Transição: ABERTA → FECHANDO quando T_ABERTA expira e sensor=0, ou fechar_manual=1

              motor_abrir  <= '0';
              motor_fechar <= '0';
              
              if (timer_cnt >= T_ABERTA_MAX and sensor = '0') or(fechar_manual = '1') then
                next_state <= FECHANDO;
              end if;
 
            ----------------------------------------------------------------
            when FECHANDO =>
              -- Estado: FECHANDO — motor_fechar ligado até porta fechar completamente
              -- Transição: FECHANDO → FECHADA quando fim_curso_fechada=1

              motor_abrir  <= '0';
              motor_fechar <= '1';
              if fim_curso_fechada = '1' then
                next_state <= FECHADA;
              end if;

            ----------------------------------------------------------------
            when others =>
              next_state   <= FECHADA;
              motor_abrir  <= '0';
              motor_fechar <= '0';
        end case;
    end process;

end rtl;
