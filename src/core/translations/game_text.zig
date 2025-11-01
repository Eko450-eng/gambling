const std = @import("std");
pub const Translation = struct {
    key: [:0]const u8,
    value: [:0]const u8,
};

const DE_TRANSLATIONS: [8]Translation = [8]Translation{
    Translation{ .key = "title", .value = "Gambling Game" },
    Translation{ .key = "pressSpaceToStart", .value = "Drücke LEERTASTE zum Starten\nNutze E für Englisch oder D für Deutsch\nBenötigt einen neustart" },
    Translation{ .key = "PlayerCoins", .value = "Spielermünzen: %02.02f" },
    Translation{ .key = "LastWon", .value = "Zuletzt gewonnen: %02.02f" },
    Translation{ .key = "Debt", .value = "Schulden: -%02.02f" },

    Translation{ .key = "DebtQuestionTitle", .value = "#191#Ups" },
    Translation{ .key = "DebtQuestionMessage", .value = "Es sieht so aus, als hättest du nicht genug Geld für diesen Spin...\nMöchtest du einen Kredit aufnehmen?" },
    Translation{ .key = "DebtQuestionButtons", .value = "Kredit von 40 aufnehmen;Ablehnen und Spiel beenden" },
};

const EN_TRANSLATIONS: [8]Translation = [8]Translation{
    Translation{ .key = "title", .value = "Gambling game" },
    Translation{ .key = "pressSpaceToStart", .value = "Press SPACE to start\nUse E for English D for German\nWill require Restart" },
    Translation{ .key = "PlayerCoins", .value = "Player coins: %02.02f" },
    Translation{ .key = "LastWon", .value = "Last won: %02.02f" },
    Translation{ .key = "Debt", .value = "Debt: -%02.02f" },

    Translation{ .key = "DebtQuestionTitle", .value = "#191#Woops" },
    Translation{ .key = "DebtQuestionMessage", .value = "Looks like you don't have enough money for this spin...\nWould you like to take a loan?" },
    Translation{ .key = "DebtQuestionButtons", .value = "Take loan of 40;Decline and end the game" },
};

pub const Translator = struct {
    language: []const u8,

    pub fn init(language: []const u8) Translator {
        return Translator{
            .language = language,
        };
    }

    pub fn translate(translator: *Translator, key: []const u8) [:0]const u8 {
        var translations: [8]Translation = EN_TRANSLATIONS;
        if (std.mem.eql(u8, translator.language, "de")) {
            translations = DE_TRANSLATIONS;
        }

        for (translations) |t| {
            if (std.mem.eql(u8, t.key, key)) return t.value;
        }
        return "";
    }
};
