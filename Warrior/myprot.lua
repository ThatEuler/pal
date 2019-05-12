local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warrior
SB.VictoryRushBuff = 32216
local EternalEmburfuryTalisman = 122667
local enemies_visible = {}
local race = UnitRace("player")

local function combat()
  -- some quick sanity checks before we pew pew
  --if not target.alive or not target.enemy or player.channeling then return end

  -- Boss Mode
  if toggle("Boss_Mode", false) then
    if race == "Troll" and -spell(SB.Berserking) == 0 then
      cast(SB.Berserking)
    end
  end

  ------------
  -- Self Heal
  ------------

  -- Heirloom Necklace
  local Neck2 = GetInventoryItemID("player", 2)
  if Neck2 == EternalEmburfuryTalisman
  and player.health.percent <= 85
  and (GetItemCooldown(EternalEmburfuryTalisman)) == 0 then
    UseInventoryItem(2);
  end

  -- Victory Rush
  if player.buff(SB.VictoryRushBuff).up
     and -spell(SB.VictoryRush) == 0
     and target.castable(SB.VictoryRush) then
    return cast(SB.VictoryRush, target)
  end

  ---------------
  -- Auto Taunt
  -- Aggro all the enemies
  -- This code isn't well tested.
  -- It seems that UnitThreatSituation() always returns nil
  -- TODO if this is slow in raids.
  -- check healers for any agro
  --  check al mos against the healer
  -- check all dps for any agro
  --  check all mobs against the healer
  -- also. put it in the gcd.
  ---------------
  if -spell(SB.Taunt) == 0 or -spell(SB.HeroicThrow) then
    local members = GetNumGroupMembers()
    local group_type = GroupType()
    -- for each party member, and each enemy, check if
    -- they are tanking. if yes, taunt the enemy.
    if group_type ~= 'solo' then
      local member = group_type .. i
      for i = 1, (members - 1) do
        if UnitGroupRolesAssigned(member) ~= "TANK" then
          for unitID, unitName in pairs(enemies_visible) do
            if UnitExists(unitID) and UnitAffectingCombat(unitID) then
              isTanking = UnitThreatSituation(member, unitID)
              if isTanking == 0 then
                print((UnitName(member)), " is tanking with ", unitName)
                if -spell(SB.HeroicThrow) and IsSpellInRange('Heroic Throw', unitID) then
                  return case(SB.HeroicThrow, unitID)
                end
                if -spell(SB.Taunt) and IsSpellInRange('Taunt', unitID) then
                  return cast(SB.Taunt, unitID)
                end
              end
            end
          end
        end
      end
    end
  end

  ---------
  -- Combat
  ---------

  -- Charge
  if castable(SB.Charge)
  and target.castable(SB.Charge)
  and -spell(SB.Charge) == 0
  then
    return cast(SB.Charge, target)
  end

  -- Shield Block
  if castable(SB.ShieldBlock)
  and -spell(SB.ShieldBlock) == 0
  and -power.rage >= 30
  and target.time_to_die > 6
  and player.buff(SB.ShieldBlockBuff).down
  then
    return cast(SB.ShieldBlock)
  end

  -- ThunderClap
  if castable(SB.ThunderClap)
  and -spell(SB.ThunderClap) == 0 then
    return cast(SB.ThunderClap)
  end

  -- Shield Slam
  if castable(SB.ShieldSlam)
  and target.castable(SB.ShieldSlam)
  and -spell(SB.ShieldSlam) == 0
  then
    return cast(SB.ShieldSlam, target)
  end

  -- Devastate
  if castable(SB.Devastate)
  and target.castable(SB.Devastate)
  and -spell(SB.Devastate) == 0
  then
    return cast(SB.Devastate, target)
  end

end

local function resting()

  if not player.alive then return end

  -- Heirloom Necklace
  local Neck2 = GetInventoryItemID("player", 2)
  if Neck2 == EternalEmburfuryTalisman
  and player.health.percent <= 85
  and (GetItemCooldown(EternalEmburfuryTalisman)) == 0 then
    UseInventoryItem(2);
  end
end


local function interface()
  dark_addon.interface.buttons.add_toggle(
    {
      name = "Boss_Mode",
      label = "Boss Mode",
      on = {
        label = "Boss Mode",
        color = dark_addon.interface.color.green,
      },
      off = {
        label = "Boss Mode",
        color = dark_addon.interface.color.grey,
      }
    }
  )
end

------
-- Maintain a list of enemies
-- make sure nameplates are always on
------
local function add_enemy(unitID)
  if not enemies_visible[unitID] and not UnitIsFriend("player", unitID) then
    local name, _ = UnitName(unitID)
    --print("adding: ", unitID, " name: ", name)
    enemies_visible[unitID] = dark_addon.environment.conditions.unit(unitID)
  end
end

local function remove_enemy(unitID)
  if enemies_visible[unitID] then
    local name, _ = UnitName(unitID)
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


-----------
-- Register
-----------

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.warrior.protection,
  name = 'myprot',
  label = 'Prot Warrior <= level 20',
  combat = combat,
  resting = resting,
  interface = interface
})
