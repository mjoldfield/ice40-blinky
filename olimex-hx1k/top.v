/*
 * Top module for Olimex iCE40HX1K-EVB blinky
 * 
 * Bounce LEDs
 * 
 * Generate test signal: 6.25MHz
 */

module top(input CLK
	   , output LED1
	   , output LED2
	   , output TSTA
	   );

   // No PLL, so use 100MHz external clock
   wire sysclk;
   assign sysclk = CLK;
   
   // We want to do a 2-cycle pattern in 1s, i.e. tick at
   // 2Hz. log_2 (100M / 2) = 25.6. so use a 26-bit counter
   localparam ANIM_PERIOD    = 100000000 / 2;
   localparam SYS_CNTR_WIDTH = 26;

   reg [SYS_CNTR_WIDTH-1:0] syscounter;
   reg 			    led_strobe;
   
   always @(posedge sysclk)
     if (syscounter < ANIM_PERIOD-1)
       begin
	  syscounter <= syscounter + 1;
	  led_strobe <= 0;
       end
     else
       begin
	  syscounter <= 0;
	  led_strobe <= 1;
       end

   reg 		    ledState;
   always @(posedge sysclk)
     if (led_strobe)
       ledState <= !ledState;
   
   assign LED1 =  ledState;
   assign LED2 = !ledState;

   // test signal: 100MHz / 2^4 = 6.25MHz
   assign TSTA = syscounter[3];

endmodule		 
   
  
