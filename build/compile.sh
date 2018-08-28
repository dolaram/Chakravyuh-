INC_DIRS=src/
ncverilog -C src/control_unit/cu.v +incdir+$INCDIRS
ncverilog -C src/memory/memory.v +incdir+$INCDIRS
#ncverilog -C test_cu.v
