cd /home/runner
export PATH=/usr/local/bin:/usr/bin:/bin:/tool/pandora64/bin:/usr/share/questa/questasim//linux_x86_64::/usr/share/precision/Mgc_home/bin
export CPLUS_INCLUDE_PATH=/usr/share/questa/questasim//interfaces/include
export SALT_LICENSE_SERVER=1717@10.116.0.5
export EDATOOL=questa
export QUESTA_HOME=/usr/share/questa/questasim/
export PRECISION_HOME=/usr/share/precision/Mgc_home
export HOME=/home/runner
export UVM_HOME=/playground_lib/uvm-1.1d
qrun -batch -access=rw+/. -uvmhome uvm-1.1d '-timescale' '1ns/1ns' -mfcu design.sv testbench.sv '-voptargs=+acc=npr'  -do  " run -all; exit"  ; echo 'Creating result.zip...' && zip -r /tmp/tmp_zip_file_123play.zip . && mv /tmp/tmp_zip_file_123play.zip result.zip