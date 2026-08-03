## ============================================================
## Basys 3
## DFX Reconfigurable Signal Generator
## ============================================================


## ------------------------------------------------------------
## 100 MHz Clock
## ------------------------------------------------------------

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]


## ------------------------------------------------------------
## Reset - Center Button BTNC
## ------------------------------------------------------------

set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]


## ------------------------------------------------------------
## LED0 - wave_out[0]
## ------------------------------------------------------------

set_property PACKAGE_PIN U16 [get_ports {wave_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[0]}]


## LED1

set_property PACKAGE_PIN E19 [get_ports {wave_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[1]}]


## LED2

set_property PACKAGE_PIN U19 [get_ports {wave_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[2]}]


## LED3

set_property PACKAGE_PIN V19 [get_ports {wave_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[3]}]


## LED4

set_property PACKAGE_PIN W18 [get_ports {wave_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[4]}]


## LED5

set_property PACKAGE_PIN U15 [get_ports {wave_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[5]}]


## LED6

set_property PACKAGE_PIN U14 [get_ports {wave_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[6]}]


## LED7

set_property PACKAGE_PIN V14 [get_ports {wave_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wave_out[7]}]

create_pblock pblock_RP
add_cells_to_pblock [get_pblocks pblock_RP] [get_cells -quiet [list RP]]
resize_pblock [get_pblocks pblock_RP] -add {SLICE_X4Y110:SLICE_X29Y144 \
                                            DSP48_X0Y44:DSP48_X0Y57 \
                                            RAMB18_X0Y44:RAMB18_X0Y57 \
                                            RAMB36_X0Y22:RAMB36_X0Y28 \
}
