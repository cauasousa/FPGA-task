//==============================================================
// testbench.sv — Teste do Somador/Subtrator Completo
//==============================================================

`timescale 1ns/1ps

module tb_somador_subtrator;

    logic M, A, B, Te;
    logic S, Ts;

    // Instância do DUT
    somador_subtrator DUT (
        .M(M),
        .A(A),
        .B(B),
        .Te(Te),
        .S(S),
        .Ts(Ts)
    );

    // Teste automático de todas as 16 combinações
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_somador_subtrator);

        $display("===============================================");
        $display("M A B Te | S Ts | Operação");
        $display("===============================================");

        // Loop pelas 16 combinações
        for (int i = 0; i < 16; i++) begin
            {M, A, B, Te} = i[3:0];
            #5;

            if (M == 0)
                $display("%b %b %b %b | %b  %b  | Soma", M, A, B, Te, S, Ts);
            else
                $display("%b %b %b %b | %b  %b  | Subtração", M, A, B, Te, S, Ts);
        end

        $display("===============================================");
        #10;
        $finish;
    end

endmodule
