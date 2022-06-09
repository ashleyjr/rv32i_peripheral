# rv32i_peripheral

## Install Notes

- Install ``https://github.com/YosysHQ/oss-cad-suite-build`` and source ``export PATH="<extracted_location>/oss-cad-suite/bin:$PATH"``
- Create file ``/etc/udev/rules.d/53-lattice-ftdi.rules`` containing ``ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0660", GROUP="plugdev", TAG+="uaccess"`` 
