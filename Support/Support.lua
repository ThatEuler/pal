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
    [263224] = "Mark of the blood god",
    [258133] = "DarkStep",
    [258153] = "Watery Dome",
    [256849] = "DinoBuff",
    [268375] = "?",
    [276767] = "?",
    [256957] = "?",
    [272659] = "?",
    [262947] = "?",
    [262540] = "?",
    [66009] = "Hand of Protection",
    [12472] = "Icy Veins",
    [10060] = "Power Infusion",
    [2825] = "Bloodlust",
    [29166] = "Innervate",
    [12042] = "Arcane Power",
    [32182] = "Heroism",
    [1044] = "Blessing of Freedom",
    [198111] = "Temporal Shield",
    [213610] = "Holy Ward",
    [196098] = "Soul Harvest",
    [11426] = "Ice Barrier",
    [212295] = "Nether Ward",
    [196762] = "Inner Focus",
    [198144] = "Ice Form",
    [235450] = "Prismatic Barrier",
    [235313] = "Blazing Barrier",
    [190319] = "Combustion",
    [210294] = "Divine Favor",
    [33763] = "Lifebloom"

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

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

function getTanks()
    local tank1 = nil
    local tank2 = nil

    local group_type = GroupType()
    local members = GetNumGroupMembers()
    for i = 1, (members - 1) do
        local unit = group_type .. i
        if (UnitGroupRolesAssigned(unit) == 'TANK') and not UnitCanAttack('player', unit) and not UnitIsDeadOrGhost(unit) then
            if tank1 == nil then
                tank1 = unit
            elseif tank2 == nil then
                tank2 = unit
                break
            end
        end
    end
    --print("The two tanks are: " .. tank1.name .. ", " .. tank2.name)
    if tank1 ~= nil then
        tank1 = dark_addon.environment.conditions.unit(tank1)

    end
    if tank2 ~= nil then
        tank2 = dark_addon.environment.conditions.unit(tank2)
    end
    return tank1, tank2
end

function doBeacons(autoBeacon, tank1, tank2, SB)
    if autoBeacon and talent(7, 2) and tank1 ~= nil then
        if tank1.buff(SB.BeaconofLight).down and tank1.distance <= 40 and not UnitIsDeadOrGhost("tank1") then
            return cast(SB.BeaconofLight, tank1)
        end
        if tank2 ~= nil and tank2.buff(SB.BeaconofFaith).down and tank2.distance <= 40 and not UnitIsDeadOrGhost("tank2") then
            return cast(SB.BeaconofFaith, tank2)
        end
    elseif tank1 ~= nil and talent(7, 1) and autoBeacon and tank1.buff(SB.BeaconofLight).down and tank1.distance <= 40 and not UnitIsDeadOrGhost("tank1") then
        return cast(SB.BeaconofLight, tank1)
    end
end