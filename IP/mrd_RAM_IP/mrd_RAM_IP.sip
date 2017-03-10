set_global_assignment -entity "mrd_RAM_IP" -library "lib_mrd_RAM_IP" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "mrd_RAM_IP" -library "lib_mrd_RAM_IP" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "mrd_RAM_IP" -library "lib_mrd_RAM_IP" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_mrd_RAM_IP" -name SPD_FILE [file join $::quartus(sip_path) "mrd_RAM_IP.spd"]
set_global_assignment -library "lib_mrd_RAM_IP" -name MISC_FILE [file join $::quartus(sip_path) "../mrd_RAM_IP.qsys"]

set_global_assignment -library "lib_mrd_RAM_IP" -name MISC_FILE [file join $::quartus(sip_path) "sim/mrd_RAM_IP.v"]
set_global_assignment -library "lib_mrd_RAM_IP" -name MISC_FILE [file join $::quartus(sip_path) "ram_2port_151/sim/mrd_RAM_IP_ram_2port_151_hhdwfsy.v"]
