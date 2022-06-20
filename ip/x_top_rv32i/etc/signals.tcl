set sigs [list]

lappend sigs "i_clk"
lappend sigs "i_nrst"
lappend sigs "i_data" 
lappend sigs "i_accept" 
lappend sigs "o_valid" 
lappend sigs "o_rnw"
lappend sigs "o_addr"
lappend sigs "o_data"

set added [ gtkwave::addSignalsFromList $sigs ]
gtkwave::/Time/Zoom/Zoom_Full
