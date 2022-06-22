set sigs [list]

lappend sigs "i_clk"
lappend sigs "i_nrst"
lappend sigs "i_data" 
lappend sigs "i_accept" 
lappend sigs "o_valid" 
lappend sigs "o_rnw"
lappend sigs "o_addr"
lappend sigs "o_data"
lappend sigs "rs1"
lappend sigs "rs2"
lappend sigs "rd"
lappend sigs "sm_q"
lappend sigs "alu_sel"
lappend sigs "pc_q"

set added [ gtkwave::addSignalsFromList $sigs ]
gtkwave::/Time/Zoom/Zoom_Full
