set_location_assignment PIN_W15  -to LED0
set_location_assignment PIN_AA24 -to LED1
set_location_assignment PIN_V16  -to LED2
set_location_assignment PIN_V15  -to LED3
set_location_assignment PIN_AF26 -to LED4
set_location_assignment PIN_AE26 -to LED5
set_location_assignment PIN_Y16  -to LED6
set_location_assignment PIN_AA23 -to LED7

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED*

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to vga_*
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to vga_*

#============================================================
# VGA
#============================================================

set_location_assignment PIN_AE19 -to vga_hs
set_location_assignment PIN_AE17 -to vga_vs
set_location_assignment PIN_AG28 -to vga_r[5]
set_location_assignment PIN_AA15 -to vga_r[4]
set_location_assignment PIN_Y15  -to vga_r[3]
set_location_assignment PIN_AC24 -to vga_r[2]
set_location_assignment PIN_AD26 -to vga_r[1]
set_location_assignment PIN_AF28 -to vga_r[0]
set_location_assignment PIN_AF21 -to vga_g[5]
set_location_assignment PIN_AE22 -to vga_g[4]
set_location_assignment PIN_AA20 -to vga_g[3]
set_location_assignment PIN_AG21 -to vga_g[2]
set_location_assignment PIN_AH22 -to vga_g[1]
set_location_assignment PIN_AF23 -to vga_g[0]
set_location_assignment PIN_AG20 -to vga_b[5]
set_location_assignment PIN_AF22 -to vga_b[4]
set_location_assignment PIN_AH23 -to vga_b[3]
set_location_assignment PIN_AH21 -to vga_b[2]
set_location_assignment PIN_AG24 -to vga_b[1]
set_location_assignment PIN_AG23 -to vga_b[0]

#============================================================
# SDRAM
#============================================================

set_location_assignment PIN_Y11 -to SDRAM_A[0]
set_location_assignment PIN_AA26 -to SDRAM_A[1]
set_location_assignment PIN_AA13 -to SDRAM_A[2]
set_location_assignment PIN_AA11 -to SDRAM_A[3]
set_location_assignment PIN_W11 -to SDRAM_A[4]
set_location_assignment PIN_Y19 -to SDRAM_A[5]
set_location_assignment PIN_AB23 -to SDRAM_A[6]
set_location_assignment PIN_AC23 -to SDRAM_A[7]
set_location_assignment PIN_AC22 -to SDRAM_A[8]
set_location_assignment PIN_C12 -to SDRAM_A[9]
set_location_assignment PIN_AB26 -to SDRAM_A[10]
set_location_assignment PIN_AD17 -to SDRAM_A[11]
set_location_assignment PIN_D12 -to SDRAM_A[12]
set_location_assignment PIN_Y17 -to SDRAM_BA[0]
set_location_assignment PIN_AB25 -to SDRAM_BA[1]
set_location_assignment PIN_E8 -to SDRAM_DQ[0]
set_location_assignment PIN_V12 -to SDRAM_DQ[1]
set_location_assignment PIN_D11 -to SDRAM_DQ[2]
set_location_assignment PIN_W12 -to SDRAM_DQ[3]
set_location_assignment PIN_AH13 -to SDRAM_DQ[4]
set_location_assignment PIN_D8 -to SDRAM_DQ[5]
set_location_assignment PIN_AH14 -to SDRAM_DQ[6]
set_location_assignment PIN_AF7 -to SDRAM_DQ[7]
set_location_assignment PIN_AE24 -to SDRAM_DQ[8]
set_location_assignment PIN_AD23 -to SDRAM_DQ[9]
set_location_assignment PIN_AE6 -to SDRAM_DQ[10]
set_location_assignment PIN_AE23 -to SDRAM_DQ[11]
set_location_assignment PIN_AG14 -to SDRAM_DQ[12]
set_location_assignment PIN_AD5 -to SDRAM_DQ[13]
set_location_assignment PIN_AF4 -to SDRAM_DQ[14]
set_location_assignment PIN_AH3 -to SDRAM_DQ[15]
set_location_assignment PIN_AG13 -to SDRAM_DQML
set_location_assignment PIN_AF13 -to SDRAM_DQMH
set_location_assignment PIN_AD20 -to SDRAM_CLK
set_location_assignment PIN_AG10 -to SDRAM_CKE
set_location_assignment PIN_AA19 -to SDRAM_nWE
set_location_assignment PIN_AA18 -to SDRAM_nCAS
set_location_assignment PIN_Y18 -to SDRAM_nCS
set_location_assignment PIN_W14 -to SDRAM_nRAS

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_*
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to SDRAM_*
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_*
set_instance_assignment -name FAST_OUTPUT_ENABLE_REGISTER ON -to SDRAM_DQ[*]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to SDRAM_DQ[*]
set_instance_assignment -name ALLOW_SYNCH_CTRL_USAGE OFF -to *|SDRAM_*

