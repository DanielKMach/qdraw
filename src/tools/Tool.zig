const std = @import("std");
const raylib = @import("raylib");

const This = @This();
const ListenFn = fn (self: *anyopaque) void;
const UpdateFn = fn (self: *anyopaque) anyerror!void;
const RenderFn = fn (self: *anyopaque) void;
const DeinitFn = fn (self: *anyopaque, std.mem.Allocator) void;

data: *anyopaque,
alloc: std.mem.Allocator,
renderFn: *const RenderFn,
tickFn: *const UpdateFn,
listenFn: *const ListenFn,
deinitFn: *const DeinitFn,

pub fn init(tool: anytype, alloc: std.mem.Allocator) !This {
    const ToolType = @TypeOf(tool);
    const typeInfo = @typeInfo(ToolType);

    if (typeInfo != .Struct) {
        @compileError("type of shape must be a struct");
    }
    if (!@hasDecl(ToolType, "render")) {
        @compileError(@typeName(ToolType) ++ " must have a render method");
    }
    if (@TypeOf(ToolType.render) != fn (*ToolType) void) {
        @compileError(@typeName(ToolType) ++ ".render must have the signature `fn (*" ++ @typeName(ToolType) ++ ") void`");
    }
    if (!@hasDecl(ToolType, "tick")) {
        @compileError(@typeName(ToolType) ++ " must have a tick method");
    }
    if (!@hasDecl(ToolType, "listen")) {
        @compileError(@typeName(ToolType) ++ " must have a listen method");
    }

    const Wrapper = struct {
        pub fn render(self: *anyopaque) void {
            const toolData: *ToolType = @alignCast(@ptrCast(self));
            toolData.render();
        }
        pub fn tick(self: *anyopaque) !void {
            const toolData: *ToolType = @alignCast(@ptrCast(self));
            try toolData.tick();
        }
        pub fn listen(self: *anyopaque) void {
            const toolData: *ToolType = @alignCast(@ptrCast(self));
            toolData.listen();
        }
        pub fn deinit(self: *anyopaque, allocator: std.mem.Allocator) void {
            const toolData: *ToolType = @alignCast(@ptrCast(self));
            allocator.destroy(toolData);
        }
    };

    const data = try alloc.create(@TypeOf(tool));
    data.* = tool;

    return This{
        .data = data,
        .alloc = alloc,
        .renderFn = &Wrapper.render,
        .tickFn = &Wrapper.tick,
        .listenFn = &Wrapper.listen,
        .deinitFn = &Wrapper.deinit,
    };
}

pub fn render(self: This) void {
    self.renderFn(self.data);
}

pub fn tick(self: This) !void {
    try self.tickFn(self.data);
}

pub fn listen(self: This) void {
    return self.listenFn(self.data);
}

pub fn deinit(self: This) void {
    self.deinitFn(self.data, self.alloc);
}
