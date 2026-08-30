module UartRx 
(
  input logic Clk,
  input logic Rst,
  input logic Tick,
  input logic RxIn,
  output reg [7:0] DataOut,
  output reg DataValid 

);
  localparam ST_WAIT = 2'b00;
  localparam ST_16CLOCK = 2'b01;
  localparam ST_RX = 2'b10;
  localparam ST_END = 2'b11;
  

  reg [3:0] cnt_tick;
  reg [3:0] cnt_data; // счетчик колличества бит для основного буфера 
  reg [4:0] reg_data; // счетчик единиц во время накопления 16-ти отсчетов
  reg [9:0] BufData;
  reg [1:0] State;
  reg [2:0] rxd;  // защита от случайных импульсов
  reg rxd_sync;
 
  //зашита от случайных коротких импульсов 
  always_ff @(posedge Clk) begin : stage1
    if (Rst) begin
      rxd <= 3'b111;
      rxd_sync <= 1'b1;
    end 
    else begin
      rxd <= {rxd[1:0], RxIn};
      rxd_sync <= (rxd[2])? (rxd[1] | rxd[0]) : (rxd[1] & rxd[0]);
    end
  end
  
  reg rx_bit;
  assign rx_bit = (reg_data < 5'd8)? 1'b0 : 1'b1; 
  
  //автомат передачи данных
  always_ff @(posedge Clk) begin : stage2
    if (Rst) begin
      State <= ST_WAIT;
      cnt_data <= 4'd0;
      cnt_tick <= 4'd0;
      DataValid <= 1'b0;
      BufData <= 10'b0;
    end else begin
      case (State)
        ST_WAIT:
        begin
          DataValid <= 1'b0;
          if (Tick & !rxd_sync) begin
            State <= ST_16CLOCK;
            cnt_tick <= 4'd1;
            cnt_data <= 4'd0;
            reg_data <= 5'd0;
          end
        end
        ST_16CLOCK:
        begin
          if (Tick) begin
            cnt_tick <= cnt_tick + 4'd1;
            reg_data <= reg_data + {4'd0, rxd_sync};
            if (cnt_tick == 4'd15) begin
              State <= ST_RX;
            end
          end
        end
        ST_RX:
        begin
          State <= (cnt_data < 4'd9)? ST_16CLOCK : ST_END;
          BufData <= {rx_bit, BufData[9:1]};
          cnt_data <= cnt_data + 4'd1;
          cnt_tick <= 4'd0;
          reg_data <= 5'd0;
        end
        ST_END:
        begin
          DataValid <= BufData[9] & !BufData[0];
          DataOut <= BufData[8:1];
          State <= ST_WAIT;
        end
      endcase
    end
  end
endmodule