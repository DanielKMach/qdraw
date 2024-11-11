const std = @import("std");
const raylib = @import("raylib");

const This = @This();

const QDraw = @import("../QDraw.zig");
const Shape = @import("../shapes/Shape.zig");

context: QDraw.Context,
allocator: std.mem.Allocator,
trigger_key: raylib.KeyboardKey,

shapes: std.ArrayList(*Shape),

pub fn init(allocator: std.mem.Allocator, trigger_key: raylib.KeyboardKey, context: QDraw.Context) This {
    return This{
        .context = context,
        .trigger_key = trigger_key,
        .allocator = allocator,
        .shapes = std.ArrayList(*Shape).init(allocator),
    };
}

pub fn tick(self: *This) !void {
    const mpos = raylib.getScreenToWorld2D(raylib.getMousePosition(), self.context.camera.*);
    const lastpos = raylib.getScreenToWorld2D(raylib.getMousePosition().subtract(raylib.getMouseDelta()), self.context.camera.*);
    const delta = mpos.subtract(lastpos);

    if (raylib.isKeyUp(self.trigger_key) and self.shapes.items.len == 0) {
        self.shapes.clearRetainingCapacity();
        self.context.releaseFocus(self);
        return;
    }

    if (raylib.isMouseButtonDown(.mouse_button_left)) {
        for (self.shapes.items) |shp| {
            shp.x += @intFromFloat(delta.x);
            shp.y += @intFromFloat(delta.y);
        }
        return;
    } else if (raylib.isMouseButtonReleased(.mouse_button_left)) {
        self.context.canvas.requestRedraw();
    }

    if (raylib.isKeyDown(.key_left_control) and raylib.isKeyPressed(.key_d)) {
        self.shapes.clearRetainingCapacity();
        return;
    }

    if (raylib.isKeyPressed(.key_d) and self.shapes.items.len > 0) {
        var i = self.context.canvas.shapes.items.len;
        while (i > 0) : (i -= 1) {
            const shp = &self.context.canvas.shapes.items[i - 1];
            for (self.shapes.items) |sel| {
                if (sel == shp) {
                    const removed = self.context.canvas.shapes.orderedRemove(i - 1);
                    removed.deinit();
                    break;
                }
            }
        }
        self.shapes.clearRetainingCapacity();
        self.context.canvas.requestRedraw();
        return;
    }

    var t: f32 = 0;
    while (t <= delta.length()) : (t += 1) {
        const hover = self.context.canvas.pickShapeV(mpos.add(delta.normalize().scale(t)));
        if (hover) |h| {
            for (self.shapes.items) |shp| {
                if (shp == h) break;
            } else {
                try self.shapes.append(h);
            }
        }
    }
}

pub fn listen(self: *This) void {
    if (raylib.isKeyPressed(self.trigger_key)) {
        self.context.requestFocus(self);
    }
}

pub fn render(self: *This) void {
    for (self.shapes.items) |shp| {
        shp.renderColored(raylib.Color.blue);
    }
}
