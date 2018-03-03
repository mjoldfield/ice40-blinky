/*
 * Top module for HX8K breakout blinky
 * 
 * Sweep light along LED array
 * 
 * Generate test signals at 6.0MHz and 1Hz.
 */

module top(input CLK
	   , output LED0
	   , output LED1
	   , output LED2
	   , output LED3
	   , output LED4
	   , output LED5
	   , output LED6
	   , output LED7
	   , output TSTA
	   , output TSTB
	   );

   // PLL to get 96MHz clock
   wire       sysclk;
   wire       locked;
   pll myPLL (.clock_in(CLK), .global_clock(sysclk), .locked(locked));

   // We want to do a 16-cycle pattern in 1s, i.e. tick at
   // 16Hz. log_2 (96M / 16) = 22.516.. so use a 23-bit counter
   localparam ANIM_PERIOD    = 96000000 / 16;
   localparam SYS_CNTR_WIDTH = 23;

   reg [SYS_CNTR_WIDTH-1:0] syscounter;
   reg 			    anim_stb;
   
   always @(posedge sysclk)
     if (locked && syscounter < ANIM_PERIOD-1)
       begin
	  syscounter <= syscounter + 1;
	  anim_stb   <= 0;
       end
     else
       begin
	  syscounter <= 0;
	  anim_stb   <= 1;
       end
		     
   // animation phase: 4-bits so 16 cycles
   reg [3:0]  anim_phase;

   // a register holding LED state.
   reg [7:0]  leds;

   always @(posedge sysclk)
     if (!locked)
       anim_phase <= 0;
     else if (anim_stb)
       begin
	  anim_phase <= anim_phase + 1;
	  
	  case (anim_phase)
	    4'b0000: leds <= 8'b00000001;
	    4'b1000: leds <= 8'b10000000;
	    default:
	      if (anim_phase[3])
		leds <= leds >> 1;
	      else
		leds <= leds << 1;
	  endcase
       end // if (anim_stb)

   assign { LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7 } = leds;
         
   // test signals on counter
   assign TSTA = syscounter[3];                // 96MHz / 2^4  = 6MHz
   assign TSTB = anim_phase == 0;              // 1Hz
   
endmodule		 

   
  
