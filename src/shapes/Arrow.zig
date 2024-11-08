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

    // Draw tip
    const tip = self.points[self.points.len - 1];
    var before: raylib.Vector2 = undefined;
    for (1..self.points.len) |i| {
        before = self.points[self.points.len - i];
        if (before.distance(tip) > 10) break;
    }
    const dir = before.subtract(tip);
    const dirn = dir.normalize();
    const tip1 = tip.add(dirn.rotate(45 * std.math.rad_per_deg).scale(20));
    raylib.drawLineEx(tip.add(offset), tip1.add(offset), 5, raylib.Color.white);
    const tip2 = tip.add(dirn.rotate(-45 * std.math.rad_per_deg).scale(20));
    raylib.drawLineEx(tip.add(offset), tip2.add(offset), 5, raylib.Color.white);
}

pub fn deinit(self: This, alloc: std.mem.Allocator) void {
    alloc.free(self.points);
}
