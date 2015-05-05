class ms_scenario_barrier extends uvm_barrier;

  int     seq_num         [string];
  int     releaser        [string];
  int     catcher         [string];
  string  scn_name_q      [string];

  function new (string name = "", int threshold = 0);
    super.new(name, threshold);
  endfunction

  virtual function bit is_releaser (string scn_name, int scn_num);
    // `uvm_info(get_name, $psprintf("is releaser %0s, %0d, releaser = %0d", scn_name, scn_num, releaser[scn_name] ), UVM_MEDIUM)
    if(!scn_name_q.exists(scn_name))
      return 0;
    foreach(releaser[n])
      if(n == scn_name)
        if(releaser[n] == scn_num)
          return  1'b1;
    return  1'b0;
  endfunction
  
  virtual function bit is_catcher (string scn_name, int scn_num);
    // `uvm_info(get_name, $psprintf("is catcher %0s, %0d, catcher = %0d", scn_name, scn_num,catcher[scn_name] ), UVM_MEDIUM)
    if(!scn_name_q.exists(scn_name))
      return 0;
    foreach(catcher[n])
      if(n == scn_name)
        if(catcher[n] == scn_num)
          return  1'b1;
      return  1'b0;
  endfunction
  
  virtual function add_barrier  (string scn_name = "", int step, bit releaser = 0, int increment = 1);
    scn_name_q[scn_name] = scn_name;
    seq_num[scn_name] = step;
    if(increment) set_threshold(get_threshold() +1);
    if(releaser)
      this.releaser[scn_name] = step;
    else
      catcher[scn_name] = step;
	  
  endfunction

endclass