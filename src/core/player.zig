const std = @import("std");
const doctorsandman = @import("../main.zig");
const rl = @import("raylib");
const rg = @import("raygui");
const Translations = @import("translations/game_text.zig");

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

const SPEED = 10;

pub const Player = struct {
    coins: f32,
    debt: f32,
    lastWin: f32,
    position: Vec2,
    payDay: i32,
    spinsSinceLastInterestCharge: i32,

    pub fn init(startBalance: f32) Player {
        return .{
            .coins = startBalance,
            .debt = 0,
            .lastWin = 0,
            .position = Vec2{ .x = 0, .y = 0 },
            .payDay = 0,
            .spinsSinceLastInterestCharge = 0,
        };
    }

    pub fn move(player: *Player) !void {
        if (rl.isKeyDown(.w)) player.position.y -= SPEED;
        if (rl.isKeyDown(.s)) player.position.y += SPEED;
        if (rl.isKeyDown(.d)) player.position.x += SPEED;
        if (rl.isKeyDown(.a)) player.position.x -= SPEED;
    }

    pub fn draw(player: *Player) !void {
        const x: i32 = @intFromFloat(player.position.x);
        const y: i32 = @intFromFloat(player.position.y);
        rl.drawRectangle(x, y, 10, 10, .white);
    }

    pub fn drawGambling(player: *Player, translator: *Translations.Translator) void {
        const screenHeight: f32 = @floatFromInt(rl.getScreenHeight());
        const screenWidth: f32 = @floatFromInt(rl.getScreenWidth());

        const screenHeightHalfed: f32 = @divFloor(screenHeight, 2);
        const screenWidthHalfed: f32 = @divFloor(screenWidth, 2);

        rl.drawText(rl.textFormat(translator.translate("PlayerCoins"), .{player.coins}), 0, rl.getScreenHeight() - doctorsandman.FONT_SIZE, doctorsandman.FONT_SIZE, doctorsandman.NeutralColor);
        if (player.lastWin > 0) rl.drawText(rl.textFormat(translator.translate("LastWin"), .{player.lastWin}), 0, rl.getScreenHeight() - doctorsandman.FONT_SIZE * 2, doctorsandman.FONT_SIZE, doctorsandman.WinColor);
        if (player.debt > 0) rl.drawText(rl.textFormat(translator.translate("Debt"), .{player.debt}), 0, rl.getScreenHeight() - doctorsandman.FONT_SIZE * 3, doctorsandman.FONT_SIZE, doctorsandman.LooseColor);

        if (player.coins <= 10) {
            const res = rg.messageBox(
                .init(screenWidthHalfed - screenWidth * 0.25, screenHeightHalfed, screenWidth * 0.5, screenHeight * 0.3),
                translator.translate("DebtQuestionTitle"),
                translator.translate("DebtQuestionMessage"),
                translator.translate("DebtQuestionButtons"),
            );

            // TODO: Add save function
            // BUG: when exiting using this function something crashes

            if (res == 1) {
                player.coins += 40;
                player.debt += 40;
            } else if (res == 2) {
                rl.closeWindow();
            }
        }
    }
};
