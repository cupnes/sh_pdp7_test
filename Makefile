SAMPLES = 01_test340.simh 02_square.simh 03_konnichiha_sekai.simh
TYPE340_START_ADDR = 1000

all: $(SAMPLES)

%.simh: %.340simh
	cat $< type340/load_infexec_set_param_and_run.simh >$@

%.340simh: %.340ml
	tools/ml2simh $< $@ $(TYPE340_START_ADDR)

%.340ml: %.csv
	tools/ld2ml $< $@

%.340ml: %.sh
	./$< >$@

clean:
	rm -f *.340simh *.340ml *.simh

.PHONY: clean
