const std = @import("std");
const doctorsandman = @import("../main.zig");
const rl = @import("raylib");
const Player = @import("player.zig").Player;
const Vec2 = rl.Vector2;

var text_display_timer: f32 = 0.0;
const LINGER_DURATION: f32 = 1.0;

const V_SHAPE_UP: [5][2]usize = [_][2]usize{ .{ 2, 0 }, .{ 1, 1 }, .{ 0, 2 }, .{ 1, 3 }, .{ 2, 4 } };
const V_SHAPE_DOWN: [5][2]usize = [_][2]usize{ .{ 0, 0 }, .{ 1, 1 }, .{ 2, 2 }, .{ 1, 3 }, .{ 0, 4 } };
const STRAIGHT_TOP: [5][2]usize = [_][2]usize{ .{ 0, 0 }, .{ 0, 1 }, .{ 0, 2 }, .{ 0, 3 }, .{ 0, 4 } };
const STRAIGHT_MID: [5][2]usize = [_][2]usize{ .{ 1, 0 }, .{ 1, 1 }, .{ 1, 2 }, .{ 1, 3 }, .{ 1, 4 } };
const STRAIGHT_BOTTOM: [5][2]usize = [_][2]usize{ .{ 2, 0 }, .{ 2, 1 }, .{ 2, 2 }, .{ 2, 3 }, .{ 2, 4 } };

const TEN: Symbol = Symbol{ .id = 1, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 0, .y = 341 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 2.5, 10.0 } };
const JOKER: Symbol = Symbol{ .id = 2, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 682, .y = 341 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 2.5, 10.0 } };
const KING: Symbol = Symbol{ .id = 3, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 0, .y = 682 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 4.0, 15.0 } };
const ACE: Symbol = Symbol{ .id = 4, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 0, .y = 682 }, .priceList = [5]f32{ 0.0, 0.0, 0.5, 4.0, 15.0 } };
const SCARAB: Symbol = Symbol{ .id = 5, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 341, .y = 0 }, .priceList = [5]f32{ 0.0, 0.5, 3.0, 10.0, 75.0 } };
const EYE: Symbol = Symbol{ .id = 6, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 341, .y = 341 }, .priceList = [5]f32{ 0.0, 0.5, 3.0, 10.0, 75.0 } };
const RA: Symbol = Symbol{ .id = 7, .color = doctorsandman.NeutralColor, .iconPos = Vec2{ .x = 682, .y = 682 }, .priceList = [5]f32{ 0.0, 0.5, 4.0, 40.0, 200.0 } };
const SYMBOLS: [7]Symbol = [7]Symbol{ TEN, JOKER, KING, ACE, SCARAB, EYE, RA };

const SHAPES: [5][5][2]usize = [5][5][2]usize{
    V_SHAPE_UP,
    V_SHAPE_DOWN,
    STRAIGHT_TOP,
    STRAIGHT_MID,
    STRAIGHT_BOTTOM,
};

const Symbol = struct {
    id: i32,
    priceList: [5]f32,
    color: rl.Color,
    iconPos: Vec2,
};

const SymbolList = struct {
    symbols: [3][5]Symbol,

    pub fn getWins(sl: *SymbolList) f32 {
        var winnings: f32 = 0;
        for (SHAPES) |shape| winnings += sl.checkWinningShape(shape);

        return winnings;
    }

    pub fn checkWinningShape(sl: SymbolList, shape: [5][2]usize) f32 {
        const start_value = sl.symbols[shape[0][0]][shape[0][1]];

        var count: usize = 1;
        for (shape[1..]) |pos| {
            const row = pos[0];
            const col = pos[1];

            if (sl.symbols[row][col].id == start_value.id) {
                count += 1;
            } else {
                // Stop counting when sequence is interrupted
                break;
            }
        }

        // Pay out based on the length of the uninterrupted sequence (count is 1-indexed)
        return start_value.priceList[count - 1];
    }

    pub fn init() SymbolList {
        var result: [3][5]Symbol = undefined;

        var prng = std.Random.DefaultPrng.init(@as(u64, @intCast(std.time.nanoTimestamp())));

        for (0..3) |row_index| {
            for (0..5) |col_index| {
                const idx = prng.random().intRangeLessThan(usize, 0, 6);
                const value = SYMBOLS[idx];
                result[row_index][col_index] = value;
            }
        }

        return SymbolList{ .symbols = result };
    }
};

pub const SlotMachine = struct {
    paidOut: bool,
    playInput: f32,
    symbolList: SymbolList,

    pub fn init(input: f32) SlotMachine {
        const sl = SymbolList.init();
        return SlotMachine{
            .paidOut = false,
            .playInput = input,
            .symbolList = sl,
        };
    }

    pub fn action(machine: *SlotMachine, player: *Player, input: f32) void {
        if (player.coins - input <= 0) return;
        machine.paidOut = false;
        player.coins -= input;

        text_display_timer = LINGER_DURATION;

        machine.playInput = input;
        const sl = SymbolList.init();
        machine.symbolList = sl;

        const winnings: f32 = machine.symbolList.getWins();
        player.lastWin = winnings;
        player.coins += winnings;
        if (player.spinsSinceLastInterestCharge == doctorsandman.INTEREST_DAYS) {
            player.debt *= doctorsandman.INTEREST;
            player.spinsSinceLastInterestCharge = 0;
        }
        player.spinsSinceLastInterestCharge += 1;
    }

    pub fn draw(machine: *SlotMachine, FieldTexture: rl.Texture, IconTextures: rl.Texture) void {
        const widthFloatRaw: f32 = @floatFromInt(rl.getScreenWidth());
        const heightFloatRaw: f32 = @floatFromInt(rl.getScreenHeight());

        const widthFloat: f32 = widthFloatRaw * 0.2;
        const heightFloat: f32 = heightFloatRaw * 0.3;

        const init_pos = Vec2{ .x = widthFloat, .y = heightFloat };
        var pos = init_pos;

        for (machine.symbolList.symbols, 0..) |row, rowIndex| {
            const rowIndexPos = rowIndex + 1;
            const rowIndexFloat: f32 = @floatFromInt(rowIndexPos);
            pos.y = heightFloatRaw * (0.15 * rowIndexFloat);

            for (row, 0..) |out, itemIndex| {
                const itemIndexPos = itemIndex + 1;
                const itemIndexFloat: f32 = @floatFromInt(itemIndexPos);
                pos.x = widthFloatRaw * (0.15 * itemIndexFloat);

                const rec = rl.Rectangle.init(out.iconPos.x, out.iconPos.y, 342, 342);

                const iconSize = 1024 * 0.08;
                const dest = rl.Rectangle.init(pos.x, pos.y, iconSize, iconSize);
                const origin = Vec2{ .x = 0, .y = 0 };

                rl.drawTexturePro(IconTextures, rec, dest, origin, 0, .white);
                rl.drawTextureEx(FieldTexture, pos, 0.0, 0.08, .white);
            }
        }
    }
};
