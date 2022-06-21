`timescale 1 ns/10 ps // time-unit = 1 ns, precision = 10 ps

module encoder_serializer_tb;
	reg clock;
	reg[7:0] colorByte;
	reg[1:0] C_bus;
	reg display_active;
	wire hdmiOUT;
	
	always #185 clock <= ~clock; //approx 270MHz clock
	encoder_serializer DUT (
							.pixelComponent(colorByte),
							.controlBus(C_bus),
							.DE(display_active),
							.serialClk(clock),
							.tmdsSerialOut(hdmiOUT)
							);
	initial begin
		$dumpfile("sim_result.vcd");
		$dumpvars(0, encoder_serializer_tb);
		$dumpon;
		//$monitor("Time=%0t | TMDS Serial Output=%10b | Clock=%1b", $time, tmdsOUT, clock);
		#0 colorByte = 8'h55;
		#0 C_bus = 2'b0;
		#0 display_active = 0;
		#0 clock = 0;
		#4000 display_active = 1;
		#47000 $finish;
	end
endmodule