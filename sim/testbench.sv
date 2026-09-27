module testbench();
  parameter BOUDRATE = 115200; 
  parameter FREQ = 50000000;
  parameter CLK_PERIOD = 20;
  parameter DEBOUNCE_MS = 1;

  logic Clk = 1'b0;
  logic rst_n = 1'b0;
  logic txd; // это будет общая линия для tx и rx
  logic new_data = 1'b0;
  logic [7:0] tx_data_in = 8'd0;
  logic [7:0] rx_data_out = 8'd0;
  logic data_valid;
  
  Uart #(.BOUDRATE(BOUDRATE), .FREQ(FREQ), .DEBOUNCE_MS(DEBOUNCE_MS))
  DUT
  (
    .Clk(Clk),
    .rst_n(rst_n),
    .i_rx(txd),
    .o_tx(txd),
    .o_rx_data(rx_data_out),
    .i_tx_data(tx_data_in),
    .i_tx_vld_button(new_data),
    .o_rx_vld(data_valid)
  );

  initial begin
    Clk = 0;
    forever #(CLK_PERIOD/2) Clk = ~Clk;
  end

  initial begin
    repeat(20) @(posedge Clk);
    rst_n <= 1'b1;
    repeat(10) @(posedge Clk);
    tx_data_in <= 8'b10101010;
    new_data <= 1'b1;
    repeat(51000) @(posedge Clk);
    new_data <= 1'b0;
  end
endmodule