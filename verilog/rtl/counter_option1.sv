`line 2 "counter_option1.tlv" 0 //_\TLV_version 1d: tl-x.org, generated by SandPiper(TM) 1.12-2022/01/27-beta
`include "sp_default.vh" //_\SV
                               
   
   module counter_option1 #(
    parameter BITS = 32
   )(
   `ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
   `endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
    );
   
   logic clk;

`include "counter_option1_gen.sv" //_\TLV
   // WB MI A
   assign L0_valid_a0 = wbs_cyc_i && wbs_stb_i; 
   assign L0_wstrb_a0[3:0] = wbs_sel_i & {4{wbs_we_i}};
   assign wbs_dat_o = L0_rdata_a0[31:0];
   assign wbs_ack_o = L0_ready_a0;
   assign L0_wdata_a0[31:0] = wbs_dat_i;

    // IO
   assign io_out = L0_count_a1;
   assign io_oeb = {(`MPRJ_IO_PADS-1){L0_rst_a0}};

    // IRQ
   assign irq = '0;// Unused

    // LA
   assign la_data_out = {{(127-BITS){1'b0}}, L0_count_a1};
    // Assuming LA probes [63:32] are for controlling the count register  
   assign L0_la_write_a0[31:0] = ~la_oenb[63:32] & ~{BITS{L0_valid_a0}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
   assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
   assign L0_rst_a0 = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

   assign L0_count_a0[BITS-1:0] = L0_rst_a0 ? '0 :
                      (L0_valid_a0 && !L0_ready_a1) ? {{L0_wstrb_a0[3] ? L0_wdata_a0[31:24] : L0_count_a1[31:24]},
                                             {L0_wstrb_a0[2] ? L0_wdata_a0[23:16] : L0_count_a1[23:16]},
                                             {L0_wstrb_a0[1] ? L0_wdata_a0[15: 8] : L0_count_a1[15: 8]},
                                             {L0_wstrb_a0[0] ? L0_wdata_a0[7 : 0] : L0_count_a1[ 7: 0]}}:
                      ~|L0_la_write_a0 ? L0_count_a1+1:
                      |L0_la_write_a0 ? L0_la_write_a0 & la_data_in[63:32]:
                      L0_count_a1;
                      
   assign L0_ready_a0 = L0_valid_a0 && !L0_ready_a1;
   assign L0_rdata_a0[31:0] = (L0_valid_a0 && !L0_ready_a1) ? L0_count_a1 : '0; endgenerate
  
//_\SV
   endmodule
