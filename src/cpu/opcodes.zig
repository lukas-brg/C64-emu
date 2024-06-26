const std = @import("std");
const CPU = @import("cpu.zig").CPU;
const instructions = @import("instructions.zig");
const instruction = @import("instruction.zig");

const HandlerFn = fn(*CPU, instruction.Instruction) void;


const opcode_lookup_table: [256]?OpcodeInfo = init_opcode_table();

fn init_opcode_table() [256]?OpcodeInfo {
    var table: [256]?OpcodeInfo = [_]?OpcodeInfo{null} ** 256;
    for (OPCODE_TABLE) |opcode_struct| {
        table[opcode_struct.opcode] = opcode_struct;
    }
    return table;
}


pub inline fn decode_opcode(opcode: u8) ?OpcodeInfo {
    return opcode_lookup_table[opcode];
}


pub const AddressingMode = enum {
    ACCUMULATOR,
    ABSOLUTE,
    ABSOLUTE_X,
    ABSOLUTE_Y,
    IMMEDIATE,
    IMPLIED,
    INDIRECT,
    INDIRECT_X,
    INDIRECT_Y,
    RELATIVE,
    ZEROPAGE,
    ZEROPAGE_X,
    ZEROPAGE_Y,
};


pub const OpcodeInfo = struct {
    opcode: u8,
    op_name: []const u8,
    addressing_mode: AddressingMode,
    bytes: u3,
    cycles: u4,
    handler_fn:  * const HandlerFn,

    pub fn print(self: OpcodeInfo) void {
        std.debug.print("(Name: {s}, Opcode: 0x{x:0>2},  Addressing Mode: {s}, Bytes: {}, Cycles: {})\n",
            .{self.op_name, self.opcode, @tagName(self.addressing_mode), self.bytes, self.cycles});
    }
};


const OPCODE_TABLE = [_]OpcodeInfo{
    // Only the legal opcodes are implemented for now, ToDo?
    .{.opcode=0x69, .op_name="ADC", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.adc},
    .{.opcode=0x65, .op_name="ADC", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.adc},
    .{.opcode=0x75, .op_name="ADC", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.adc},
    .{.opcode=0x6D, .op_name="ADC", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.adc},
    .{.opcode=0x7D, .op_name="ADC", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.adc},
    .{.opcode=0x79, .op_name="ADC", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.adc},
    .{.opcode=0x61, .op_name="ADC", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.adc},
    .{.opcode=0x71, .op_name="ADC", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.adc},

    .{.opcode=0x29, .op_name="AND", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.and_fn},
    .{.opcode=0x25, .op_name="AND", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.and_fn},
    .{.opcode=0x35, .op_name="AND", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.and_fn},
    .{.opcode=0x2D, .op_name="AND", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.and_fn},
    .{.opcode=0x3D, .op_name="AND", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.and_fn},
    .{.opcode=0x39, .op_name="AND", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.and_fn},
    .{.opcode=0x21, .op_name="AND", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.and_fn},
    .{.opcode=0x31, .op_name="AND", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.and_fn},

    .{.opcode=0x0A, .op_name="ASL", .addressing_mode=AddressingMode.ACCUMULATOR,.bytes = 1, .cycles = 2, .handler_fn = &instructions.asl},
    .{.opcode=0x06, .op_name="ASL", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 5, .handler_fn = &instructions.asl},
    .{.opcode=0x16, .op_name="ASL", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.asl},
    .{.opcode=0x0E, .op_name="ASL", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.asl},
    .{.opcode=0x1E, .op_name="ASL", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 7, .handler_fn = &instructions.asl},

    .{.opcode=0x90, .op_name="BCC", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bcc},
    .{.opcode=0xB0, .op_name="BCS", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bcs},
    .{.opcode=0xF0, .op_name="BEQ", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.beq},
    .{.opcode=0x30, .op_name="BMI", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bmi},
    .{.opcode=0xD0, .op_name="BNE", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bne},
    .{.opcode=0x10, .op_name="BPL", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bpl},
    .{.opcode=0x50, .op_name="BVC", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bvc},
    .{.opcode=0x70, .op_name="BVS", .addressing_mode=AddressingMode.RELATIVE,   .bytes = 2, .cycles = 2, .handler_fn = &instructions.bvs},
    
    .{.opcode=0x24, .op_name="BIT", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.bit},
    .{.opcode=0x2C, .op_name="BIT", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.bit},
    
    .{.opcode=0x00, .op_name="BRK", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 2, .cycles = 7, .handler_fn = &instructions.brk},
    
    .{.opcode=0x18, .op_name="CLC", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.clc},
    .{.opcode=0xD8, .op_name="CLD", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.cld},
    .{.opcode=0x58, .op_name="CLI", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.cli},
    .{.opcode=0xB8, .op_name="CLV", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.clv},

    .{.opcode=0xC9, .op_name="CMP", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.cmp},
    .{.opcode=0xC5, .op_name="CMP", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.cmp},
    .{.opcode=0xD5, .op_name="CMP", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.cmp},
    .{.opcode=0xCD, .op_name="CMP", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.cmp},
    .{.opcode=0xDD, .op_name="CMP", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.cmp},
    .{.opcode=0xD9, .op_name="CMP", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.cmp},
    .{.opcode=0xC1, .op_name="CMP", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.cmp},
    .{.opcode=0xD1, .op_name="CMP", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.cmp},

    .{.opcode=0xE0, .op_name="CPX", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.cpx},
    .{.opcode=0xE4, .op_name="CPX", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.cpx},
    .{.opcode=0xEC, .op_name="CPX", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.cpx},
    
    .{.opcode=0xC0, .op_name="CPY", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.cpy},
    .{.opcode=0xC4, .op_name="CPY", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.cpy},
    .{.opcode=0xCC, .op_name="CPY", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.cpy},

    .{.opcode=0xC6, .op_name="DEC", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 5, .handler_fn = &instructions.dec},
    .{.opcode=0xD6, .op_name="DEC", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.dec},
    .{.opcode=0xCE, .op_name="DEC", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.dec},
    .{.opcode=0xDE, .op_name="DEC", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 7, .handler_fn = &instructions.dec},
    
    .{.opcode=0xCA, .op_name="DEX", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.dex},
    .{.opcode=0x88, .op_name="DEY", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.dey},
    
    .{.opcode=0x49, .op_name="EOR", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.eor},
    .{.opcode=0x45, .op_name="EOR", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.eor},
    .{.opcode=0x55, .op_name="EOR", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.eor},
    .{.opcode=0x4D, .op_name="EOR", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.eor},
    .{.opcode=0x5D, .op_name="EOR", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.eor},
    .{.opcode=0x59, .op_name="EOR", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.eor},
    .{.opcode=0x41, .op_name="EOR", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.eor},
    .{.opcode=0x51, .op_name="EOR", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.eor},

    .{.opcode=0xE6, .op_name="INC", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 5, .handler_fn = &instructions.inc},
    .{.opcode=0xF6, .op_name="INC", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.inc},
    .{.opcode=0xEE, .op_name="INC", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.inc},
    .{.opcode=0xFE, .op_name="INC", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 7, .handler_fn = &instructions.inc},

    .{.opcode=0xE8, .op_name="INX", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.inx},
    .{.opcode=0xC8, .op_name="INY", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.iny},

    .{.opcode=0x4C, .op_name="JMP", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 3, .handler_fn = &instructions.jmp},
    .{.opcode=0x6C, .op_name="JMP", .addressing_mode=AddressingMode.INDIRECT,   .bytes = 3, .cycles = 5, .handler_fn = &instructions.jmp},
    .{.opcode=0x20, .op_name="JSR", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.jsr},

    .{.opcode=0xA9, .op_name="LDA", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.lda},
    .{.opcode=0xA5, .op_name="LDA", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.lda},
    .{.opcode=0xB5, .op_name="LDA", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.lda},
    .{.opcode=0xAD, .op_name="LDA", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.lda},
    .{.opcode=0xBD, .op_name="LDA", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.lda},
    .{.opcode=0xB9, .op_name="LDA", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.lda},
    .{.opcode=0xA1, .op_name="LDA", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.lda},
    .{.opcode=0xB1, .op_name="LDA", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.lda},

    .{.opcode=0xA2, .op_name="LDX", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.ldx},
    .{.opcode=0xA6, .op_name="LDX", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.ldx},
    .{.opcode=0xB6, .op_name="LDX", .addressing_mode=AddressingMode.ZEROPAGE_Y, .bytes = 2, .cycles = 4, .handler_fn = &instructions.ldx},
    .{.opcode=0xAE, .op_name="LDX", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.ldx},
    .{.opcode=0xBE, .op_name="LDX", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.ldx},

    .{.opcode=0xA0, .op_name="LDY", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.ldy},
    .{.opcode=0xA4, .op_name="LDY", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.ldy},
    .{.opcode=0xB4, .op_name="LDY", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.ldy},
    .{.opcode=0xAC, .op_name="LDY", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.ldy},
    .{.opcode=0xBC, .op_name="LDY", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.ldy},

    .{.opcode=0x4A, .op_name="LSR", .addressing_mode=AddressingMode.ACCUMULATOR,.bytes = 1, .cycles = 2, .handler_fn = &instructions.lsr},
    .{.opcode=0x46, .op_name="LSR", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 5, .handler_fn = &instructions.lsr},
    .{.opcode=0x56, .op_name="LSR", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.lsr},
    .{.opcode=0x4E, .op_name="LSR", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.lsr},
    .{.opcode=0x5E, .op_name="LSR", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 7, .handler_fn = &instructions.lsr},

    .{.opcode=0xEA, .op_name="NOP", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.nop},

    .{.opcode=0x09, .op_name="ORA", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.ora},
    .{.opcode=0x05, .op_name="ORA", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.ora},
    .{.opcode=0x15, .op_name="ORA", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.ora},
    .{.opcode=0x0D, .op_name="ORA", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.ora},
    .{.opcode=0x1D, .op_name="ORA", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.ora},
    .{.opcode=0x19, .op_name="ORA", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.ora},
    .{.opcode=0x01, .op_name="ORA", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.ora},
    .{.opcode=0x11, .op_name="ORA", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.ora},

    .{.opcode=0x48, .op_name="PHA", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 3, .handler_fn = &instructions.pha},
    .{.opcode=0x08, .op_name="PHP", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 3, .handler_fn = &instructions.php},
    .{.opcode=0x68, .op_name="PLA", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 4, .handler_fn = &instructions.pla},
    .{.opcode=0x28, .op_name="PLP", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 4, .handler_fn = &instructions.plp},

    .{.opcode=0x6A, .op_name="ROR", .addressing_mode=AddressingMode.ACCUMULATOR,.bytes = 1, .cycles = 2, .handler_fn = &instructions.ror},
    .{.opcode=0x66, .op_name="ROR", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 5, .handler_fn = &instructions.ror},
    .{.opcode=0x76, .op_name="ROR", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.ror},
    .{.opcode=0x6E, .op_name="ROR", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.ror},
    .{.opcode=0x7E, .op_name="ROR", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 7, .handler_fn = &instructions.ror},
       
    .{.opcode=0x2A, .op_name="ROL", .addressing_mode=AddressingMode.ACCUMULATOR,.bytes = 1, .cycles = 2, .handler_fn = &instructions.rol},
    .{.opcode=0x26, .op_name="ROL", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 5, .handler_fn = &instructions.rol},
    .{.opcode=0x36, .op_name="ROL", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.rol},
    .{.opcode=0x2E, .op_name="ROL", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 6, .handler_fn = &instructions.rol},
    .{.opcode=0x3E, .op_name="ROL", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 7, .handler_fn = &instructions.rol},
    
    .{.opcode=0x40, .op_name="RTI", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 6, .handler_fn = &instructions.rti},
    .{.opcode=0x60, .op_name="RTS", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 6, .handler_fn = &instructions.rts},

    .{.opcode=0xE9, .op_name="SBC", .addressing_mode=AddressingMode.IMMEDIATE,  .bytes = 2, .cycles = 2, .handler_fn = &instructions.sbc},
    .{.opcode=0xE5, .op_name="SBC", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.sbc},
    .{.opcode=0xF5, .op_name="SBC", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.sbc},
    .{.opcode=0xED, .op_name="SBC", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.sbc},
    .{.opcode=0xFD, .op_name="SBC", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 4, .handler_fn = &instructions.sbc},
    .{.opcode=0xF9, .op_name="SBC", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 4, .handler_fn = &instructions.sbc},
    .{.opcode=0xE1, .op_name="SBC", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.sbc},
    .{.opcode=0xF1, .op_name="SBC", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 5, .handler_fn = &instructions.sbc},

    .{.opcode=0x38, .op_name="SEC", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.sec},
    .{.opcode=0xF8, .op_name="SED", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.sed},
    .{.opcode=0x78, .op_name="SEI", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.sei},
    
    .{.opcode=0x85, .op_name="STA", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.sta},
    .{.opcode=0x95, .op_name="STA", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.sta},
    .{.opcode=0x8D, .op_name="STA", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.sta},
    .{.opcode=0x9D, .op_name="STA", .addressing_mode=AddressingMode.ABSOLUTE_X, .bytes = 3, .cycles = 5, .handler_fn = &instructions.sta},
    .{.opcode=0x99, .op_name="STA", .addressing_mode=AddressingMode.ABSOLUTE_Y, .bytes = 3, .cycles = 5, .handler_fn = &instructions.sta},
    .{.opcode=0x81, .op_name="STA", .addressing_mode=AddressingMode.INDIRECT_X, .bytes = 2, .cycles = 6, .handler_fn = &instructions.sta},
    .{.opcode=0x91, .op_name="STA", .addressing_mode=AddressingMode.INDIRECT_Y, .bytes = 2, .cycles = 6, .handler_fn = &instructions.sta},
    
    .{.opcode=0x86, .op_name="STX", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.stx},
    .{.opcode=0x96, .op_name="STX", .addressing_mode=AddressingMode.ZEROPAGE_Y, .bytes = 2, .cycles = 4, .handler_fn = &instructions.stx},
    .{.opcode=0x8E, .op_name="STX", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.stx},
    
    .{.opcode=0x84, .op_name="STY", .addressing_mode=AddressingMode.ZEROPAGE,   .bytes = 2, .cycles = 3, .handler_fn = &instructions.sty},
    .{.opcode=0x94, .op_name="STY", .addressing_mode=AddressingMode.ZEROPAGE_X, .bytes = 2, .cycles = 4, .handler_fn = &instructions.sty},
    .{.opcode=0x8C, .op_name="STY", .addressing_mode=AddressingMode.ABSOLUTE,   .bytes = 3, .cycles = 4, .handler_fn = &instructions.sty},
    
    .{.opcode=0xAA, .op_name="TAX", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.tax},
    .{.opcode=0xA8, .op_name="TAY", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.tay},
    .{.opcode=0xBA, .op_name="TSX", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.tsx},
    .{.opcode=0x8A, .op_name="TXA", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.txa},
    .{.opcode=0x9A, .op_name="TXS", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.txs},
    .{.opcode=0x98, .op_name="TYA", .addressing_mode=AddressingMode.IMPLIED,    .bytes = 1, .cycles = 2, .handler_fn = &instructions.tya},

};