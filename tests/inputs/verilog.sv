/* http://www.asic-world.com/examples/verilog/parity.html#And_the_Practical_One
 */
 //-----------------------------------------------------
 // Design Name : parity_using_function2
 // File Name   : parity_using_function2.v
 // Function    : Parity using function
 // Coder       : Deepak Kumar Tala
 //-----------------------------------------------------
 module parity_using_function2 (
 data_in    , //  8 bit data in
 parity_out   //  1 bit parity out
 );
 output  parity_out ;
 input [7:0] data_in ; 
      
 wire parity_out ;
 function parity;
   input [31:0] data; 
   integer i; 
   begin 
     parity = 0; 
     for (i = 0; i < 32; i = i + 1) begin  
       parity = parity ^ data[i]; 
     end 
   end 
 endfunction 
 
 always @ (data_in)
 begin
   parity_out = parity(data_in);
 end
 
 endmodule
//-----------------------------------------------------
 // Design Name : parallel_crc_ccitt
 // File Name   : parallel_crc.v
 // Function    : CCITT Parallel CRC
 // Coder       : Deepak Kumar Tala
 //-----------------------------------------------------
 module parallel_crc_ccitt (
 clk     ,
 reset   ,
 enable  ,
 init    , 
 data_in , 
 crc_out
 );
 //-----------Input Ports---------------
 input clk     ;
 input reset   ;
 input enable  ;
 input init    ;
 input [7:0] data_in ;
 //-----------Output Ports---------------
 output [15:0] crc_out;
 //------------Internal Variables--------
 reg [15:0]   crc_reg;
 wire [15:0]  next_crc;
 //-------------Code Start-----------------
 assign crc_out = crc_reg;
 // CRC Control logic
 always @ (posedge clk)
 if (reset) begin
   crc_reg <= 16'hFFFF;
 end else if (enable) begin
   if (init) begin
      crc_reg <= 16'hFFFF;
   end else begin
      crc_reg <= next_crc;
   end
 end
 // Parallel CRC calculation
 assign next_crc[0] = data_in[7] ^ data_in[0] ^ crc_reg[4] ^ crc_reg[11];
 assign next_crc[1] = data_in[1] ^ crc_reg[5];
 assign next_crc[2] = data_in[2] ^ crc_reg[6];
 assign next_crc[3] = data_in[3] ^ crc_reg[7];
 assign next_crc[4] = data_in[4] ^ crc_reg[8];
 assign next_crc[5] = data_in[7] ^ data_in[5] ^ data_in[0] ^ crc_reg[4] ^ crc_reg[9] ^ crc_reg[11];
 assign next_crc[6] = data_in[6] ^ data_in[1] ^ crc_reg[5] ^ crc_reg[10];
 assign next_crc[7] = data_in[7] ^ data_in[2] ^ crc_reg[6] ^ crc_reg[11];
 assign next_crc[8] = data_in[3] ^ crc_reg[0] ^ crc_reg[7];
 assign next_crc[9] = data_in[4] ^ crc_reg[1] ^ crc_reg[8];
 assign next_crc[10] = data_in[5] ^ crc_reg[2] ^ crc_reg[9];
 assign next_crc[11] = data_in[6] ^ crc_reg[3] ^ crc_reg[10];
 
 endmodule
