local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.priest

-------------
---Spells---
-------------
SB.GiftOftheNaaru = 59544
SB.MendingBuff = 41635


local function combat()

-------------
--Modifiers--
-------------
    if modifier.alt and castable(SB.MassDispell) then
      return cast(SB.MassDispell, ground)
    end

    if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
      return cast(SB.AngelicFeather, player)
    end

    if modifier.control and castable(SB.DivineHymn) then
      return cast(SB.DivineHymn)
    end

-------------
---Dispel----
-------------
    if toggle('dispel', false) and castable(SB.Purify) and player.dispellable(SB.Purify) then
        return cast(SB.Purify, "player")
    end
    local unit = group.dispellable(SB.Purify)
    if unit and unit.distance < 40 then
        return cast(SB.Purify, unit)
    end



end
local function resting()

-------------
--Modifiers--
-------------
    if modifier.alt and castable(SB.MassDispell) then
      return cast(SB.MassDispell, ground)
    end

    if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
      return cast(SB.AngelicFeather, player)
    end
-------------
----Buff-----
-------------
    local allies_without_my_buff = group.count(function (unit)
        return unit.alive and unit.distance < 40 and unit.buff(SB.PowerWordFortitude).down
    end)
    if allies_without_my_buff > 2 and castable(SB.PowerWordFortitude) then
        return cast(SB.PowerWordFortitude, 'player')
    end

    if player.buff(SB.PowerWordFortitude).down and castable(SB.PowerWordFortitude) then
        return cast(SB.PowerWordFortitude, 'player')
    end

    
end

function interface()
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.priest.holy,
    name = 'holypal',
    label = 'PAL: Holy Priest',
    combat = combat,
    resting = resting,
    interface = interface
})
