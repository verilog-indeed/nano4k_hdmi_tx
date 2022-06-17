module num_of_ones(input wire[7:0] onesFrom,
                   output wire[3:0] result);
    wire [3:0] nibbleSum1;
    wire [3:0] nibbleSum2;

    assign nibbleSum1 = onesFrom[3] + onesFrom[2] + 
                         onesFrom[1] + onesFrom[0];
    assign nibbleSum2 = onesFrom[7] + onesFrom[6] + 
                         onesFrom[5] + onesFrom[4];
    
    assign result = nibbleSum1 + nibbleSum2;
endmodule