this text is ignored
http://www.asic-world.com/code/specman_examples/mem_op_monitor.e
<'
struct mem_op_monitor {
  mem_object : mem_base_object;
  mem_scoreboard : mem_scoreboard;
  -- event clk is fall('memory_tb.clk') @sim;

  output_monitor()@clk is {
    while (TRUE) {
    /*
      wait cycle;
      if (('memory_tb.chip_en' == 1) && ('memory_tb.read_write' == 0)) {
    */
         outf("Output_monitor : Detected memory read access-> Address : %x   Data : %x\n", 'memory_tb.address','memory_tb.data_out');
	// mem_object.addr = 'memory_tb.address';
	 mem_object.data = 'memory_tb.data_out';  -- more comment
         mem_scoreboard.post_output(mem_object);
      };
    };
  };
};
'>
more text that should
be ignored
<'
 a = 5 // this is more code
'>
