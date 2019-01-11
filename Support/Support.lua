--support functions etc.

local dark_addon = dark_interface

dark_addon.support = {};

dark_addon.rotation.spellbooks.purgeables = {
    [255579] = "Gilded Claws",
    [257397] = "Healing Balms",
    [270901] = "Induced REgeneration",
    [273432] = "Bound by Shadow",
    [267256] = "Earthwall",
    [267977] = "Tidal Surge",
    [276266] = "Spirit Swiftness",
    [268030] = "Mending Rapids",
    [274210] = "Reanimated Bones",
    [268375] = "Detect Thoughts",
    [276767] = "Consuming Void",
    [256957] = "Watertight Shell",
    [272659] = "electrified Scales",
    [269896] = "embryonic vigor",
    [265912] = "accumualtedCharge",
    [263224] = "Mark of the blood god"
}

dark_addon.rotation.CC = {
    [339] = "Entangling Roots",
    [2637] = "Hibernate",
    [41085] = "Freezing Trap",
    [9484] = "Shackle Undead",
    [51514] = "Hex",
    -- [5782] = "Fear",
    [217832] = "Imprison",
    [118] = "Polymorph",
    [161372] = "Polymorph Peacock",
    [61780] = "Polymorph Turkey",
    [161353] = "Polymorph Polar Bear",
    [161354] = "Polymorph Monkey",
    [161355] = "Polymorph Penguin",
    [28271] = "Polymorph Turtle",
    [28272] = "Polymorph Pig",
    [61305] = "Polymorph Black Cat",
    [61721] = "Polymorph Rabbit",
    [5246] = "Intimidating Shout",
    [22884] = "Psychic Scream",
    [277787] = "Polymorph Direhorn",
    [277792] = "Polymorph BumbleBee",
    [210873] = "Hex Dinosaur",
    [211004] = "Hex Spider",
    [211010] = "Hex Snake",
    [211015] = "Hex Cockraoch",
    [269352] = "Hex Dinosaur",
    [277778] = "Hex Zandalari Tendonripper",
    [20066] = "Rependance",
    [277784] = "Hex White Mongrel",
    [2094] = "Blind",
    [6770] = "Sap",
    [1776] = "Gouge"
}
dark_addon.rotation.specs = {
    [62] = { name = "Arcane", role = "dps" },
    [63] = { name = "Fire", role = "dps" },
    [64] = { name = "Frost", role = "dps" },
    [65] = { name = "Holy", role = "heal" },
    [66] = { name = "Protection", role = "dps" },
    [70] = { name = "Retribution", role = "dps" },
    [71] = { name = "Arms", role = "dps" },
    [72] = { name = "Fury", role = "dps" },
    [73] = { name = "Protection", role = "dps" },
    [102] = { name = "Balance", role = "dps" },
    [103] = { name = "Feral", role = "dps" },
    [104] = { name = "Guardian", role = "dps" },
    [105] = { name = "Restoration", role = "heal" },
    [250] = { name = "Blood", role = "dps" },
    [251] = { name = "Frost", role = "dps" },
    [252] = { name = "Unholy", role = "dps" },
    [253] = { name = "Beast Mastery", role = "dps" },
    [254] = { name = "Marksmanship", role = "dps" },
    [255] = { name = "Survival", role = "dps" },
    [256] = { name = "Discipline", role = "heal" },
    [257] = { name = "Holy", role = "heal" },
    [258] = { name = "Shadow", role = "dps" },
    [259] = { name = "Assassination", role = "dps" },
    [260] = { name = "Outlaw", role = "dps" },
    [261] = { name = "Subtlety", role = "dps" },
    [262] = { name = "Elemental", role = "dps" },
    [263] = { name = "Enhancement", role = "dps" },
    [264] = { name = "Restoration", role = "heal" },
    [265] = { name = "Affliction", role = "dps" },
    [266] = { name = "Demonology", role = "dps" },
    [267] = { name = "Destruction", role = "dps" },
    [268] = { name = "Brewmaster", role = "dps" },
    [269] = { name = "Windwalker", role = "dps" },
    [270] = { name = "Mistweaver", role = "heal" },
    [577] = { name = "Havoc", role = "dps" },
    [581] = { name = "Vengeance", role = "dps" }
}

function isCC(target)
    for i = 1, 40 do
        local name, _, _, count, debuff_type, _, _, _, _, spell_id = UnitDebuff(target, i)
        if spell_id == nil then
            break
        end
        if name and dark_addon.rotation.CC[spell_id] then
            return true
        end
    end
    return false
end
