const std = @import("std");

const This = @This();
const CanvasState = @import("CanvasState.zig");
const Tool = @import("tools/Tool.zig");

pub const Context = struct {
    qdraw: *This,
    canvas: *CanvasState,

    pub fn init(qdraw: *This) Context {
        return Context{
            .qdraw = qdraw,
            .canvas = &qdraw.canvas,
        };
    }

    pub fn requestFocus(self: *Context, tool: anytype) void {
        std.debug.print("Requested focus\r\n", .{});
        if (self.qdraw.selected_tool != null) return;
        for (self.qdraw.tools.items) |t| {
            if (@intFromPtr(t.data) == @intFromPtr(tool)) {
                self.qdraw.selected_tool = t;
                break;
            }
        }
    }

    pub fn releaseFocus(self: *Context, tool: anytype) void {
        std.debug.print("Requested focus release\r\n", .{});
        const stool = if (self.qdraw.selected_tool) |t| &t else return;
        if (@intFromPtr(stool) == @intFromPtr(tool) or @intFromPtr(stool.data) == @intFromPtr(tool)) {
            self.qdraw.selected_tool = null;
        }
    }
};

allocator: std.mem.Allocator,
canvas: CanvasState,
tools: std.ArrayList(Tool),
selected_tool: ?Tool = null,

pub fn init(allocator: std.mem.Allocator) !This {
    const canvas = try CanvasState.init(allocator);

    return This{
        .allocator = allocator,
        .canvas = canvas,
        .tools = std.ArrayList(Tool).init(allocator),
    };
}

pub fn tick(self: *This) void {
    if (self.selected_tool) |st| {
        st.tick();
    }

    for (self.tools.items) |t| {
        t.listen();
    }
}

pub fn render(self: *This) void {
    self.canvas.render();

    if (self.selected_tool) |st| {
        st.render();
    }
}
