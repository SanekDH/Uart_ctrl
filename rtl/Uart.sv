module Uart 
#(parameter BOUDRATE = 115200, 
  parameter FREQ = 50000000
  )
(
  input logic Clk,
  input logic Rst,
  input logic RxIn,
  //output reg [7:0] DataOut,
  output reg DataValid,
  input logic [7:0] TxDataIn,
  input logic NewData, // запрос на обработку нового байта
  output logic TxOut,
  output logic ReadyForData,
  output reg [7:0] seg_data,
  output reg [7:0] enable 
);
  wire tick;
  wire [7:0] DataOut;

  UartTick #(.BOUDRATE(BOUDRATE), .FREQ(FREQ))
  uart_tick_ex1
  (
    .Clk(Clk),
    .Rst(Rst),
    .Tick(tick)
  );

  UartRx uart_rx_ex1 
  (
    .Clk(Clk),
    .Rst(Rst),
    .Tick(tick),
    .RxIn(RxIn),
    .DataOut(DataOut),
    .DataValid(DataValid)
  );

  UartTx uart_tx_ex1
  (
    .Clk(Clk),
    .Rst(Rst),
    .Tick(tick),
    .TxDataIn(TxDataIn),
    .NewData(NewData),
    .TxOut(TxOut),
    .ReadyForData(ReadyForData)
  );

  Segment segment_ex1
  (
    .Clk(Clk),
    .DataIn(DataOut),
    .Enable(enable),
    .SegData(seg_data),
    .Rst(Rst)
  );
endmodule