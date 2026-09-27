module UartRx (
  input logic Clk,
  input logic rst_n,   
  input logic i_rx,    
  input logic tick,    
  output logic [7:0] o_data,  
  output logic o_vld    
);

  logic rx_sync1, rx_sync2;
  always_ff @(posedge Clk or negedge rst_n) begin : stage1
    if (!rst_n) begin
      rx_sync1 <= 1'b1;
      rx_sync2 <= 1'b1;
    end else begin
      rx_sync1 <= i_rx;
      rx_sync2 <= rx_sync1;
    end
  end

  logic [7:0] rx_shift_reg;
  logic [3:0] tick_cnt;

  typedef enum logic [3:0] {
    IDLE  = 4'd0,
    START = 4'd1,
    BIT0  = 4'd2,
    BIT1  = 4'd3,
    BIT2  = 4'd4,
    BIT3  = 4'd5,
    BIT4  = 4'd6,
    BIT5  = 4'd7,
    BIT6  = 4'd8,
    BIT7  = 4'd9,
    STOP  = 4'd10
  } state_t;

  state_t state, next_state;

  always_comb begin
    next_state = state;
    case (state)
      IDLE: begin
        if (rx_sync2 == 1'b0) begin
          next_state = START;
        end
      end
      START: begin
        if (tick && tick_cnt == 4'd7) begin
          if (rx_sync2 == 1'b0) 
            next_state = BIT0;
          else
            next_state = IDLE;  
        end
      end

      BIT0: if (tick && tick_cnt == 4'd15) next_state = BIT1;
      BIT1: if (tick && tick_cnt == 4'd15) next_state = BIT2;
      BIT2: if (tick && tick_cnt == 4'd15) next_state = BIT3;
      BIT3: if (tick && tick_cnt == 4'd15) next_state = BIT4;
      BIT4: if (tick && tick_cnt == 4'd15) next_state = BIT5;
      BIT5: if (tick && tick_cnt == 4'd15) next_state = BIT6;
      BIT6: if (tick && tick_cnt == 4'd15) next_state = BIT7;
      BIT7: if (tick && tick_cnt == 4'd15) next_state = STOP;

      STOP: begin
        if (tick && tick_cnt == 4'd15) begin
          next_state = IDLE;
        end
      end
      default: next_state = IDLE;
    endcase
  end
  //управление счётчиком
  always_ff @(posedge Clk or negedge rst_n) begin : stage2
    if (!rst_n) begin
      state <= IDLE;
      tick_cnt <= 4'd0;
    end else begin
      state <= next_state;
      if (state != next_state && next_state != IDLE) begin
        tick_cnt <= 4'd0;
      end else if (tick && state != IDLE) begin
        tick_cnt <= tick_cnt + 1'b1;
      end
    end
  end
  // выдача данных
  always_ff @(posedge Clk or negedge rst_n) begin : stage3
    if (!rst_n) begin
      rx_shift_reg <= 8'd0;
      o_data <= 8'd0;
      o_vld <= 1'b0; // данные не валидны
    end else begin
      o_vld <= 1'b0; // данные не валидны (по умолчанию)
      if (tick && tick_cnt == 4'd15) begin
        if (state == BIT0 || state == BIT1 || state == BIT2 || state == BIT3 || 
          state == BIT4 || state == BIT5 || state == BIT6 || state == BIT7) begin
          rx_shift_reg <= {rx_sync2, rx_shift_reg[7:1]};
        end else if (state == STOP) begin
          if (rx_sync2 == 1'b1) begin
            o_data <= rx_shift_reg;
            o_vld <= 1'b1; 
          end
        end
      end
    end
  end
endmodule