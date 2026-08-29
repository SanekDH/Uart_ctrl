module UartTick #(parameter BOUDRATE = 115200, parameter FREQ = 50000000)
(
    input logic Clk,
    input logic Rst,
    output reg Tick 
);
  localparam real TICK_INC_REAL_1 = ( ( 4294967296.0 * 16.0 * BOUDRATE ) / ( FREQ ) );
  localparam [32:0] TICK_INC_INT_1 = TICK_INC_REAL_1;

  reg [32:0] tick_cnt;
  reg [32:0] tick_inc;

  always_ff @( posedge Clk ) begin : stage1
    if (Rst) begin
      tick_cnt <= 33'd0;
    end else begin
      if (tick_cnt[32]) begin
        tick_cnt <= {1'b0, tick_cnt[31:0]} + tick_inc;
      end else begin
        tick_cnt <= tick_cnt + tick_inc;
      end
    end
  end

  always_ff @( posedge Clk ) begin : stage2
    tick_inc <= TICK_INC_INT_1;
    Tick <= tick_cnt[32]; 
  end
endmodule