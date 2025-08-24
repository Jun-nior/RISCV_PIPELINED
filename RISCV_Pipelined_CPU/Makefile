TEST_MODULE?=CPU_Top

TOP_MODULE?=$(TEST_MODULE)_tb_top

FILE_LIST?=file.f

UVM_TEST?=base_test

UVM_VERBOSITY?=UVM_MEDIUM
NO_OF_TRANSACTIONS?=1

SEED?=1

SEEDS?=1 2 3 4 5

ifeq ($(OS),Windows_NT)
    RM_CMD = powershell if (Test-Path $(TEST_MODULE)) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $(TEST_MODULE) }
else
    RM_CMD = rm -rf $(TEST_MODULE)
endif

all: clean run_uvm

run_uvm: 
# 	mkdir $(TEST_MODULE)
	qrun -verbose -lint=default -parallel -vlog.sv \
		-vopt.access=rw+/. \
		-f $(FILE_LIST) \
		+define+NO_OF_TRANSACTIONS=$(NO_OF_TRANSACTIONS) \
		+define+UVM_NO_DEPRECATED \
		+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
		-top $(TOP_MODULE) \
		+UVM_TESTNAME=$(UVM_TEST) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		-sv_seed $(SEED) \
		-coverage +cover=bcestf \
		-cvgperinstance	\
		-sva -assertdebug \
		-outdir $(TEST_MODULE) \
		-l $(TEST_MODULE)/qrun.log \
		-designfile $(TEST_MODULE)/$(TEST_MODULE).bin \
		-qwavedb=+memory=all+cell+signal+assertion+class+wavefile=$(TEST_MODULE)/$(TEST_MODULE).db \
		-do "coverage save -onexit $(TEST_MODULE)/$(UVM_TEST)_$(SEED).ucdb; run -all; quit -f"

run_regression:
ifeq ($(OS),Windows_NT)
	@echo "=============== RUNNING REGRESSION WITH SEEDS: $(SEEDS) ==============="
	@for %%s in ($(SEEDS)) do $(MAKE) run_uvm SEED=%%s
	@echo "====================================================================="
else
	@echo "=============== RUNNING REGRESSION WITH SEEDS: $(SEEDS) ==============="
	@for seed in $(SEEDS); do \
		$(MAKE) run_uvm SEED=$$seed; \
	done
	@echo "====================================================================="
endif

merge_coverage:
	@echo ""
	@echo "=============== MERGING COVERAGE FILES ==============="
	vcover merge -out $(TEST_MODULE)/merged.ucdb $(wildcard $(TEST_MODULE)/$(UVM_TEST)_*.ucdb)
	@echo "Merged coverage database created: $(TEST_MODULE)/merged.ucdb"
	@echo "===================================================="

report_coverage: 
	@echo ""
	@echo "=============== COVERAGE SUMMARY FOR SEED $(SEED) ==============="
	vcover report -summary $(TEST_MODULE)/$(UVM_TEST)_$(SEED).ucdb
	@echo "================================================"

report_merged_coverage: 
	@echo ""
	@echo "=============== COVERAGE SUMMARY FOR MERGED ==============="
	vcover report -summary $(TEST_MODULE)/merged.ucdb
	@echo "================================================"

report_merged_html:
	@echo ""
	@echo "=============== GENERATING MERGED HTML REPORT ==============="
	vcover report -html -details -output $(TEST_MODULE)/coverage_html_merged -annotate $(TEST_MODULE)/merged.ucdb
	@echo "HTML report generated in: $(TEST_MODULE)/coverage_html_merged"
	@echo "=========================================================="

report_html: 
	@echo ""
	@echo "=============== GENERATING HTML REPORT FOR SEED $(SEED) ==============="
	vcover report -html -details -output $(TEST_MODULE)/coverage_html_${SEED} -annotate  $(TEST_MODULE)/$(UVM_TEST)_${SEED}.ucdb
	@echo "HTML report generated in: $(TEST_MODULE)/coverage_html_${SEED}"
	@echo "===================================================="

clean:
	$(RM_CMD)

run_no_uvm:	
# 	mkdir $(TEST_MODULE)
	qrun -verbose -lint=default -parallel -vlog.sv \
		-vopt.access=rw+/. \
		-f $(FILE_LIST) \
		-top $(TOP_MODULE) \
		-outdir $(TEST_MODULE) \
		-l $(TEST_MODULE)/qrun.log \
		-designfile $(TEST_MODULE)/$(TEST_MODULE).bin \
		-qwavedb=+memory=all+assertion+cell+signal+class+wavefile=$(TEST_MODULE)/$(TEST_MODULE).db

.PHONY: all clean run_uvm