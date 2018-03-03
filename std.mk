TARGET_STEM = blink

PINS_FILE = pins.pcf

YOSYS_LOG  = synth.log
YOSYS_ARGS = -v3 -l $(YOSYS_LOG)

VERILOG_SRCS = $(wildcard *.v)

BIN_FILE  = $(TARGET_STEM).bin
ASC_FILE  = $(TARGET_STEM).asc
BLIF_FILE = $(TARGET_STEM).blif

all:	$(BIN_FILE)

$(BIN_FILE):	$(ASC_FILE)
	icepack	$< $@

$(ASC_FILE):	$(BLIF_FILE) $(PINS_FILE)
	arachne-pnr -d $(ARACHNE_DEVICE) -P $(PACKAGE) -o $(ASC_FILE) -p $(PINS_FILE) $<

$(BLIF_FILE):	$(VERILOG_SRCS)
	yosys $(YOSYS_ARGS) -p "synth_ice40 -blif $(BLIF_FILE)" $(VERILOG_SRCS)

prog:	$(BIN_FILE)
	$(PROG_BIN) $<

timings:$(ASC_FILE)
	icetime -tmd $(ICETIME_DEVICE) $<

clean:
	rm -f $(BIN_FILE) $(ASC_FILE) $(BLIF_FILE) $(YOSYS_LOG)

.PHONY:	all clean prog timings


