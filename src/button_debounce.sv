module button_debounce #(
    parameter FREQ = 50000000, 
    parameter DEBOUNCE_MS = 20          
)(
  input logic Clk,       
  input logic rst_n,     
  input logic button_i,  
  output logic button_o   // cинхронизированный сигнал от кнопки
);
  // Вычисляем максимальное значение счетчика для заданного времени
  localparam MAX_COUNT = (FREQ / 1000) * DEBOUNCE_MS;
  localparam COUNTER_WIDTH = $clog2(MAX_COUNT);

  logic [1:0] sync_reg;
  logic sync_btn;
  logic [COUNTER_WIDTH-1:0] counter;

  // Двойная синхронизация для защиты от метастабильности
  always_ff @(posedge Clk or negedge rst_n) begin : stage1
    if (!rst_n) begin
      sync_reg <= 2'b00;
    end else begin
      sync_reg <= {sync_reg[0], button_i};
    end
  end
    
  assign sync_btn = sync_reg[1];

  logic button_state;
  logic button_state_prev;

  always_ff @(posedge Clk or negedge rst_n) begin : stage2
    if (!rst_n) begin
      counter <= '0;
      button_state <= 1'b0;
    end else begin
      if (button_state != sync_btn) begin
        if (counter == MAX_COUNT - 1) begin
          button_state <= sync_btn;
          counter <= '0;
        end else begin
          counter <= counter + 1'b1;
        end
      end else begin
        counter <= '0;
      end
    end
  end

  always_ff @(posedge Clk) begin : stage3
    if (!rst_n) begin
      button_state_prev <= 1'b0;
      button_o <=1'b0;
    end else begin
      button_state_prev <=button_state;
      button_o <= button_state & ~button_state_prev; 
    end
  end
endmodule