const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const CanvasState = @import("CanvasState.zig");
const Tool = @import("tools/Tool.zig");

const log = std.log.scoped(.qdraw);

pub const Context = struct {
    qdraw: *This,
    canvas: *CanvasState,
    camera: *raylib.Camera2D,

    pub fn init(qdraw: *This) Context {
        return Context{
            .qdraw = qdraw,
            .canvas = &qdraw.canvas,
            .camera = &qdraw.camera,
        };
    }

    pub fn requestFocus(self: *Context, tool: anytype) void {
        log.info(@typeName(@TypeOf(tool)) ++ " requested focus", .{});
        if (self.qdraw.selected_tool != null) return;
        for (self.qdraw.tools.items) |t| {
            if (@intFromPtr(t.data) == @intFromPtr(tool)) {
                log.info(@typeName(@TypeOf(tool)) ++ " obtained focus", .{});
                self.qdraw.selected_tool = t;
                break;
            }
        }
    }

    pub fn releaseFocus(self: *Context, tool: anytype) void {
        log.info(@typeName(@TypeOf(tool)) ++ " requested focus release", .{});
        const stool = if (self.qdraw.selected_tool) |t| &t else return;
        if (@intFromPtr(stool) == @intFromPtr(tool) or @intFromPtr(stool.data) == @intFromPtr(tool)) {
            log.info(@typeName(@TypeOf(tool)) ++ " released focus", .{});
            self.qdraw.selected_tool = null;
        }
    }
};

allocator: std.mem.Allocator,
canvas: CanvasState,
camera: raylib.Camera2D,
tools: std.ArrayList(Tool),
selected_tool: ?Tool = null,

pub fn init(allocator: std.mem.Allocator) !This {
    const canvas = try CanvasState.init(allocator);

    return This{
        .allocator = allocator,
        .canvas = canvas,
        .tools = std.ArrayList(Tool).init(allocator),
        .camera = raylib.Camera2D{
            .offset = raylib.Vector2.init(
                @floatFromInt(@divTrunc(raylib.getScreenHeight(), 2)),
                @floatFromInt(@divTrunc(raylib.getScreenHeight(), 2)),
            ),
            .target = raylib.Vector2.init(0, 0),
            .rotation = 0,
            .zoom = 1,
        },
    };
}

pub fn tick(self: *This) void {
    { // Camera controller
        self.camera.zoom += raylib.getMouseWheelMove() / 10.0;

        const mpos = raylib.getMousePosition();
        const delta = blk: {
            const d = raylib.getMouseDelta();
            break :blk raylib.Vector2.init(d.x / self.camera.zoom, d.y / self.camera.zoom);
        };

        self.camera.target = raylib.math.vector2Add(self.camera.target, delta);
        self.camera.offset = mpos;

        if (raylib.isMouseButtonDown(.mouse_button_right)) {
            self.camera.target = raylib.math.vector2Subtract(self.camera.target, delta);
        }
    }

    if (raylib.isKeyPressed(.key_delete)) {
        self.canvas.clear();
    }

    if (self.selected_tool) |st| {
        st.tick() catch |err| {
            log.err("selected tool tick failed: {s}", .{@errorName(err)});
        };
    }

    for (self.tools.items) |t| {
        t.listen();
    }
}

pub fn render(self: *This) void {
    self.camera.begin();
    defer self.camera.end();

    self.canvas.render();

    if (self.selected_tool) |st| {
        st.render();
    }
}
