const std = @import("std");
const raylib = @import("raylib");

const This = @This();

const QDraw = @import("../QDraw.zig");
const Shape = @import("../shapes/Shape.zig");

context: QDraw.Context,
allocator: std.mem.Allocator,
trigger_key: raylib.KeyboardKey,
shader: raylib.Shader,
texture: raylib.RenderTexture,

shapes: std.ArrayList(*Shape),

pub fn init(allocator: std.mem.Allocator, trigger_key: raylib.KeyboardKey, context: QDraw.Context) This {
    return This{
        .context = context,
        .trigger_key = trigger_key,
        .allocator = allocator,
        .shapes = std.ArrayList(*Shape).init(allocator),
        .shader = raylib.loadShaderFromMemory(null, @embedFile("selection.frag")),
        .texture = raylib.RenderTexture.init(context.canvas.texture.texture.width, context.canvas.texture.texture.height),
    };
}

pub fn tick(self: *This) !void {
    const mpos = raylib.getScreenToWorld2D(raylib.getMousePosition(), self.context.camera.*);
    const lastpos = raylib.getScreenToWorld2D(raylib.getMousePosition().subtract(raylib.getMouseDelta()), self.context.camera.*);
    const delta = mpos.subtract(lastpos);

    if (raylib.isMouseButtonDown(.mouse_button_left)) {
        for (self.shapes.items) |shp| {
            shp.x += @intFromFloat(delta.x);
            shp.y += @intFromFloat(delta.y);
        }
        return;
    } else if (raylib.isMouseButtonReleased(.mouse_button_left)) {
        self.context.qdraw.requestRedraw();
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
        self.context.qdraw.requestRedraw();
        return;
    }

    if (raylib.isKeyDown(self.trigger_key)) {
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
    } else if (raylib.isKeyUp(self.trigger_key) and self.shapes.items.len == 0) {
        self.context.releaseFocus(self);
    }
}

pub fn listen(self: *This) void {
    if (raylib.isKeyPressed(self.trigger_key)) {
        self.context.requestFocus(self);
    }
}

pub fn render(self: *This) void {
    {
        self.texture.begin();
        defer self.texture.end();

        raylib.clearBackground(raylib.Color.blank);
        for (self.shapes.items) |shp| {
            shp.renderColored(raylib.Color.white);
        }
    }
    {
        raylib.beginShaderMode(self.shader);
        defer raylib.endShaderMode();
        // IDK why but this is rendering relative to the screen, not the world
        // so I did a bunch of math to make it work
        const src = raylib.Rectangle.init(
            0,
            0,
            @floatFromInt(self.texture.texture.width),
            @floatFromInt(-self.texture.texture.height),
        );
        const topleft = raylib.getWorldToScreen2D(raylib.Vector2.zero(), self.context.camera.*);
        const bottomright = raylib.getWorldToScreen2D(raylib.Vector2.init(@floatFromInt(self.texture.texture.width), @floatFromInt(self.texture.texture.height)), self.context.camera.*);
        const size = bottomright.subtract(topleft);
        const dest = raylib.Rectangle.init(
            topleft.x,
            topleft.y,
            size.x,
            size.y,
        );
        raylib.drawTexturePro(self.texture.texture, src, dest, raylib.Vector2.zero(), 0, raylib.Color.blue);
    }
}
