const std = @import("std");
const gambling = @import("gambling");
const rl = @import("raylib");

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

const SPEED = 10;

pub const Player = struct {
    coins: u32,
    debt: u32,
    lastWin: i32,
    position: Vec2,

    pub fn init(startBalance: u32) Player {
        return .{
            .coins = startBalance,
            .debt = 2000,
            .lastWin = 0,
            .position = Vec2{ .x = 0, .y = 0 },
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
};
