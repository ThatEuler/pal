local dark_addon = dark_interface

local SB = dark_addon.rotation.spellbooks.paladin
local EternalEmburfuryTalisman = 122667
local enemies_visible = {}
local race = UnitRace("player")
local count = 0
local function combat()

  --count = count+1
  --print("combat counter ", count)
  ------
  -- Self Heal
  ------
  -- Heirloom Necklace
  --[[
  local Neck2 = GetInventoryItemID("player", 2)
  if Neck2 == EternalEmburfuryTalisman
  and player.health.percent <= 75
  and (GetItemCooldown(EternalEmburfuryTalisman)) == 0 then
    return UseInventoryItem(2);
  end
  -- Flash Of Light
  if player.castable(SB.FlashofLight) and player.health.percent <= 66 then
    return cast(SB.FlashofLight, player)
  end
  ]]--
  ------
  -- Group Heal
  ------
  if GroupType() ~= "solo" and lowest.castable(SB.FlashofLight)
  and lowest.health.percent <= 33 then
    return cast(SB.FlashofLight, lowest)
  end

  -------
  -- debuff, stun, interrupt
  -------
  --print("check debuff, stun, interrupt")
  for unitID, unit in pairs(enemies_visible) do
    if unitID ~= nil and unit ~= nil
    and UnitExists(unitID) and UnitAffectingCombat(unitID) then
      --print(unit.name, " exists and is in combat")

      -- check if the unit can be debuffed
      if -spell(SB.ArcaneTorrent) == 0 then
        for i = 1, 40 do
          local name, _, _, _, _, _, _, _, _, spell_id = UnitBuff(unitID, i, "CANCELABLE")
          if spell_id ~= nil then
            print("unit ", unit.name, " has cancelable buff ", name)
            if race == "Blood Elf" and -spell(SB.ArcaneTorrent) == 0
            and unit.distance < 8 then
              return cast(SB.ArcaneTorrent)
            end
          end
        end
      end

      -- check if an enemy can be interrupted
      if toggle("interrupts", false) and -spell(SB.HammerofJustice) == 0 then
        -- check current target first.
        if target.interrupt() and target.distance < 10
        --and -spell(SB.Rebuke) > 0
        --and -spell(SB.BlindingLight) > 0
        then
          print("hammer ", unit.name, " to interrupt targeted caster")
          return cast(SB.HammerofJustice, "target")
        end
        -- then check all other attacking targets.
        local sp, _, _, st, et, _, _, notInterruptible = UnitCastingInfo(unitID)
        if sp ~= nil and not notInterruptible
        and IsSpellInRange("Hammer of Justice", unitID) then
          local pcntdone = ((GetTime()*1000)-st)/(et-st);
          print("unit ", unit.name, " is ", pcntdone, "% done casting ", sp)
          if pcntdone > 75.0 then
            --print("hammer ", unit.name, " to interrupt non target caster")
            --return cast(SB.HammerofJustice, unit)
          end
        end
      end

      -- check if attacking unit, that isn't the current target,
      -- can be stunned
      if not UnitIsUnit('target', unitID)
      and IsSpellInRange("Hammer of Justice", unitID)
      and -spell(SB.HammerofJustice) == 0 then
        --print("hammer ", unit.name, " to interrupt not target mob")
        --return cast(SB.HammerofJustice, unit)
      end
    end
  end

  ------
  -- Combat
  ------
  --print("check reg combat")

  -- BlessedHammer
  --[[
  if castable(SB.BlessedHammer)
  and enemies.around(10) > 0
  and -spell(SB.BlessedHammer) == 0 then
    return cast(SB.BlessedHammer)
  end ]]--

  -- Judgment
  if castable(SB.Judgment)
  and target.castable(SB.Judgment)
  and -spell(SB.Judgment) == 0 then
    return cast(SB.Judgment)
  end

  -- AvengersShield
  if castable(SB.AvengersShield)
  and target.castable(SB.AvengersShield)
  and -spell(SB.AvengersShield) == 0 then
    return cast(SB.AvengersShield)
  end

  -- ConsecrationProt
  if castable(SB.ConsecrationProt)
  and -spell(SB.ConsecrationProt) == 0
  and enemies.around(10) >= 2 then
    return cast(SB.ConsecrationProt)
  end

  -- HammerOfTheRighteous
  if castable(SB.HammerOfTheRighteous)
  and target.castable(SB.HammerOfTheRighteous)
  and -spell(SB.HammerOfTheRighteous) == 0 then
    return cast(SB.HammerOfTheRighteous)
  end

  if target.distance < 5 then
    return cast(SB.AutoAttack)
  end
  print("do nothing")

end


local function resting()
  ------------
  -- Self Heal
  ------------
  -- Heirloom Necklace
  local Neck2 = GetInventoryItemID("player", 2)
  if Neck2 == EternalEmburfuryTalisman
  and player.health.percent <= 75
  and (GetItemCooldown(EternalEmburfuryTalisman)) == 0 then
    return UseInventoryItem(2);
  end
  -- Flash Of Light
  if player.castable(SB.FlashofLight) and player.health.percent <= 66 then
    return cast(SB.FlashofLight, player)
  end

  ------
  -- Group Heal
  ------
  if GroupType() ~= "solo" and lowest.castable(SB.FlashofLight)
  and lowest.health.percent <= 66 then
    return cast(SB.FlashofLight, lowest)
  end

end


------
-- Maintain a list of enemies
-- make sure nameplates are always on
------
local function add_enemy(unitID)
  if not enemies_visible[unitID] and not UnitIsFriend("player", unitID) then
    local name = (UnitName(unitID))
    --print("adding: ", unitID, " name: ", name)
    enemies_visible[unitID] = dark_addon.environment.conditions.unit(unitID)
  end
end

local function remove_enemy(unitID)
  if enemies_visible[unitID] then
    local name = (UnitName(unitID))
    --print("removing: ", unitID, " name: ", name)
    enemies_visible[unitID] = nil
  end
end

dark_addon.event.register("NAME_PLATE_UNIT_ADDED", function(...)
  return add_enemy(...)
end)

dark_addon.event.register("NAME_PLATE_UNIT_REMOVED", function(...)
  return remove_enemy(...)
end)



dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.paladin.protection,
  name = 'myprotpal',
  label = 'prot paly',
  combat = combat,
  resting = resting
})
