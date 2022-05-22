verilator --trace --cc ip/x_top_urt_tx/rtl/x_top_uart_tx.sv --exe ip/x_top_uart_tx/tb/x_top_uart_tx_tb.cpp 
make -C obj_dir -f Vx_top_uart_tx.mk Vx_top_uart_tx 
./obj_dir/Vx_top_uart_tx 
