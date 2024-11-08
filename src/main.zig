const raylib = @import("raylib");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    raylib.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer raylib.closeWindow();

    raylib.setTargetFPS(60);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.white);

        raylib.drawText("Congrats! You created your first window!", 190, 200, 20, raylib.Color.light_gray);
    }
}
