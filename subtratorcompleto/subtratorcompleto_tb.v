`include "subtratorcompleto.v"
`timescale 1ns/100ps

module subtratorcompleto_tb;
reg a0, b0, cin0;
wire s0, cout0;
subtratorcompleto uut (.a(a0),.b(b0),.cin(cin0),.s(s0),.cout(cout0));

initial begin
$dumpfile("subtratorcompleto.vcd");
$dumpvars(0, subtratorcompleto_tb);
          a0 = 0; b0 = 0; cin0 = 0;
     #10; a0 = 0; b0 = 0; cin0 = 1;
     #10; a0 = 0; b0 = 1; cin0 = 0;
     #10; a0 = 0; b0 = 1; cin0 = 1;
     #10; a0 = 1; b0 = 0; cin0 = 0;
     #10; a0 = 1; b0 = 0; cin0 = 1;
     #10; a0 = 1; b0 = 1; cin0 = 0;
     #10; a0 = 1; b0 = 1; cin0 = 1;
     #10; $finish;
     end
endmodule