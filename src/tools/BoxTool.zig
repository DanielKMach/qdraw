const std = @import("std");
const raylib = @import("raylib");

const This = @This();

const QDraw = @import("../QDraw.zig");
const Square = @import("../shapes/Square.zig");
const Shape = @import("../shapes/Shape.zig");

context: QDraw.Context,
allocator: std.mem.Allocator,
trigger_key: raylib.KeyboardKey,
squarex: i32 = 0,
squarey: i32 = 0,
square: ?Square = null,

pub fn init(allocator: std.mem.Allocator, trigger_key: raylib.KeyboardKey, context: QDraw.Context) This {
    return This{
        .context = context,
        .trigger_key = trigger_key,
        .allocator = allocator,
    };
}

pub fn tick(self: *This) !void {
    if (raylib.isKeyDown(self.trigger_key)) {
        const mpos = raylib.getScreenToWorld2D(raylib.getMousePosition(), self.context.camera.*);
        if (self.square == null) {
            self.squarex = @intFromFloat(mpos.x);
            self.squarey = @intFromFloat(mpos.y);
            self.square = Square.init(0, 0);
        }
        self.square.?.width = @as(i32, @intFromFloat(mpos.x)) - self.squarex;
        self.square.?.height = @as(i32, @intFromFloat(mpos.y)) - self.squarey;
    } else {
        if (self.square) |sqr| {
            const shp = try self.context.addShape(sqr);
            shp.x = self.squarex;
            shp.y = self.squarey;
            self.square = null;
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
    if (self.square) |s| {
        s.render(self.squarex, self.squarey);
    }
}
