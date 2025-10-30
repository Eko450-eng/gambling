const std = @import("std");
const gambling = @import("gambling");
const rl = @import("raylib");

const Rect = rl.Rectangle;
const Vec2 = rl.Vector2;

pub const Player = struct {
    coins: u32,
    debt: u32,
    lastWin: i32,

    pub fn init(startBalance: u32) Player {
        return .{
            .coins = startBalance,
            .debt = 2000,
            .lastWin = 0,
        };
    }
};
