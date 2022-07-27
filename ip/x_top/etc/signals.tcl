set sigs [list]

lappend sigs "i_clk"
lappend sigs "i_nrst"
lappend sigs "i_rx" 
lappend sigs "o_tx" 

set added [ gtkwave::addSignalsFromList $sigs ]
gtkwave::/Time/Zoom/Zoom_Full
