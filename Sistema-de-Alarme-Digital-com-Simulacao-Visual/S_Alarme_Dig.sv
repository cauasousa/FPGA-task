// https://digitaljs.tilk.eu/#90285b9ff8d563df10d4344ccddb3061c07a7d129841394d769af89480289cd1 

module alarme (
 input A,
 input B,
 input C,
 output Y
);
   wire AB, AC, BC;
  
   assign AB = A & B;
   assign AC = A & C;
   assign BC = B & C;
  
   assign Y = AB | AC | BC;
endmodule