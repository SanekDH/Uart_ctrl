module Segment (
  input logic Clk,
  input reg [7:0] DataIn,
  output reg [7:0] Enable,
  output reg [7:0] SegData = 8'b00000000
);
  reg [2:0] swap;
  reg [7:0] count = {8{1'b0}};
  reg [7:0] DataBuf = 8'b00000000;

  assign DataBuf = DataIn;

  always_ff @(posedge Clk) begin : stage1
    count <= count + 8'd1;
    if (count == 8'd0) begin
      swap <= swap + 3'd1;
    end

    case (swap)
      3'b000: begin  
        Enable <= 8'b01111111;
        if (!DataBuf[7]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b001: begin
        Enable <= 8'b10111111;
        if (!DataBuf[6]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b010: begin
        Enable <= 8'b11011111;
        if (!DataBuf[5]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b011: begin
        Enable <= 8'b11101111;
        if (!DataBuf[4]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b100: begin
        Enable <= 8'b11110111;
        if (!DataBuf[3]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b101: begin
        Enable <= 8'b11111011;
        if (!DataBuf[2]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b110: begin
       Enable <= 8'b11111101;
        if (!DataBuf[1]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
      3'b111: begin
        Enable <= 8'b11111110;
        if (!DataBuf[0]) begin
          SegData <= 8'b00000011;
        end
        else begin
          SegData <= 8'b10011111;
        end
      end
    endcase
  end
endmodule