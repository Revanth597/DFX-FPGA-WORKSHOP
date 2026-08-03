# ============================================================
# DFX Constraints - Reconfigurable Partition RP
# ============================================================

create_pblock pblock_RP_1

add_cells_to_pblock [get_pblocks pblock_RP_1] \
    [get_cells -hierarchical -filter {NAME == "RP"}]

resize_pblock [get_pblocks pblock_RP_1] -add {
    SLICE_X62Y110:SLICE_X103Y139
    DSP48_X3Y44:DSP48_X4Y55
    RAMB18_X4Y44:RAMB18_X4Y55
    RAMB36_X4Y22:RAMB36_X4Y27
}

# Do NOT require frame alignment
set_property RESET_AFTER_RECONFIG false [get_pblocks pblock_RP_1]

# Keep RP routing within the RP region
set_property CONTAIN_ROUTING true [get_pblocks pblock_RP_1]