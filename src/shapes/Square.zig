const std = @import("std");
const raylib = @import("raylib");

const Shape = @import("Shape.zig");
const This = @This();

width: i32,
height: i32,

pub fn init(width: i32, height: i32) This {
    return This{
        .width = width,
        .height = height,
    };
}

pub fn render(self: This, x: i32, y: i32) void {
    var fx: i32 = x;
    var fy: i32 = y;
    var w: i32 = self.width;
    var h: i32 = self.height;
    if (w < 0) {
        fx += w;
        w = -w;
    }
    if (h < 0) {
        fy += h;
        h = -h;
    }
    const rect = raylib.Rectangle.init(
        @floatFromInt(fx),
        @floatFromInt(fy),
        @floatFromInt(w),
        @floatFromInt(h),
    );
    raylib.drawRectangleLinesEx(rect, 5, raylib.Color.white);
}

pub fn shape(self: This, x: i32, y: i32, alloc: std.mem.Allocator) !Shape {
    return Shape.init(self, x, y, alloc);
}
