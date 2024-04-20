const std = @import("std");
const c = @import("cpu/cpu.zig");
const Bus = @import("bus.zig").Bus;
const CPU = @import("cpu/cpu.zig").CPU;
const Emulator = @import("emulator.zig").Emulator;
const EmulatorConfig = @import("emulator.zig").EmulatorConfig;
const graphics = @import("graphics.zig");

pub fn load_rom_data(rom_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const rom_data = try std.fs.cwd().readFileAlloc(allocator, rom_path, std.math.maxInt(usize));
    return rom_data;
}


pub fn main() !void {
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
   
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    var rom_path: []const u8 = "debug.o65";
    
    if (args.len > 1){
        rom_path = args[1];
    }

    var emulator = try Emulator.init(allocator, .{.scaling_factor = 4});
    defer emulator.deinit(allocator);

    _ = try emulator.load_rom(rom_path, 0x1000);

    try emulator.init_c64();
    try emulator.run(null);
}



fn test_init_reset_vector(bus: *Bus) void {
    // Reset vector to 0x2010
    bus.write(0xfffc, 0x10);
    bus.write(0xfffd, 0x20);
}

test "loading reset vector into pc" {
    const assert = std.debug.assert;
    var bus = Bus{};
    var cpu = c.CPU.init(&bus);
    test_init_reset_vector(&bus);
    cpu.reset();

    assert(cpu.PC == 0x2010);
}

test "set status flag" {
    const assert = std.debug.assert;
    var bus = Bus{};
    var cpu = c.CPU.init(&bus);
    cpu.reset();

    cpu.set_status_flag(c.StatusFlag.BREAK, 1);
    assert(cpu.get_status_flag(c.StatusFlag.BREAK) == 1);

    cpu.toggle_status_flag(c.StatusFlag.BREAK);
    assert(cpu.get_status_flag(c.StatusFlag.BREAK) == 0);

    cpu.toggle_status_flag(c.StatusFlag.BREAK);
    assert(cpu.get_status_flag(c.StatusFlag.BREAK) == 1);

    cpu.set_status_flag(c.StatusFlag.BREAK, 0);
    assert(cpu.get_status_flag(c.StatusFlag.BREAK) == 0);
}

test "stack operations" {
    const assert = std.debug.assert;
    var bus = Bus{};
    var cpu = c.CPU.init(&bus);
    cpu.reset();
    cpu.push(0x4D);
    assert(cpu.pop() == 0x4D);
}


test "test opcode lookup" {
    const assert = std.debug.assert;
    const decode_opcode = @import("cpu/opcodes.zig").decode_opcode;
    var bus = Bus{};
    var cpu = c.CPU.init(&bus);
    cpu.reset();

    const instruction = decode_opcode(0xEA);
    assert(std.mem.eql(u8, instruction.op_name, "NOP"));
}


test "cpu and bus allocation" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const rom_path: []const u8 = "test.o65";
    var emulator = try Emulator.init(allocator);

    _ = try emulator.load_rom(rom_path, 0);

    std.debug.assert(std.mem.eql(u8, &emulator.bus.memory, &emulator.cpu.bus.memory));
    std.debug.assert(emulator.bus == emulator.cpu.bus);

    emulator.run(null);

    std.debug.assert(std.mem.eql(u8, &emulator.bus.memory, &emulator.cpu.bus.memory));
    std.debug.assert(emulator.bus == emulator.cpu.bus);

    emulator.deinit(allocator);
} 