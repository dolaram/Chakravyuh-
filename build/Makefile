PARENT_DIR=$(shell pwd)/../
INC_DIRS=${PARENT_DIR}/src/

all:test

cu:
	ncverilog -C $(PARENT_DIR)/src/control_unit/cu.v +incdir+${INC_DIRS}

memory:
	ncverilog -C $(PARENT_DIR)/src/memory/memory.v +incdir+${INC_DIRS}

vedic:
	ncverilog -C $(PARENT_DIR)/src/vedic/vedic8.v

emul:
	ncverilog -C $(PARENT_DIR)/src/rsa/emul.v
	ncverilog -C $(PARENT_DIR)/src/rsa/emul_sql_behavioral.v
	ncverilog -C $(PARENT_DIR)/src/rsa/emul_sql_structural.v

modn:
	ncverilog -C $(PARENT_DIR)/src/rsa/modn.v

rsa: modn emul
	ncverilog -C $(PARENT_DIR)/src/rsa/rsa_behavioral.v
	ncverilog -C $(PARENT_DIR)/src/rsa/rsa_structural.v

rng:
	ncverilog -C $(PARENT_DIR)/src/rng/rng.v +incdir+${INC_DIRS}

fullsystem: memory rsa cu
	ncverilog -C $(PARENT_DIR)/src/fullsystem.v +incdir+${INC_DIRS}	

test: fullsystem
	ncverilog -C $(PARENT_DIR)/src/test.v +incdir+${INC_DIRS}

test_vedic: vedic
	ncverilog -C $(PARENT_DIR)/src/vedic/vedic8_t.v

test_emul_sql: emul
	ncverilog -C $(PARENT_DIR)/src/rsa/test_emul_sql.v

test_modn:
	ncverilog -C $(PARENT_DIR)/src/rsa/test_modn.v

test_rsa:rsa
	ncverilog -C $(PARENT_DIR)/src/rsa/test_rsa.v

simul:
	make -C $(PARENT_DIR)/simulation/ all
	make -C $(PARENT_DIR)/simulation/ simul

test_rng:rng
	ncverilog -C $(PARENT_DIR)/src/rng/test.v +incdir+${INC_DIRS}

clean:
	rm -rf INCA_libs *.log ncsim.key memory.list nclaunch.key
	make -C $(PARENT_DIR)/simulation/ clean
