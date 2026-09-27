module UartTx  
(
  input logic Clk,
  input logic rst_n,
  input logic [7:0] i_data,
  input logic i_vld,
  output logic o_tx,
  input logic tick
);

  reg [7:0] Data;
  logic o_data;
  always_ff @(posedge Clk) begin : stage1
    if (i_vld) begin
      Data <= i_data;
    end else if (tick) begin
      o_data <= Data[0];
      Data <= Data >> 1;
    end else if (!rst_n) begin
      Data <= 8'd0;
    end
  end

  typedef enum logic [3:0] {
    IDLE  = {1'b0, 3'd0},
    START = {1'b0, 3'd1},
    BIT0  = {1'b1, 3'd0},
    BIT1  = {1'b1, 3'd1},
    BIT2  = {1'b1, 3'd2},
    BIT3  = {1'b1, 3'd3},
    BIT4  = {1'b1, 3'd4},
    BIT5  = {1'b1, 3'd5},
    BIT6  = {1'b1, 3'd6},
    BIT7  = {1'b1, 3'd7},
    STOP  = {1'b0, 3'd2}
  } state_t;

  state_t state, next_state;

  always_comb begin : block1
    case (state)
      IDLE:   next_state = i_vld ? START : state;
      START:  next_state = tick ? BIT0 : state;
      BIT0:   next_state = tick ? BIT1 : state;
      BIT1:   next_state = tick ? BIT2 : state;
      BIT2:   next_state = tick ? BIT3 : state;
      BIT3:   next_state = tick ? BIT4 : state;
      BIT4:   next_state = tick ? BIT5 : state;
      BIT5:   next_state = tick ? BIT6 : state;
      BIT6:   next_state = tick ? BIT7 : state;
      BIT7:   next_state = tick ? STOP : state;
      STOP:   next_state = tick ? IDLE : state;
      default: next_state = state;
    endcase
  end

  always_ff @(posedge Clk or negedge rst_n) begin : block2
    if (!rst_n) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin : block3
    case (state)
      IDLE: o_tx = 1'b1;
      STOP: o_tx = 1'b1;
      START: o_tx = 1'b0; 
      default: o_tx = o_data;
    endcase
  end
endmodule