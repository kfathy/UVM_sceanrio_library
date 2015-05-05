class uvm_scenario_sequence_base #(type P = uvm_sequence_item) extends uvm_sequence #(P);
  `uvm_object_param_utils(uvm_scenario_sequence_base #(P))
  
  ms_scenario_barrier seq_barriers[$];
  
  int max_length = 0;
  int next_scenario_kind = 0;
  string scenario_names[int];

  scenario_e curr_state;

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

  virtual function string convert2string();
    string prefix;
     $sformat(prefix, "%s Scenario: %0s, of length: %0d\n", prefix, get_scenario_name(scenario_kind), this.length);
    return prefix;
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
  
   virtual task apply (uvm_sequencer_base sequencer = null, uvm_sequence_base parent = null);
  endtask
endclass : uvm_scenario_sequence_base

`define uvm_scenario_gen(class_name, text) \
typedef uvm_scenario_sequence_base#(class_name) class_name``_scenario; \
`uvm_scenario_gen_using(class_name, text)

`define uvm_scenario_gen_using(class_name, text) \
\
class class_name``_scenario_sequence extends uvm_scenario_sequence_base #(class_name); \
  `uvm_object_utils(class_name``_scenario_sequence) \
\
  rand class_name items[]; \
  class_name item; \
  \
\
  function new (string name = "");\
    super.new(name);\
  endfunction \
  \
  function void fill_scenario(class_name using = null); \
    int i ;\
\
    if (this.items.size() < this.get_max_length()) begin \
      this.items = new [this.get_max_length()] (this.items);\
    end \
    foreach (this.items[i]) begin \
     if (this.items[i] != null) continue;\
\
     if (using == null) this.items[i] = new; \
     else $cast(this.items[i], using.clone());\
\
     // this.items[i].stream_id   = this.stream_id; \
     // this.items[i].scenario_id = this.scenario_id; \
     // this.items[i].data_id     = i; \
    end \
  endfunction: fill_scenario \
\
  function void pre_randomize(); \
//      this.fill_scenario(this.using);\
     this.fill_scenario();\
  endfunction: pre_randomize\
  \
  // convert2string Implementation: \
  virtual function string convert2string(); \
    string prefix; \
\
     $sformat(prefix, "%s %0s\n", prefix, super.convert2string); \
    for(int i = 0; i < this.length; i++) begin \
      if (this.items[i] == null) continue; \
        $sformat(prefix, "%s  Item[%0d]: %0s\n", prefix, i, this.items[i].convert2string); \
      end \
      // if (this.using != null) begin \
        // psdisplay = {psdisplay, "\n", this.using.psdisplay({prefix, "  Using: "})}; \
    // end \
    return prefix; \
  endfunction \
\
  virtual task body(); \
\
  endtask : body \
  \
  virtual task apply (uvm_sequencer_base sequencer = null, uvm_sequence_base parent = null);\
    for(int i = 0; i < this.length; i++) begin \
      $cast(item, this.items[i].clone()); \
      item_count = i;\
      this.start(sequencer, parent); \
    end \
  endtask \
endclass
