const std = @import("std");
const gambling = @import("gambling");
const rl = @import("raylib");
const Player = @import("core/player.zig").Player;
const SlotMachine = @import("core/slotMachine.zig").SlotMachine;

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

pub fn main() !void {
    rl.initWindow(1280, 720, "Gambling game");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var slotMachine = try SlotMachine.init(0);
    var player = Player.init(100);

    const FieldImage = try rl.loadImage("assets/tile.png");
    const FieldTexture = try rl.loadTextureFromImage(FieldImage);
    rl.unloadImage(FieldImage);

    const IconImages = try rl.loadImage("assets/iconsnew.png");
    const IconTextures = try rl.loadTextureFromImage(IconImages);
    rl.unloadImage(IconImages);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        // const boxWidth = @divFloor((rl.getScreenWidth() - 20), 5);
        // const boxHeight = @divFloor((rl.getScreenHeight() - 20), 3);
        const boxWidth = rl.getScreenWidth();
        const boxHeight = rl.getScreenHeight();

        rl.clearBackground(rl.Color.black);
        if (rl.isKeyPressed(.space)) try slotMachine.action(&player, 10);

        if (slotMachine.ready) {
            try slotMachine.draw(&player, boxWidth, boxHeight, FieldTexture, IconTextures);
        } else {
            const text = "Press SPACE to start";
            const fontSize = 30;
            const textWidth = rl.measureText(text, fontSize);
            rl.drawText(text, @divTrunc(rl.getScreenWidth() - textWidth, 2), @divFloor(rl.getScreenHeight(), 2), 30, .white);
        }
        var coinColor = rl.Color.green;

        if (player.coins > 1000) {
            coinColor = rl.Color.gold;
        } else if (player.coins >= 100) {
            coinColor = rl.Color.green;
        } else if (player.coins <= 10) {
            coinColor = rl.Color.red;
        }

        if (player.lastWin > 0) rl.drawText(rl.textFormat("Last win: %02u", .{player.lastWin}), 10, rl.getScreenHeight() - 60, 30, coinColor);
        rl.drawText(rl.textFormat("Coins: %02u", .{player.coins}), 10, rl.getScreenHeight() - 30, 30, coinColor);
    }
}
