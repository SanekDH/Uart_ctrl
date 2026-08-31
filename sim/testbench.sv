module testbench();
  parameter BOUDRATE = 115200; 
  parameter FREQ = 50000000;
  parameter CLK_PERIOD = 20;

  logic Clk = 1'b0;
  logic Rst = 1'b1;
  logic txd; // это будет общая линия для tx и rx
  logic new_data = 1'b0;
  logic [7:0] tx_data_in = 8'd0;
  logic data_valid;
  
  Uart #(.BOUDRATE(BOUDRATE), .FREQ(FREQ))
  DUT
  (
    .Clk(Clk),
    .Rst(Rst),
    .RxIn(txd),
    .DataOut(),
    .DataValid(data_valid),
    .TxDataIn(tx_data_in),
    .NewData(new_data), // запрос на обработку нового байта
    .TxOut(txd),
    .ReadyForData(),
    .seg_data(),
    .enable() 
  );

  initial begin
    Clk = 0;
    forever #(CLK_PERIOD/2) Clk = ~Clk;
  end

  initial begin
    repeat(20) @(posedge Clk);
    Rst <= 1'b0;
    repeat(10) @(posedge Clk);
    new_data <= 1'b1;
    tx_data_in <= 8'b10101010;
    repeat(1) @(posedge Clk);
    new_data <= 1'b0;
    #10000;
  end
endmodule