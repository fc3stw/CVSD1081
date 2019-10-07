`timescale 1ns/100ps
module alu(
            clk_p_i,
            reset_n_i,
            data_a_i,
            data_b_i,
            inst_i,
            data_o,
            overflow_o
            );
    /* ============================================ */
    input       clk_p_i;
    input       reset_n_i;
    input [7:0] data_a_i;
    input [7:0] data_b_i;
    input [2:0] inst_i;

    output reg [7:0]    data_o;
    output reg          overflow_o;

    reg signed [15:0]   ALU_d2_w;
    reg signed [7:0]    data_a_d1_r;
    reg signed [7:0]    data_b_d1_r;
    reg signed [2:0]    inst_d1_r;
    reg                 overflow_d2_w;

    wire signed [8:0]   sum_ab;
    wire signed [8:0]   diff_ab;
    wire signed [15:0]  product_ab;
    wire signed [7:0]   and_ab;
    wire signed [7:0]   xor_ab;
    wire signed [7:0]   max_ab;
    wire signed [7:0]   flip_a;

    assign sum_ab = data_a_d1_r + data_b_d1_r;
    assign diff_ab = data_b_d1_r - data_a_d1_r;
    assign product_ab = data_a_d1_r * data_b_d1_r;
    assign and_ab = data_a_d1_r & data_b_d1_r;
    assign xor_ab = data_a_d1_r ^ data_b_d1_r;
    assign max_ab = (data_a_d1_r > data_b_d1_r)? data_a_d1_r : data_b_d1_r;
    assign flip_a = ~data_a_d1_r + 1'b1;

    /* ============================================ */
    // input register
    always@(posedge clk_p_i, negedge reset_n_i)begin
        if(!reset_n_i)begin
            data_a_d1_r <=  8'd0;
            data_b_d1_r <=  8'd0;
            inst_d1_r   <=  3'd0;
        end
        else begin
            data_a_d1_r <=  data_a_i;
            data_b_d1_r <=  data_b_i;
            inst_d1_r   <=  inst_i;
        end
    end

    /* ============================================ */

    always@ (*)
    begin
      case(inst_d1_r)
        3'b000:    ALU_d2_w = {{7{sum_ab[8]}}, sum_ab};
        3'b001:    ALU_d2_w = {{7{diff_ab[8]}}, diff_ab};
        3'b010:    ALU_d2_w = product_ab;
        3'b011:    ALU_d2_w = {{8{and_ab[7]}}, and_ab};
        3'b100:    ALU_d2_w = {{8{xor_ab[7]}}, xor_ab};
        3'b101:    ALU_d2_w = (data_a_d1_r[7])? {{8{~data_a_d1_r[7]}}, flip_a} : {{8{data_a_d1_r[7]}}, data_a_d1_r};
        3'b110:    ALU_d2_w = {{8{sum_ab[8]}}, sum_ab[8:1]};
        3'b111:    ALU_d2_w = {{8{max_ab[7]}}, max_ab};
        default:   ALU_d2_w = 15'b0;
      endcase
    end

    always@ (*)
    begin
        overflow_d2_w = ~( &(ALU_d2_w[15:7])==1'b1 || |(ALU_d2_w[15:7])==1'b0 );
    end

    /* ============================================ */
    always@(posedge clk_p_i or negedge reset_n_i)
    begin
      if (reset_n_i == 1'b0)
      begin
        data_o <= 0;
        overflow_o <= 0;
      end
      else
      begin
        data_o <= ALU_d2_w[7:0];
        overflow_o <= overflow_d2_w;
      end
    end
    /* ============================================ */

endmodule

