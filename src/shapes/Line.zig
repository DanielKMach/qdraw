const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const Shape = @import("Shape.zig");

points: []raylib.Vector2,

pub fn init(points: []raylib.Vector2) This {
    return This{
        .points = points,
    };
}

pub fn render(self: This, x: i32, y: i32) void {
    const offset = raylib.Vector2.init(@floatFromInt(x), @floatFromInt(y));
    if (self.points.len < 2) return;
    for (0..self.points.len) |i| {
        if (i == 0) continue;
        raylib.drawLineEx(self.points[i].add(offset), self.points[i - 1].add(offset), 5, raylib.Color.white);
    }
}

pub fn deinit(self: This, alloc: std.mem.Allocator) void {
    alloc.free(self.points);
}
