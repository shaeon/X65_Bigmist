/* Copyright (c) 2023-2024 Jaroslav Sykora.
 * Terms and conditions of the MIT License apply; see the file LICENSE in top-level directory. */
/**
 * CPU Observer.
 * ISAFIX - detection of invalid instructions in 65C816 Emulation Mode.
 */
module cpu_observer 
(
    // Global signals
    input           clk,        // 48MHz
    input           resetn,     // sync reset
    input           cputype02_i,    // 1=6502, 0=65816
    // CPU signals
    input           is_isync_i,     // opcode fetch?
    input [7:0]     cpu_dbo_i,      // DB output to the CPU
    input           cef_i,          // Emulation flag?
    // Bus signals
    input           release_wr_i,   // wr-phase
    input           release_cs_i,   // cs-phase
    input [7:0]     romblock_nr,    // current romblock number
    input           isafix816_enabled,  // if the ISAFIX detection is enabled in SYSREGS
    // Control outputs
    output reg      map_pblrom_o,   // command to map the PBL ROM
    output reg      unmap_pblrom_o, // command to unmap the PBL ROM
    output          bad_opc6502_abortn      // command to ABORT the current instruction
);
    // IMPLEMENTATION

    // reg     internal_cpu_res;                       // indicates that the 65xx CPU is ongoing internal reset, some output signals are invalid!
    // wire    is_isync = csync_vpa_r && cvda_r;      // indicates this is an opcode fetch CPU cycle
    // wire     isafix816_enabled;
    
    // detect bad opcodes of 6502 used in 65816 CPU:
    wire    is_bad_opcode6502 = (cpu_dbo_i[2:0] == 3'b111) && !cputype02_i && is_isync_i /*&& !internal_cpu_res*/;
    wire    is_rti_opcode = (cpu_dbo_i == 8'h40) && is_isync_i /*&& !internal_cpu_res*/;
    
    // ABORTn generated by a bad opcode; signal active low
    reg     bad_opc6502_abort1n, bad_opc6502_abort2n;
    assign  bad_opc6502_abortn = bad_opc6502_abort1n && bad_opc6502_abort2n;        // active low => any zero will trigger it.


    always @(posedge clk) 
    begin
        if (!resetn)
        begin
            bad_opc6502_abort1n <= 1;           // 1=inactive
            bad_opc6502_abort2n <= 1;           // 1=inactive
            // internal_cpu_res <= 0;
            // isafix816_enabled <= 0;             // dis. XXXXenable by default
            // icd_cpu_stop <= 0;
            map_pblrom_o <= 0;
            unmap_pblrom_o <= 0;
        end else begin
            // icd_cpu_stop <= 0;
            map_pblrom_o <= 0;
            unmap_pblrom_o <= 0;

            // detect CPU reset (active low)?
            // if (!CRESn)
            // begin
                // yes -> remember
                // internal_cpu_res <= 1;
                // isafix816_enabled <= 1;             // enabled
            // end

            // detect CPU Vector Pull (active low)?
            // if (!cvpn_r)
            // begin
                // yes -> CPU internal reset sequence is practically finished
                // internal_cpu_res <= 0;
            // end

            // last u-cycle before PHI2 falling?
            if (release_wr_i)
            begin
                if (is_bad_opcode6502 && isafix816_enabled && cef_i)
                begin
                    bad_opc6502_abort1n <= 0;       // 0=activate!
                    // isafix816_enabled <= 0;         // 0=deactivate ISAFIX further detection of bad opcodes
                    // icd_cpu_stop <= 1;
                    map_pblrom_o <= 1;
                end

                // detect RTI opcode while ROMBLOCK bit #6 is set
                if (is_rti_opcode && romblock_nr[6])
                begin
                    // -> yes, then clear the ROMBLOCK bits 7 and 6 to remove the PBL ROM from the map.
                    unmap_pblrom_o <= 1;
                end
            end

            // first u-cycle after PHI2 falling?
            if (release_cs_i)
            begin
                bad_opc6502_abort2n <= bad_opc6502_abort1n;     // shift 
                bad_opc6502_abort1n <= 1;           // 1=inactivate!
            end
        end
    end

endmodule
