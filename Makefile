SAMPLES = 01_test340.simh
TYPE340_START_ADDR = 1000

all: $(SAMPLES)

%.simh: %.sh
	./$< >$(basename $@)_340.ml
	tools/ml2simh.sh $(basename $@)_340.ml $(basename $@)_340.simh $(TYPE340_START_ADDR)
	cat $(basename $@)_340.simh type340/load_infexec_set_param_and_run.simh >$@
	rm $(basename $@)_340.ml $(basename $@)_340.simh

clean:
	rm -f *.ml *.simh

.PHONY: clean
