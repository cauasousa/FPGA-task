//==============================================================
// design.sv — Somador e Subtrator Completo (de acordo com a Tabela 1)
//==============================================================

module somador_subtrator (
    input  logic M,     // 0 = soma, 1 = subtração
    input  logic A, B,  // bits de entrada
    input  logic Te,    // transporte de entrada (carry-in / borrow-in)
    output logic S,     // saída (resultado)
    output logic Ts     // transporte de saída (carry-out / borrow-out)
);

    
    // Soma completa (para ambos os modos)
  assign S  = (A ^ B) ^ Te;
  assign Ts =  (B & Te) | ((A ^ M) & (B | Te));

endmodule
