class uvm_ms_scenario_virtual_sequence  extends uvm_sequence;
  `uvm_object_utils(uvm_ms_scenario_virtual_sequence)

  ms_scenario_barrier phase_barriers[string];

  function new (string name = "uvm_ms_scenario_virtual_sequence");
    super.new(name);
  endfunction

  // convert2string Implementation:
  function string convert2string();
    string prefix;
     $sformat(prefix, "%s MS Scenario:\n", prefix);
  endfunction

    // do_print Implementation:
  function void do_print(uvm_printer printer);
    if(printer.knobs.sprint == 0) begin
      $display(convert2string());
    end
    else begin
      printer.m_string = convert2string();
    end 
  endfunction: do_print
  
  function add_barrier (string name = "", string scn_name , int seq_num, bit releaser = 0);
    if(phase_barriers.exists(name)) begin
     // `uvm_info(get_name,$psprintf("add to barrier %0s , Scenario %0s", name, scn_name), UVM_MEDIUM)
      phase_barriers[name].add_barrier(scn_name, seq_num, releaser,1);
    end else begin
      // `uvm_info(get_name,$psprintf("add new barrier %0s , Scenario %0s", name, scn_name), UVM_MEDIUM)
      phase_barriers[name] = new(name, 1);
      phase_barriers[name].add_barrier(scn_name, seq_num, releaser,0);
    end
  endfunction
  
// The body task is responsible on running several sequence in parallel and handle , process synchronization

  // virtual task automatic start_seq(uvm_scenario_sequence_base seq);
  // endtask



endclass : uvm_ms_scenario_virtual_sequence

