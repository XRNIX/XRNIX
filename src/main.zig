const std = @import("std");

export fn _start() callconv(.Naked) noreturn {
    @call(.always_inline, main, .{});
}

pub fn main() void {
    while (true) { }
}
