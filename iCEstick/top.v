/*
 * Top module for iCEstick blinky
 * 
 * Make circular pattern on red LEDs, flash green LEDs.
 * 
 * Generate test signals at 6.28MHz and 0.749Hz.
 */

module top(input CLK
	   , output LED1
	   , output LED2
	   , output LED3
	   , output LED4
	   , output LED5
	   , output TSTA
	   , output TSTB
	   );

   // PLL to get 100.5MHz clock
   wire       sysclk;
   wire       locked;
   pll myPLL (.clock_in(CLK), .global_clock(sysclk), .locked(locked));

   // 27-bit counter: 100.5MHz / 2^27 ~ 0.749Hz 
   localparam SYS_CNTR_WIDTH = 27;
   
   reg [SYS_CNTR_WIDTH-1:0] syscounter;
   always @(posedge sysclk)
     syscounter <= syscounter + 1;

   // test signals on counter
   assign TSTA = syscounter[3];                // 100.5MHz / 2^4 = 6.29MHz
   assign TSTB = syscounter[SYS_CNTR_WIDTH-1]; //                  0.749Hz
   
   // extract slowest 3-bits...
   wire [2:0]  display;
   assign display[2:0] = syscounter[SYS_CNTR_WIDTH-1:SYS_CNTR_WIDTH-3];
   
   // .. use slowest to flash green LED,
   assign LED5 = display[2];

   // .. and slightly faster ones to make a spinner
   decode_2to4 myDecoder (.a0(display[0]), .a1(display[1]),
			  .q0(LED1), .q1(LED2), .q2(LED3), .q3(LED4));
   
endmodule		 

/*
 * 2-bit to 4-line decode
 *  - positive logic i.e. q0 is high when (a0,a1) == (low,low)
 */
module decode_2to4(input a0, input a1
		   , output q0, output q1, output q2, output q3);

   assign q0 = (~a0) & (~a1);
   assign q1 = ( a0) & (~a1);
   assign q2 = (~a0) & ( a1);
   assign q3 = ( a0) & ( a1);

endmodule
   
  
