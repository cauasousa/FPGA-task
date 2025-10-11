`timescale 1ns/1ps
`default_nettype none
// ============================================================================
// top.sv — ÚNICO MÓDULO (ECP5 Colorlight-i9 @25 MHz)
// Entradas:
//  I1 = START (pulso)
//  I2 = STOP (pulso)
//  I3 = RESET (pulso)
//  I4 = MODO_TESTE (nível: 0=30 s, 1=3 s)
//  I5 = LED_EN (nível: 1 = permite piscar LED onboard)
// Saídas:
//  O1 = M1 (ativa quando motor 1 ligado)
//  O2 = M2 (ativa quando motor 2 ligado)
//  O3 = cronômetro (pisca 1 Hz quando em ciclo)
//  O4 = em ciclo (lógica indicando que um motor está ligado)
//  O5 = heartbeat (pisca ~2 Hz sempre)
// Observação: Somente comentários foram adicionados; o código não foi alterado.
// ============================================================================

module top #(
  // relógio e botões
  parameter integer CLK_FREQ_HZ            = 25_000_000,
  parameter         BUTTONS_ACTIVE_LOW      = 1,  // I1..I3 físicos com pull-up?
  parameter         TESTMODE_ACTIVE_LOW     = 0,  // I4 ativo-baixo?
  parameter         LED_ENABLE_ACTIVE_LOW    = 0,  // I5 ativo-baixo?
  parameter integer DEBOUNCE_TIME_MS               = 5,

  // tempos e piscas
  parameter integer RUN_TIME_NORMAL_S         = 30,
  parameter integer RUN_TIME_TEST_S           = 3,
  parameter integer DIV_TIMER_TOGGLE       = CLK_FREQ_HZ/2, // 0,5s -> 1Hz
  parameter integer DIV_LED_TOGGLE      = CLK_FREQ_HZ/2, // 0,5s -> 1Hz
  parameter integer DIV_HEARTBEAT_TOGGLE       = CLK_FREQ_HZ/4  // 0,25s -> ~2Hz
)(
  input  wire clk,
  input  wire I1, I2, I3, I4, I5,
  output reg  led,
  output reg  O1, O2, O3, O4, O5
);

  // ------------------------------------------------------------------
  // 1) Normalização das entradas e sincronização com o relógio
  //    - Ajusta níveis ativos (quando botões são ativos-baixo)
  //    - Usa sincronizadores de 2 flip-flops para cada sinal
  // ------------------------------------------------------------------

  wire start_in = BUTTONS_ACTIVE_LOW   ? ~I1 : I1;
  wire stop_in  = BUTTONS_ACTIVE_LOW   ? ~I2 : I2;
  wire rst_in   = BUTTONS_ACTIVE_LOW   ? ~I3 : I3;
  wire test_in  = TESTMODE_ACTIVE_LOW  ? ~I4 : I4;   // nível
  wire leden_in = LED_ENABLE_ACTIVE_LOW ? ~I5 : I5;   // nível

  // sincronizadores 2-FF
  reg start_s0, start_s1, stop_s0, stop_s1, rst_s0, rst_s1, test_s0, test_s1, leden_s0, leden_s1;
  always @(posedge clk) begin
    start_s0 <= start_in;  start_s1 <= start_s0;
    stop_s0  <= stop_in;   stop_s1  <= stop_s0;
    rst_s0   <= rst_in;    rst_s1   <= rst_s0;
    test_s0  <= test_in;   test_s1  <= test_s0;
    leden_s0 <= leden_in;  leden_s1 <= leden_s0;
  end
  wire start_lvl = start_s1;
  wire stop_lvl  = stop_s1;
  wire rst_lvl   = rst_s1;
  wire test_lvl  = test_s1;     // nível
  wire leden_lvl = leden_s1;    // nível

  // ------------------------------------------------------------------
  // 2) Debounce (limpeza de ruído de botões) e detecção de borda de subida
  //    - Cada botão tem contador para garantir estabilidade antes de aceitar mudança
  //    - Gera sinais de borda (start_rise, stop_rise, rst_rise)
  // ------------------------------------------------------------------

  function integer DB_MAX; DB_MAX = (CLK_FREQ_HZ/1000)*DEBOUNCE_TIME_MS; endfunction
  localparam integer DBW = ( ( (CLK_FREQ_HZ/1000)*DEBOUNCE_TIME_MS ) <= 1 ) ? 1 : $clog2( (CLK_FREQ_HZ/1000)*DEBOUNCE_TIME_MS );

  reg [DBW-1:0] db_cnt_st, db_cnt_sp, db_cnt_rs;
  reg start_state, stop_state, rst_state;

  // START
  always @(posedge clk) begin
    if (start_lvl == start_state) db_cnt_st <= {DBW{1'b0}};
    else if (db_cnt_st == DB_MAX()-1) begin
      start_state <= start_lvl;
      db_cnt_st   <= {DBW{1'b0}};
    end else db_cnt_st <= db_cnt_st + 1'b1;
  end
  // STOP
  always @(posedge clk) begin
    if (stop_lvl == stop_state) db_cnt_sp <= {DBW{1'b0}};
    else if (db_cnt_sp == DB_MAX()-1) begin
      stop_state <= stop_lvl;
      db_cnt_sp  <= {DBW{1'b0}};
    end else db_cnt_sp <= db_cnt_sp + 1'b1;
  end
  // RESET
  always @(posedge clk) begin
    if (rst_lvl == rst_state) db_cnt_rs <= {DBW{1'b0}};
    else if (db_cnt_rs == DB_MAX()-1) begin
      rst_state <= rst_lvl;
      db_cnt_rs <= {DBW{1'b0}};
    end else db_cnt_rs <= db_cnt_rs + 1'b1;
  end

  reg start_state_d, stop_state_d, rst_state_d;
  always @(posedge clk) begin
    start_state_d <= start_state;
    stop_state_d  <= stop_state;
    rst_state_d   <= rst_state;
  end
  wire start_rise = start_state & ~start_state_d;
  wire stop_rise  = stop_state  & ~stop_state_d;
  wire rst_rise   = rst_state   & ~rst_state_d;

  // ------------------------------------------------------------------
  // 3) Máquina de estados para controlar os motores M1 e M2
  //    - Estados: IDLE, M1_ON, M2_ON
  //    - Temporizador decide mudanças de M1_ON <-> M2_ON a cada 30s (ou 3s em modo teste)
  //    - START inicia o ciclo (vai para M1_ON), STOP/RESET voltam para IDLE
  // ------------------------------------------------------------------

  typedef enum reg [1:0] {IDLE, M1_ON, M2_ON} state_t;
  reg [1:0] st, st_nxt;  // usa o mesmo cod. do typedef acima (compatível com Synplify)

  // temporizador
  localparam integer MAX_CYC = RUN_TIME_NORMAL_S*CLK_FREQ_HZ;
  localparam integer TW      = (MAX_CYC <= 1) ? 1 : $clog2(MAX_CYC);
  reg [TW-1:0] tcnt;
  reg          timeup;

  wire [TW-1:0] target_cycles = test_lvl ? (RUN_TIME_TEST_S*CLK_FREQ_HZ) : (RUN_TIME_NORMAL_S*CLK_FREQ_HZ);
  wire          timer_en      = (st==M1_ON) || (st==M2_ON);

  // contagem do tempo
  always @(posedge clk) begin
    if (!timer_en) begin
      tcnt   <= {TW{1'b0}};
      timeup <= 1'b0;
    end else begin
      if (tcnt == target_cycles-1) begin
        tcnt   <= {TW{1'b0}};
        timeup <= 1'b1;
      end else begin
        tcnt   <= tcnt + 1'b1;
        timeup <= 1'b0;
      end
    end
  end

  // próxima transição (uma única lógica)
  always @* begin
    st_nxt = st;
    case (st)
      IDLE:   if (start_rise) st_nxt = M1_ON;
      M1_ON:  if (rst_rise)   st_nxt = IDLE;
              else if (stop_rise)  st_nxt = IDLE;
              else if (timeup)     st_nxt = M2_ON;
      M2_ON:  if (rst_rise)   st_nxt = IDLE;
              else if (stop_rise)  st_nxt = IDLE;
              else if (timeup)     st_nxt = M1_ON;
      default: st_nxt = IDLE;
    endcase
  end

  // estado atual
  always @(posedge clk) begin
    if (rst_rise) st <= IDLE;
    else          st <= st_nxt;
  end

  // saídas de estado (motores e "em ciclo")
  always @* begin
    case (st)
      IDLE:   begin O1=1'b0; O2=1'b0; O4=1'b0; end
      M1_ON:  begin O1=1'b1; O2=1'b0; O4=1'b1; end
      M2_ON:  begin O1=1'b0; O2=1'b1; O4=1'b1; end
      default:begin O1=1'b0; O2=1'b0; O4=1'b0; end
    endcase
  end

  // ------------------------------------------------------------------
  // 4) Geradores de pisca (timers) para O3, O5 e LED onboard
  //    - O3 pisca 1 Hz apenas quando em ciclo (O4 ativo)
  //    - O5 é heartbeat (~2 Hz) sempre ativo
  //    - led pisca 1 Hz somente se entrada I5 (LED enable) estiver ativa
  // ------------------------------------------------------------------

  localparam integer O3W  = (DIV_TIMER_TOGGLE  <= 1) ? 1 : $clog2(DIV_TIMER_TOGGLE );
  localparam integer O5W  = (DIV_HEARTBEAT_TOGGLE  <= 1) ? 1 : $clog2(DIV_HEARTBEAT_TOGGLE );
  localparam integer LEDW = (DIV_LED_TOGGLE <= 1) ? 1 : $clog2(DIV_LED_TOGGLE);

  reg [O3W-1:0]  div_o3;
  reg [O5W-1:0]  div_o5;
  reg [LEDW-1:0] div_led;

  // O3: pisca 1 Hz apenas quando em ciclo
  always @(posedge clk) begin
    if (!O4) begin
      div_o3 <= {O3W{1'b0}};
      O3     <= 1'b0;
    end else begin
      if (div_o3 == DIV_TIMER_TOGGLE-1) begin
        div_o3 <= {O3W{1'b0}};
        O3     <= ~O3;
      end else begin
        div_o3 <= div_o3 + 1'b1;
      end
    end
  end

  // O5: heartbeat sempre (~2 Hz)
  always @(posedge clk) begin
    if (div_o5 == DIV_HEARTBEAT_TOGGLE-1) begin
      div_o5 <= {O5W{1'b0}};
      O5     <= ~O5;
    end else begin
      div_o5 <= div_o5 + 1'b1;
    end
  end

  // LED onboard: pisca 1 Hz somente se I5 (enable) = 1
  always @(posedge clk) begin
    if (!leden_lvl) begin
      div_led <= {LEDW{1'b0}};
      led     <= 1'b0;
    end else begin
      if (div_led == DIV_LED_TOGGLE-1) begin
        div_led <= {LEDW{1'b0}};
        led     <= ~led;
      end else begin
        div_led <= div_led + 1'b1;
      end
    end
  end

endmodule
`default_nettype wire
