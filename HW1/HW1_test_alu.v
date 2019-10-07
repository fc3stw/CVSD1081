`timescale 1ns/100ps

module test_alu;
reg [7:0] inputA,inputB;
reg [7:0] inputA_d1,inputB_d1,inputA_d2,inputB_d2;
reg clk,reset;
reg [2:0] instruction;
wire [7:0] alu_out;
wire alu_overflow;

// reg	[7:0]	answer_d1,answer_d2;
integer i,j,t,outfile,pat_error,pat_error_task;
integer true_out, true_out_d1, true_out_d2;

wire	[2:0]	test_instruction;
wire 	test_all_ins;
wire  [9:0] test_times;

//////////////////////////////////////////////////////////////////////
// the instruction you want to test: 
//   assign test_all_ins = 1 to test all insturctions with test_times times
//   assign test_all_ins = 0 to test one instruction at the same time
//   assign test_instruction from 000 ~ 111 mapping to your instruction 000 ~ 111
assign 	test_all_ins = 1'b1;
assign  test_times = 10'd100;
assign	test_instruction = 3'b000;
//////////////////////////////////////////////////////////////////////

alu alu_0( 
       .clk_p_i(clk),
       .reset_n_i(reset),
       .data_a_i(inputA),
       .data_b_i(inputB),
       .inst_i(instruction),
       .data_o(alu_out),
       .overflow_o(alu_overflow)
       );

always #4 clk=~clk;                      //cycle time is 8ns

always@(posedge clk)
begin
  true_out_d1 <= true_out;
  true_out_d2 <= true_out_d1;

  inputA_d1 <= inputA;
  inputB_d1 <= inputB;
  inputA_d2 <= inputA_d1;
  inputB_d2 <= inputB_d1;
end

initial begin
  $dumpfile("LEDDC.vcd");
  $dumpvars;
end


// define repeat procedure as task
// would copy and paste whole task to where you use it
task CHECK;                             
  begin // repeat procedure

    if((true_out_d2>127 || true_out_d2<-128) && (t!=0))
    begin
      if(alu_overflow)
      begin
        $display("Correct! Report overflow correctly. A=%b,  B=%b,  answer=%b,  yours=%b, overflow_yours=%b",inputA_d2,inputB_d2,true_out_d2[7:0],alu_out,alu_overflow);
      end
      else
      begin
        $display(" Wrong!  Overflow happened but not reported. A=%b,  B=%b,  answer=%b,  yours=%b, overflow_yours=%b",inputA_d2,inputB_d2,true_out_d2[7:0],alu_out,alu_overflow);
        pat_error=pat_error+1;
      end
    end
    else if(t!=0)
    begin
      if(~alu_overflow && alu_out == true_out_d2[7:0]) begin
        $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b, overflow_yours=%b",inputA_d2,inputB_d2,true_out_d2[7:0],alu_out,alu_overflow);
      end
      else if(alu_overflow)
      begin
        $display(" Wrong!  Overflow not happened but reported. A=%b,  B=%b,  answer=%b,  yours=%b, overflow_yours=%b",inputA_d2,inputB_d2,true_out_d2[7:0],alu_out,alu_overflow);
        pat_error=pat_error+1;        
      end
      else
      begin
        $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b, overflow_yours=%b",inputA_d2,inputB_d2,true_out_d2[7:0],alu_out,alu_overflow);
        pat_error=pat_error+1;
      end
    end

  end

endtask

initial begin
 
  pat_error=0;

  reset=1'b1;clk=1'b1;inputA=0;inputB=0;instruction=0;
  #2 reset=1'b0;                            // system reset
  #2 reset=1'b1;
  if (test_all_ins==1'b0)
  begin
  
    case(test_instruction)
      3'b000:
      begin
        // test for instruction: Add
        $display("\n****************************** Test for Instruction=000 ****************************\n");
        instruction=3'b000;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          true_out=i+j;
          #8;
      	  CHECK;
        end
        $display("\n************************************************************************************\n");
      end

      3'b001:
      begin
        // test for instruction: Sub
        $display("\n****************************** Test for Instruction=001 ****************************\n");
        instruction=3'b001;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          true_out=j-i;
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end

      3'b010:
      begin
        // test for instruction: Multiple
        $display("\n****************************** Test for Instruction=010 ****************************\n");
        instruction=3'b010;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          true_out=j*i;
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end
      
      3'b011:
      begin
        // test for instruction: AND
        $display("\n****************************** Test for Instruction=011 ****************************\n");
        instruction=3'b011;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          // true_out=(i&j)&32'h000000ff;
          true_out=(i&j);
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end


      3'b100:
      begin
        // test for instruction: XOR
        $display("\n****************************** Test for Instruction=100 ****************************\n");
        instruction=3'b100;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          // true_out=(i^j)&32'h000000ff;
          true_out=(i^j);
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end


      3'b101:
      begin
        // test for instruction: Abs
        $display("\n****************************** Test for Instruction=101 ****************************\n");
        instruction=3'b101;
        for(t=0;t<test_times;t=t+1)
        begin
          j=$random()%128;
          inputA=j[7:0];
          // true_out=(j<0) ? (~j+1)&32'h000000ff : (j)&32'h000000ff;
          true_out=(j<0) ? (~j+1) : (j);
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end

      3'b110:
      begin
        // test for instruction: Add/2
        $display("\n****************************** Test for Instruction=110 ****************************\n");
        instruction=3'b110;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          true_out=(i+j) >>> 1;
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end

      3'b111:
      begin
        // test for instruction: Max
        $display("\n****************************** Test for Instruction=111 ****************************\n");
        instruction=3'b111;
        for(t=0;t<test_times;t=t+1)
        begin
          i=$random()%128; j=$random()%128;
          inputA=i[7:0]; inputB=j[7:0];
          true_out=(i > j)? i : j;
          #8;
          CHECK;
        end
        $display("\n************************************************************************************\n");
      end

    endcase
  end
  else
  begin

    // test for instruction: Add
    $display("\n****************************** Test for Instruction=000 ****************************\n");
    instruction=3'b000;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        true_out=i+j;
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");


    // test for instruction: Sub
    $display("\n****************************** Test for Instruction=001 ****************************\n");
    instruction=3'b001;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        true_out=j-i;
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");



    // test for instruction: Multiple
    $display("\n****************************** Test for Instruction=010 ****************************\n");
    instruction=3'b010;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        true_out=j*i;
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");

    

    // test for instruction: AND
    $display("\n****************************** Test for Instruction=011 ****************************\n");
    instruction=3'b011;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        // true_out=(i&j)&32'h000000ff;
        true_out=(i&j);
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");



    // test for instruction: XOR
    $display("\n****************************** Test for Instruction=100 ****************************\n");
    instruction=3'b100;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        // true_out=(i^j)&32'h000000ff;
        true_out=(i^j);
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");


    // test for instruction: Abs
    $display("\n****************************** Test for Instruction=101 ****************************\n");
    instruction=3'b101;
    for(t=0;t<test_times;t=t+1)
    begin
        j=$random()%128;
        inputA=j[7:0];
        // true_out=(j<0) ? (~j+1)&32'h000000ff : (j)&32'h000000ff;
        true_out=(j<0) ? (~j+1) : (j);
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");


    // test for instruction: Add/2
    $display("\n****************************** Test for Instruction=110 ****************************\n");
    instruction=3'b110;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        true_out=(i+j) >>> 1;
        #8;
        CHECK;
    end
    $display("\n************************************************************************************\n");

    // test for instruction: Max
    $display("\n****************************** Test for Instruction=111 ****************************\n");
    instruction=3'b111;
    for(t=0;t<test_times;t=t+1)
    begin
        i=$random()%128; j=$random()%128;
        inputA=i[7:0]; inputB=j[7:0];
        true_out=(i > j)? i : j;
        #8;
        CHECK;
    end

    $display("\n************************************************************************************\n");
  end
   
   
  if(!pat_error) begin
    $display("\n==================================================\n");
    $display(" Congratulations!! Your Verilog Code is correct!!\n");
    $display("==================================================\n");
  end
  else begin
    $display("\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
    $display("   Your Verilog Code has %d errors. \n",pat_error);
    $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
  end
  #10 $finish;
  
end

endmodule
