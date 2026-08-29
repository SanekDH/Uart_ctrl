module UartTx
(
  input logic Clk,
  input logic Tick,
  input logic [7:0] TxDataIn,
  input logic Rst,
  input logic NewData, // запрос на обработку нового байта
  output logic TxOut,
  output logic ReadyForData
);
  
  localparam [0:0] ST_WAIT = 1'b0;
  localparam [0:0] ST_TX = 1'b1;

  reg [7:0] RegData;
  reg [9:0] BufData;
  reg State;
  reg tx_data_exist; // флаг занятости (1 - занят)
  reg [3:0] cnt_buf; // счетчик битов (10 бит)
  reg [3:0] cnt_tick; // счетчик передискретизации (16-кратная дискретизация)

  assign TxOut = BufData[0];
  
  always_ff @(posedge Clk) begin : stage1
    if (Rst) begin
      tx_data_exist <= 1'b0;
      ReadyForData <= 1'b1;
      State <= ST_WAIT;
    end else begin
      case (State)
        ST_WAIT:
        begin
          cnt_buf <= 4'd0;
          cnt_tick <= 4'd0;
          if (Tick & tx_data_exist) begin
            BufData <= {1'b1, RegData, 1'b0};
            ReadyForData <= 1'b0;
            State <= ST_TX;
          end else begin
            BufData <= {10{1'b1}};
            State <= ST_WAIT;
          end
          if (NewData) begin
            tx_data_exist <= 1'b1;
            RegData <= TxDataIn;
          end
        end
        ST_TX: 
        begin
          if (Tick) begin
            cnt_tick <= cnt_tick + 4'd1;
            if (cnt_tick == 4'd15) begin
              cnt_buf <= cnt_buf + 4'd1;
              BufData <= {1'b1, BufData[9:1]};
            end
          end
            if (cnt_buf == 4'd10) begin
              tx_data_exist <= 1'b0;
              ReadyForData <= 1'b1;
              State <= ST_WAIT;
            end 
            else begin
              State <= ST_TX;
            end
        end
      endcase
    end
  end
endmodule