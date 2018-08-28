all:
	ncverilog -C *.v

clean:
	rm -rf hal* hdl* irun* memory.list nc* INCA* waves* cds*

simul:
	irun -s +gui +linedebug +access+rwc -q test.v
