SAMPLES = 01_test340.simh 02_square.simh 03_konnichiha_sekai.simh 04_lt.simh
TYPE340_START_ADDR = 1000
TYPE340_START_ADDR_02 = 2000

all: $(SAMPLES)

04_lt.simh: 04_lt_02.simh 04_lt_01.simh
	cat $^ >$@

04_lt_02.simh: 04_lt_02.340simh
	cat $< type340/load_infexec_02.simh >$@

%.simh: %.340simh
	cat $< type340/load_infexec_set_param_and_run.simh >$@

04_lt_02.340simh: 04_lt_02.340ml
	tools/ml2simh $< $@ $(TYPE340_START_ADDR_02)

%.340simh: %.340ml
	tools/ml2simh $< $@ $(TYPE340_START_ADDR)

%.340ml: %.csv
	tools/ld2ml $< $@

%.340ml: %.sh
	./$< >$@

clean:
	rm -f *.340simh *.340ml *.simh

.PHONY: clean
