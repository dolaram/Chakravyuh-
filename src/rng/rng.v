/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : rng.v
 * Purpose  : Random number generator implementation 
 *
 * ============================================================= */

// Module declaration
module rng(clk,en,reset,dataout,ready);
`include "constants.vh"

// Input & Output lines
input clk,en,reset;
output [WORDSIZE-1:0] dataout;
reg [WORDSIZE-1:0] dataout;
output ready;
reg ready;

// Behavioral definition 
always @(posedge clk) begin
    if (reset) begin
        $display("\t\trng >> Entering reset stage");
        dataout <= 0;
        ready <= 1;
    end // reset

    if (en) begin
        dataout <= dataout + NONCE_INCREMENT_OFFSET;
    end // en
end // always block

endmodule
