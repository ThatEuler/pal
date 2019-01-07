--support functions etc.

local dark_addon = dark_interface


dark_addon.support = {};

dark_addon.rotation.CC = {
    [339] = "Entangling Roots",
    [2637] = "Hibernate",
    [41085] = "Freezing Trap",
    [9484] = "Shackle Undead",
    [51514] = "Hex",
    [5782] = "Fear",
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
    [6770] = "Sap"
}

function isCC(target)
    for i = 1, 40 do
        local name, _, _, count, debuff_type, _, _, _, _, spell_id = UnitDebuff("target", i)
        if spell_id == nil then
            break
        end
        if name and dark_addon.rotation.CC[spell_id] then
            return true
        end
    end
    return false
end
