const std = @import("std");
const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = Target.Cpu.Arch.aarch64,
            .os_tag = Target.Os.Tag.freestanding,
        },
    });
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = std.builtin.OptimizeMode.Debug,
    });

    const kernel = b.addExecutable(.{
        .name = "XRNIX.elf",
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
        .code_model = .tiny,
    });
    kernel.setLinkerScript(.{
        .src_path = .{
            .owner = b,
            .sub_path = "src/linker.ld",
        },
    });

    b.installArtifact(kernel);
}
