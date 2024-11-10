const std = @import("std");
const raylib = @import("raylib");

const This = @This();

const QDraw = @import("../QDraw.zig");
const Arrow = @import("../shapes/Arrow.zig");
const Shape = @import("../shapes/Shape.zig");

context: QDraw.Context,
allocator: std.mem.Allocator,
trigger_key: raylib.KeyboardKey,

arrowx: i32 = 0,
arrowy: i32 = 0,
arrow: ?Arrow = null,
points: std.ArrayList(raylib.Vector2),

pub fn init(allocator: std.mem.Allocator, trigger_key: raylib.KeyboardKey, context: QDraw.Context) This {
    return This{
        .context = context,
        .trigger_key = trigger_key,
        .allocator = allocator,
        .points = std.ArrayList(raylib.Vector2).init(allocator),
    };
}

pub fn tick(self: *This) !void {
    if (raylib.isKeyDown(self.trigger_key)) {
        const mpos = raylib.getScreenToWorld2D(raylib.getMousePosition(), self.context.camera.*);
        if (self.arrow == null) {
            self.arrowx = @intFromFloat(mpos.x);
            self.arrowy = @intFromFloat(mpos.y);
            self.arrow = Arrow.init(self.points.items);
        }
        if (self.points.items.len == 0 or self.points.items[self.points.items.len - 1].distance(mpos) > 10) {
            try self.points.append(mpos.subtract(raylib.Vector2.init(@floatFromInt(self.arrowx), @floatFromInt(self.arrowy))));
            self.arrow.?.line.points = self.points.items;
        }
    } else {
        if (self.arrow) |*arr| {
            arr.line.points = try self.points.toOwnedSlice();
            const shp = try self.context.addShape(arr.*);
            shp.x = self.arrowx;
            shp.y = self.arrowy;
            self.arrow = null;
            self.context.releaseFocus(self);
        }
    }
}

pub fn listen(self: *This) void {
    if (raylib.isKeyPressed(self.trigger_key)) {
        self.context.requestFocus(self);
    }
}

pub fn render(self: *This) void {
    if (self.arrow) |s| {
        s.render(self.arrowx, self.arrowy, raylib.Color.white);
    }
}
