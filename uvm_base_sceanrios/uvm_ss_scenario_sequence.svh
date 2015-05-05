virtual class uvm_ss_scenario_sequence #(type SCN_ITEM = uvm_sequence_item) extends uvm_sequence #(SCN_ITEM);
  `uvm_object_param_utils(uvm_ss_scenario_sequence #(SCN_ITEM))
  
  ms_scenario_barrier seq_barriers[$];
  rand SCN_ITEM items[]; 
  SCN_ITEM item; 
  
  int max_length = 0;
  int next_scenario_kind = 0;
  string scenario_names[int];

  // scenario_e curr_state;

  rand int length;
  rand int scenario_kind;
  rand int repeated = 0;

  int   item_count;
  
  function new (string name = "uvm_scenario_sequence_base");
    super.new(name);
  endfunction

  constraint uvm_scenario_valid {

    scenario_kind >= 0;
    scenario_kind < ((next_scenario_kind == 0) ? 1 : next_scenario_kind);

    length >=0 ;
    length <= max_length ;

    repeated >=0 ;

    solve scenario_kind before length;
  }

  constraint repetition {
    repeated == 0;
  }

    function void fill_scenario(SCN_ITEM using = null); 
    int i ;

    if (this.items.size() < this.get_max_length()) begin 
      this.items = new [this.get_max_length()] (this.items);
    end 

    foreach (this.items[i]) begin 
     if (this.items[i] != null) continue;
     if (using == null) 
	   this.items[i] = SCN_ITEM::type_id::create($psprintf("%0s.Item[%0d]",get_name, i)); 
     else $cast(this.items[i], using.clone());
    end 
  endfunction: fill_scenario 
  
  function void pre_randomize(); 
   this.fill_scenario();
  endfunction: pre_randomize
  
  function int define_scenario(string name, int unsigned max_len = 0);

    define_scenario = this.next_scenario_kind++;
    this.scenario_names[define_scenario] = name;
    if(max_len > this.max_length) this.max_length = max_len;

  endfunction: define_scenario

  function string get_scenario_name (int unsigned scen_kind = 0);
    if (!this.scenario_names.exists(scen_kind)) begin
      `uvm_error(get_name, $psprintf("Cannot find scenario name: undefined scenario kind %0d",scen_kind))
       return ("");
    end else
      return (this.scenario_names[scen_kind]);
  endfunction

  virtual function int unsigned get_max_length();
    return this.max_length;
  endfunction: get_max_length

  // do_print Implementation:
  function void do_print(uvm_printer printer);
    if(printer.knobs.sprint == 0) begin
      $display(convert2string());
    end
    else begin
      printer.m_string = convert2string();
    end
  endfunction: do_print
  
  virtual function string convert2string(); 
	string prefix; 

	 $sformat(prefix, "%s Scenario: %0s, of length: %0dn", prefix, get_scenario_name(scenario_kind), this.length);
	for(int i = 0; i < this.length; i++) begin 
	  if (this.items[i] == null) continue; 
		$sformat(prefix, "%s  Item[%0d]: %0sn", prefix, i, this.items[i].convert2string); 
	  end 
	return prefix; 
  endfunction 
  
  virtual function add_seq_barrier(ms_scenario_barrier seq_barrier);
    seq_barriers.push_back(seq_barrier);
    `uvm_info(get_name,$psprintf("added barrier %0s , threshold = %0d", seq_barrier.get_name, seq_barrier.get_threshold), UVM_MEDIUM)
  endfunction
  
  virtual task pre_body();
    foreach(seq_barriers[n]) begin
      if(seq_barriers[n].is_catcher(get_name, item_count)) begin
        `uvm_info("pre_body", "pre wait for", UVM_MEDIUM);
        seq_barriers[n].wait_for();
        `uvm_info("pre_body", "post wait for", UVM_MEDIUM);
      end
    end
  endtask

  virtual task post_body();
    foreach(seq_barriers[n]) begin
        if(seq_barriers[n].is_releaser(get_name,item_count)) begin
          `uvm_info("post_body", "pre wait for", UVM_MEDIUM);
          seq_barriers[n].wait_for();
          `uvm_info("post_body", "post wait for", UVM_MEDIUM);
        end
      end
  endtask
  
  virtual task apply (uvm_sequencer_base sequencer = null, uvm_sequence_base parent = null, int this_priority	 = 	-1, bit call_pre_post	 = 	1);
    for(int i = 0; i < this.length; i++) begin 
      $cast(item, this.items[i].clone()); 
      item_count = i;
      this.start(sequencer, parent, this_priority, call_pre_post); 
    end 
  endtask 
  
endclass : uvm_ss_scenario_sequence

