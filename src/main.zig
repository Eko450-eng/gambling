const std = @import("std");
const gambling = @import("gambling");
const rl = @import("raylib");
const Player = @import("core/player.zig").Player;
const SlotMachine = @import("core/slotMachine.zig").SlotMachine;
const SlotMachineReworked = @import("core/slotMachineReworked.zig").SlotMachine;

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

const Views = enum(i8) {
    load = 1,
    gambling = 2,
    main = 3,
};

const GameState = struct {
    viewState: Views,
};

pub fn main() !void {
    rl.initWindow(1280, 720, "Gambling game");
    defer rl.closeWindow();
    rl.setTargetFPS(60);
    var gameState = GameState{ .viewState = Views.load };

    // var slotMachine = try SlotMachine.init(0);
    var slotMachineReworked = SlotMachineReworked.init(10);
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
        // const boxWidth = rl.getScreenWidth();
        // const boxHeight = rl.getScreenHeight();

        rl.clearBackground(rl.Color.black);

        switch (gameState.viewState) {
            .gambling => {
                //if (rl.isKeyPressed(.space)) try slotMachine.action(&player, 10);
                if (rl.isKeyPressed(.space)) slotMachineReworked.action(&player, 10);
                // try slotMachine.draw(&player, boxWidth, boxHeight, FieldTexture, IconTextures);
                slotMachineReworked.draw(FieldTexture, IconTextures);
            },
            .load => {
                const text = "Press SPACE to start";
                const fontSize = 30;
                const textWidth = rl.measureText(text, fontSize);
                rl.drawText(text, @divTrunc(rl.getScreenWidth() - textWidth, 2), @divFloor(rl.getScreenHeight(), 2), 30, .white);
                if (rl.isKeyPressed(.space)) {
                    gameState.viewState = .gambling;
                    // slotMachine.ready = true;
                }
                if (rl.isKeyPressed(.enter)) gameState.viewState = .main;
            },
            .main => {
                try player.move();
                try player.draw();
            },
        }
    }
}
