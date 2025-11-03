const std = @import("std");

const translationCount: usize = 17;

pub const Translation = struct {
    key: [:0]const u8,
    value: [:0]const u8,
};

const DE_TRANSLATIONS: [translationCount]Translation = [translationCount]Translation{
    Translation{ .key = "title", .value = "Doctor Sandman" },
    Translation{ .key = "pressSpaceToStart", .value = "Drücke LEERTASTE zum Starten\nNutze E für Englisch oder D für Deutsch\nBenötigt einen neustart" },
    Translation{ .key = "PlayerCoins", .value = "Spielermünzen: %02.02f" },
    Translation{ .key = "LastWon", .value = "Zuletzt gewonnen: %02.02f" },
    Translation{ .key = "Debt", .value = "Schulden: -%02.02f" },

    Translation{ .key = "DebtQuestionTitle", .value = "#191#Ups" },
    Translation{ .key = "DebtQuestionMessage", .value = "Es sieht so aus, als hättest du nicht genug Geld für diesen Spin...\nMöchtest du einen Kredit aufnehmen?" },
    Translation{ .key = "DebtQuestionButtons", .value = "Kredit von 40 aufnehmen;Ablehnen und Spiel beenden" },
    Translation{ .key = "cutSceneIntro1", .value = " On a grim rainy Morning\n you awake to\nThe smell of cigarette smoke and coffe in the air.\nYou once again fell asleep at your des\n beside you\n Mila your beloved cat\n curled into a blanked you left out for her.\nThese damn Murders\n they just won't stop.\nYou haven't gotten much sleep for months\n it all started out 4 Months ago... " },
    Translation{ .key = "cutSceneIntro2", .value = "When a doctor had been brutally murdered shortly after leaving his job at Coretechs.\nThe Same Company that has been proced and critizised for their work nonstop." },
    Translation{ .key = "cutSceneIntro3", .value = "They are one ofd the worlds leading Pharmaceutrical companies\nbut also always under attack for god knows what now, Inhuman labor practices, animal cruelty\nand even some rumors about workers and test patients dying due to their...\nlet's call it work practices..." },
    Translation{ .key = "cutSceneIntro4", .value = "That last piece, that should've been what sparked your interest,\nbut instead this time it was way simpler to get me to do the work, it was a Note..." },
    Translation{ .key = "cutSceneIntro5", .value = "A Note, written by the Doctor himself, it read: " },
    Translation{ .key = "cutSceneIntro6", .value = "Dear Detective,\nI have tried to get the Police to listen to me, but they shrugged it off as simple 'Paranoia'.\nI heard you are one of the few people who might be willing to take on my request.\nI fear, I may have given offense to those whose reach exceeds my own\nnow I suppose, they are after me.\nI found out about Coretechs real goals...\nPlease meet me as soon as you can! I will be awaiting you in the City Park\n at the bench near the carousel at dawn this coming Saturday.\nTime is of the essence my friend.\n    ~Sherman Sandwood" },
    Translation{ .key = "cutSceneIntro7", .value = "A weird note I must say, sadly, by the time it had reached me, Sherman has had already been killed.\n" },
    Translation{ .key = "cutSceneIntro8", .value = "Inside the Mail, there was also a weirdly shaped Key, I have a feeling that the Doctor knew what was coming his way,\nand also knew, he had to leave me some more information...\nAt least, I hope that's what's inside whatever the key is supposed to open..." },
    Translation{ .key = "cutSceneIntro9", .value = "If he would've also told me, what this key is supposed to open...\nApparently, he did not want anyone to be able to easily find whatever hes hiding...\nOr maybe, he just dropped his key into the envelope..." },
};

const EN_TRANSLATIONS: [translationCount]Translation = [translationCount]Translation{
    Translation{ .key = "title", .value = "Doctor Sandman" },
    Translation{ .key = "pressSpaceToStart", .value = "Press SPACE to start\nUse E for English D for German\nWill require Restart" },
    Translation{ .key = "PlayerCoins", .value = "Player coins: %02.02f" },
    Translation{ .key = "LastWon", .value = "Last won: %02.02f" },
    Translation{ .key = "Debt", .value = "Debt: -%02.02f" },
    Translation{ .key = "DebtQuestionTitle", .value = "#191#Woops" },
    Translation{ .key = "DebtQuestionMessage", .value = "Looks like you don't have enough money for this spin...\nWould you like to take a loan?" },
    Translation{ .key = "DebtQuestionButtons", .value = "Take loan of 40;Decline and end the game" },
    Translation{ .key = "cutSceneIntro1", .value = " On a grim rainy Morning\n you awake to\nThe smell of cigarette smoke and coffe in the air.\nYou once again fell asleep at your des\n beside you\n Mila your beloved cat\n curled into a blanked you left out for her.\nThese damn Murders\n they just won't stop.\nYou haven't gotten much sleep for months\n it all started out 4 Months ago... " },
    Translation{ .key = "cutSceneIntro2", .value = "When a doctor had been brutally murdered shortly after leaving his job at Coretechs.\nThe Same Company that has been proced and critizised for their work nonstop." },
    Translation{ .key = "cutSceneIntro3", .value = "They are one ofd the worlds leading Pharmaceutrical companies\nbut also always under attack for god knows what now, Inhuman labor practices, animal cruelty\nand even some rumors about workers and test patients dying due to their...\nlet's call it work practices..." },
    Translation{ .key = "cutSceneIntro4", .value = "That last piece, that should've been what sparked your interest,\nbut instead this time it was way simpler to get me to do the work, it was a Note..." },
    Translation{ .key = "cutSceneIntro5", .value = "A Note, written by the Doctor himself, it read: " },
    Translation{ .key = "cutSceneIntro6", .value = "Dear Detective,\nI have tried to get the Police to listen to me, but they shrugged it off as simple 'Paranoia'.\nI heard you are one of the few people who might be willing to take on my request.\nI fear, I may have given offense to those whose reach exceeds my own\nnow I suppose, they are after me.\nI found out about Coretechs real goals...\nPlease meet me as soon as you can! I will be awaiting you in the City Park\n at the bench near the carousel at dawn this coming Saturday.\nTime is of the essence my friend.\n    ~Sherman Sandwood" },
    Translation{ .key = "cutSceneIntro7", .value = "A weird note I must say, sadly, by the time it had reached me, Sherman has had already been killed.\n" },
    Translation{ .key = "cutSceneIntro8", .value = "Inside the Mail, there was also a weirdly shaped Key, I have a feeling that the Doctor knew what was coming his way,\nand also knew, he had to leave me some more information...\nAt least, I hope that's what's inside whatever the key is supposed to open..." },
    Translation{ .key = "cutSceneIntro9", .value = "If he would've also told me, what this key is supposed to open...\nApparently, he did not want anyone to be able to easily find whatever hes hiding...\nOr maybe, he just dropped his key into the envelope..." },
};

pub const Translator = struct {
    language: []const u8,

    pub fn init(language: []const u8) Translator {
        return Translator{
            .language = language,
        };
    }

    pub fn translate(translator: *Translator, key: []const u8) [:0]const u8 {
        var translations: [translationCount]Translation = EN_TRANSLATIONS;
        if (std.mem.eql(u8, translator.language, "de")) {
            translations = DE_TRANSLATIONS;
        }

        for (translations) |t| {
            if (std.mem.eql(u8, t.key, key)) return t.value;
        }
        return "";
    }
};
