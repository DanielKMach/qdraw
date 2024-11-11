const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const CanvasState = @import("CanvasState.zig");
const Tool = @import("tools/Tool.zig");
const Shape = @import("shapes/Shape.zig");

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

    pub fn addShape(self: Context, shape: anytype) !*Shape {
        var shp: Shape = undefined;
        if (@TypeOf(shape) == Shape) {
            shp = shape;
        } else {
            shp = try Shape.init(shape, 0, 0, self.qdraw.allocator);
        }
        try self.canvas.shapes.append(shp);
        self.qdraw.requestRedraw();
        return &self.canvas.shapes.items[self.canvas.shapes.items.len - 1];
    }
};

allocator: std.mem.Allocator,
canvas: CanvasState,
camera: raylib.Camera2D,
tools: std.ArrayList(Tool),
selected_tool: ?Tool = null,
redraw_requested: bool = true,

pub fn init(allocator: std.mem.Allocator) !This {
    const canvas = try CanvasState.init(allocator, 1024, 1024);

    return This{
        .allocator = allocator,
        .canvas = canvas,
        .tools = std.ArrayList(Tool).init(allocator),
        .camera = raylib.Camera2D{
            .offset = raylib.Vector2.zero(),
            .target = raylib.Vector2.zero(),
            .rotation = 0,
            .zoom = 1,
        },
    };
}
pub fn requestRedraw(self: *This) void {
    self.redraw_requested = true;
    log.info("Redraw requested", .{});
}

pub fn tick(self: *This) void {
    { // Camera controller
        self.camera.zoom += raylib.getMouseWheelMoveV().scale(0.1).y;
        self.camera.zoom = raylib.math.clamp(self.camera.zoom, 0.2, 2);

        const mpos = raylib.getMousePosition();
        const delta = raylib.getMouseDelta().scale(1 / self.camera.zoom);

        self.camera.target = self.camera.target.add(delta);
        self.camera.offset = mpos;

        if (raylib.isMouseButtonDown(.mouse_button_right)) {
            self.camera.target = self.camera.target.subtract(delta);
        }
    }

    if (raylib.isKeyPressed(.key_delete)) {
        self.canvas.clear();
        self.requestRedraw();
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
    if (self.redraw_requested) {
        self.redraw_requested = false;
        self.canvas.redraw();
    }

    self.camera.begin();
    defer self.camera.end();

    self.canvas.render();

    if (self.selected_tool) |st| {
        st.render();
    }
}
