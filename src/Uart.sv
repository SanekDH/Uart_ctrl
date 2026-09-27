module Uart #(
  parameter FREQ = 50000000,
  parameter BOUDRATE = 115200,
  parameter DEBOUNCE_MS = 20 
)(
  input logic Clk,
  input logic rst_n, 
  input logic i_rx,
  output logic o_tx,
  input logic [7:0] i_tx_data,
  input logic i_tx_vld_button, // сигнал от кнопки
  output logic [7:0] o_rx_data,
  output logic o_rx_vld
);

  logic rx_tick_16x; 
  logic tx_tick_1x;   
  logic i_tx_vld; // cинхронизированный сигнал от кнопки

  logic [3:0] tx_div_cnt;
  always_ff @(posedge Clk or negedge rst_n) begin
    if (!rst_n) begin
      tx_div_cnt <= 4'd0;
      tx_tick_1x <= 1'b0;
    end else begin
      tx_tick_1x <= 1'b0;       
      if (rx_tick_16x) begin
        tx_div_cnt <= tx_div_cnt + 1'b1;
        if (tx_div_cnt == 4'd15) begin
          tx_tick_1x <= 1'b1;
        end
      end
    end
  end

  button_debounce #(
    .FREQ(FREQ),
    .DEBOUNCE_MS(DEBOUNCE_MS)
  ) button_debounce_ex1 (
    .Clk(Clk),
    .rst_n(rst_n),
    .button_i(i_tx_vld_button),
    .button_o(i_tx_vld)
  );
  
  UartTick #(
    .FREQ(FREQ),
    .BOUDRATE(BOUDRATE) 
  ) uart_tick (
    .Clk(Clk),
    .rst_n(rst_n),
    .Tick(rx_tick_16x) 
  );

  UartTx uart_tx (
    .Clk(Clk),
    .rst_n(rst_n),
    .i_data(i_tx_data),
    .i_vld(i_tx_vld),
    .tick(tx_tick_1x), // подаем поделенный тик 1x Baudrate
    .o_tx(o_tx)
  );

  UartRx uart_rx (
    .Clk(Clk),
    .rst_n(rst_n),
    .i_rx(i_rx),
    .tick(rx_tick_16x), // подаем оригинальный тик 16x Baudrate
    .o_data(o_rx_data),
    .o_vld(o_rx_vld)
  );
endmodule