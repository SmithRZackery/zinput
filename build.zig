const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("zinput", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    module.link_libc = true;

    if (target.result.os.tag == .windows) {
        module.addIncludePath(b.path("windows.h"));
    } else if (target.result.os.tag == .macos) {
        module.addIncludePath(b.path("CoreGraphics/CoreGraphics.h"));
    } else {
        // NOTE: I'll likely need to ship both X11 and Wayland in this project.
        //       A Linux binary must have both compiled in for it to work.
        //       I shall look into using Mach Core's X11 and Wayland mirrors

        // module.addSystemIncludePath("wayland-client.h");
        module.addIncludePath(b.path("xdo.h"));
    }

    const tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const tests_step = b.step("test", "Run library tests");
    tests_step.dependOn(&tests.step);
}
