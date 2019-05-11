
local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.druid
local DS = dark_addon.rotation.dispellbooks.soothe

SB.CelestialAlignment = 194223
SB.ChosenOfElune = 102560

local enemies_cache = {}

local nonemode = 0
local gcdmode = 1
local combatmode = 2
local restingmode = 3
local mode = nonemode
local moving_counter = 0
local stopped_counter = 0
local EHC_healing = 3567
local EHC_itemid = 122664
local SM_healing = 7621
local SwiftMendTooltip

local function findHealer()
  local members = GetNumGroupMembers()
  local group_type = GroupType()

  for i = 1, (members - 1) do
    local unit = group_type .. i

    if (UnitGroupRolesAssigned(unit) == "HEALER")
    and not UnitCanAttack("player", unit)
    and not UnitIsDeadOrGhost(unit)
    then
      return unit
    end
  end

  return "player"
end


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function GetSpellPower()
  local spellPower = GetSpellBonusDamage(2)
  for i=3,MAX_SPELL_SCHOOLS do
    spellPower = min(spellPower,(GetSpellBonusDamage(i)))
  end
  return spellPower
end

local function combat()
  if mode ~= combatmode then
  --  print ("in combat()")
    mode = combatmode
  end

  SM_healing = GetSpellPower() * (10014/2053)

  --- group_health_percent
  local group_health_percent = 100 * UnitHealth("player") / UnitHealthMax("player") or 0
  local group_health = group_health_percent
  local group_unit_count = IsInGroup() and GetNumGroupMembers() or 1
  local damaged_units = group_health_percent < 90 and 1 or 0
  local dead_units = 0
  for i = 1,group_unit_count-1 do
    local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
    local unit = IsInRaid() and "raid"..i or "party"..i
    local unit_health = 100 * UnitHealth(unit) / UnitHealthMax(unit) or 0
    if unit_health < 75 then
      damaged_units = damaged_units + 1
    end
    if isDead or not online or not UnitInRange(unit) then
      dead_units = dead_units + 1
    else
      group_health = group_health + unit_health
    end
  end
  group_health_percent = group_health / (group_unit_count - dead_units)

  -- Innervate self
  if IsInGroup()
  and UnitGroupRolesAssigned("player") == "HEALER"
  and player.castable(SB.Innervate)
  and player.power.mana.percent < 90 then
    return cast(SB.Innervate, player)
  end

  ------------
  -- Team Heal
  ------------
  if toggle("Group_Healing", false) then
    -- Use Wild Growth, when at least 4/6 members of the group/raid are damaged.
    if lowest.castable(SB.WildGrowth) and not player.moving
    and (not IsInRaid() and damaged_units >= 4 or damaged_units >= 6) then
      print("wildgrowth")
      return cast(SB.WildGrowth, lowest)
    end
    -- Tank
    if tank.castable(SB.Swiftmend) and tank.health.percent <= 50 then
      return cast(SB.Swiftmend, tank)
    end
    if not tank.buff(SB.Rejuvenation).up and tank.castable(SB.Rejuvenation)
    and tank.health.percent <= 50 then
      return cast(SB.Rejuvenation, tank)
    end
    -- lowest
    if lowest.castable(SB.Swiftmend) and lowest.health.percent <= 50 then
      return cast(SB.Swiftmend, lowest)
    end
    if not lowest.buff(SB.Rejuvenation).up and lowest.castable(SB.Rejuvenation)
    and lowest.health.percent <= 50 then
      return cast(SB.Rejuvenation, lowest)
    end
    -- regrowth
    if tank.castable(SB.Regrowth) and not player.moving and tank.health.percent <= 50 then
      return cast(SB.Regrowth, tank)
    end
    if lowest.castable(SB.Regrowth) and not player.moving and lowest.health.percent <= 50 then
      return cast(SB.Regrowth, lowest)
    end
  end

  ------------
  -- Self Heal
  ------------
  -- if swiftmend is availble, wait for the full effect.
  if (player.castable(SB.Swiftmend) and player.health.missing >= SM_healing)
  or (not player.castable(SB.Swiftmend))
  then
    if player.castable(SB.Swiftmend) and player.health.missing >= SM_healing then
      print("swiftmend. sm healing is ", SM_healing)
      return cast(SB.Swiftmend, player)
    end
    --Health Stone
    if player.health.percent < 75 and GetItemCount(5512) >= 1 and
        GetItemCooldown(5512) == 0
    then
      print("healthstone")
      macro("/use Healthstone")
    end
    if player.castable(SB.Barkskin) and player.health.percent < 90 then
      return cast(SB.Barkskin, player)
    end
    if player.castable(SB.Rejuvenation) and not player.buff(SB.Rejuvenation).up
    and player.health.percent < 66 then
      print("rejuvination")
      return cast(SB.Rejuvenation, player)
    end
    if player.castable(SB.Regrowth)
    and player.health.percent < 50
    and not player.moving then
      print("regrowth")
      return cast(SB.Regrowth, player)
    end
    if player.castable(SB.Regrowth)
    and not player.buff(SB.Regrowth).up
    and player.health.percent < 75
    and not player.moving then
      print("regrowth")
      return cast(SB.Regrowth, player)
    end
  end

  -----------------------------
  ---     Innervate
  -----------------------------

  if IsInGroup() and player.castable(SB.Innervate) then
    local iTarget = dark_addon.environment.conditions.unit(findHealer())
    if iTarget.unitID ~= "player" and iTarget.distance <= 45 then
      print("Innervate on " .. iTarget.name)
      return cast(SB.Innervate, iTarget)
    end
  end

  -- become moonkin
  if not player.moving and castable(SB.MoonkinForm) and player.buff(SB.MoonkinForm).down then
    return cast(SB.MoonkinForm)
  end

  --[[
  ------------------
  -- Targeting logic
  ------------------
  if not (target.exists and target.alive and target.enemy) then
    print("looking for target")
    for unit, _ in pairs(enemies_cache) do
      if UnitAffectingCombat(unit) then
        print("will target ", UnitName(unit))
        TargetUnit(unit)
        return
      end
    end
  end

  -----
  -- Try to keep debufs on all attacking mobs
  -----
  for unit, _ in pairs(enemies_cache) do
    local hasMF = false;
    local hasSF = false;
    if UnitAffectingCombat(unit) then
      for i = 0, 40 do
        local name, _, _, _, _, _, _, _, _, _, spellId = UnitDebuff(unit, i)
        if name and spellId == SB.Moonfire then
          hasMF = true;
        end
        if name and spellId == SB.Sunfire then
          hasSF = true;
        end
      end
      if not hasMF and IsSpellInRange(SB.Moonfire, unit) then
        TargetUnit(unit)
        CastSpell(SB.Moonfire, "spell")
        TargetLastEnemy()
      end
      if not hasSF and IsSpellInRange(SB.Sunfire, unit) then
        TargetUnit(unit)
        CastSpell(SB.Sunfire, "spell")
        TargetLastEnemy()
      end
    end
  end
  ]]--



  ---------
  -- Attack
  ---------

  -- if i don't have a target. don't attack
  if target.exists and target.alive and target.enemy then

    -- interrupt
    if target.interrupt() and target.distance <= 45 and target.castable(SB.SolarBeam) and not player.moving then
      print("Interrupting " .. target.name)
      return cast(SB.SolarBeam, "target")
    end

    --soothe
    if target.castable(SB.Soothe) then
      for i = 1, 40 do
        local name, _, _, count, debuff_type, _, _, _, _, spell_id = UnitAura("target", i)
        if name and DS[spell_id] then
          print("Soothing " .. name .. " off the target.")
          return cast(SB.Soothe, "target")
        end
      end
    end

    -- player wants to use starfall
    if modifier.lshift
    and -spell(SB.Starfall) == 0
    and power.astral.actual >= 50 then
      return cast(SB.Starfall, "ground")
    end

    -- boss fight mode
    if toggle("Chosen_of_Elune", false)
    and player.buff(SB.ChosenOfElune).down
    and castable(SB.ChosenOfElune)
    and power.astral.actual >= 40 then
      return cast(SB.ChosenOfElune, "player")
    end

    -- fury of elune
    if talent(7, 2) and castable(SB.FuryofElune) then
      return cast(SB.FuryofElune, "target")
    end
    -- keep Moonfire on the target
    if castable(SB.Moonfire) and not target.debuff(SB.Moonfire).up then
      return cast(SB.Moonfire, "target")
    end
    if castable(SB.Moonfire) and player.moving and not lastcast(SB.Moonfire) then
      return cast(SB.Moonfire, "target")
    end
    -- keep Sunfire on the target
    if castable(SB.Sunfire) and not target.debuff(SB.Sunfire).up then
      return cast(SB.Sunfire, "target")
    end
    if castable(SB.Sunfire) and player.moving and not lastcast(SB.Sunfire) then
      return cast(SB.Sunfire, "target")
    end

    if not player.moving then

      -- cast Starsurge to consume astral power
      if castable(SB.Starsurge) and power.astral.actual >= 40
      and player.buff(SB.SolarEmpowerment).count < 3
      and player.buff(SB.LunarEmpowerment).count < 3
      and not modifier.lshift  -- lshift means i'm charging up for starfall
      then
        return cast(SB.Starsurge, "target")
      end

      -- cast lunarstrike if i have lunar empowerment
      if castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 then
        return cast(SB.LunarStrike, "target")
      end

      -- cast solarwrath
      if castable(SB.SolarWrath) then
        return cast(SB.SolarWrath, "target")
      end
    end
  end
end

local function resting()
  if mode ~= restingmode then
  --  print ("in resting()")
    mode = restingmode
  end

  if not player.alive then
    return
  end

  if not SwiftMendTooltip then
    SwiftMendTooltip = CreateFrame("GameTooltip","SwiftMendTooltip",UIParent,"GameTooltipTemplate")
    SwiftMendTooltip:SetOwner(UIParent,"ANCHOR_NONE")
  end
  --if (SwiftMendTooltip:SetSpellByID(SB.Swiftmend)) then
  --  print("frame: ", tostring(SwiftMendTooltip))
  --  print("text: ", SwiftMendTooltip:GetText())
  --end
  --print("frame: ", tostring(SwiftMendTooltip))

  --local heal = tonumber(SwiftMendTooltipTextLeft4:GetText():match("Instantly heals a friendly target for up to (.-)."):gsub(",",""))
  --print("heal: ", heal)

  ------------
  -- Self Heal
  ------------
  -- heirloom necklace
  local GearSlot2 = GetInventoryItemID("player", 2)
  local starttime, duration, _ = GetItemCooldown(GearSlot2)
  if (IsUsableItem(GearSlot2))
  and starttime == 0
  and player.health.percent <= 75
  then
    print ("Using necklace heal")
    macro("/use 2")
    return
  end

  -- if my health is low. cast regrowth
  if player.castable(SB.Regrowth) and not player.buff(SB.Regrowth).up and player.health.percent < 75 then
    return cast(SB.Regrowth, player)
  end
  if player.castable(SB.Regrowth) and player.health.percent < 50 then
    return cast(SB.Regrowth, player)
  end

  -------------
  -- Auto Attack
  -------------
  --for unit, _ in pairs(enemies_cache) do
  --  if not UnitIsDead(unit) then
  --    TargetUnit(unit)
  --    return cast(SB.SolarWrath, "target")
  --  end
  --end

  --------------
  -- Auto set travel form
  --------------
  local outdoors = IsOutdoors()
  if outdoors then
    travelbuff = SB.TravelForm
  else
    travelbuff = SB.CatForm
  end
  -- auto start cat or travel form
  if toggle("Auto_Travel_Form", false) then
    if player.moving and player.buff(travelbuff).down and moving_counter < 15  then
      moving_counter = moving_counter + 1
    end
    if not player.moving then
      moving_counter = 0
    end
    if player.moving and player.buff(travelbuff).down and moving_counter >= 15 then
      return cast(travelbuff)
    end
  end

  -- auto leave cat form
  if toggle("Auto_Travel_Form", false) then
    if not player.moving and player.buff(SB.CatForm).up and stopped_counter < 8  then
      stopped_counter = stopped_counter + 1
    end
    if player.moving then
      stopped_counter = 0
    end
    if not player.moving and player.buff(SB.CatForm).up and stopped_counter >= 8 then
      return cast(SB.CatForm)
    end
  end

end

local function interface()
  dark_addon.interface.buttons.add_toggle(
    {
      name = "Auto_Travel_Form",
      label = "Auto change between travel form and normal form",
      on = {
        label = "Auto Travel Enabled",
        color = dark_addon.interface.color.orange,
      },
      off = {
        label = "Auto Travel Disabled",
        color = dark_addon.interface.color.grey,
      }
    }
  )

  dark_addon.interface.buttons.add_toggle(
    {
      name = "Chosen_of_Elune",
      label = "Use Chosen of Elune when in combat",
      on = {
        label = "CoE Enabled",
        color = dark_addon.interface.color.orange,
      },
      off = {
        label = "CoE Disabled",
        color = dark_addon.interface.color.grey,
      }
    }
  )

  dark_addon.interface.buttons.add_toggle(
    {
      name = "Group_Healing",
      label = "Enable group healing",
      on = {
        label = "Group Healing Enabled",
        color = dark_addon.interface.color.orange,
      },
      off = {
        label = "Group Healing Disabled",
        color = dark_addon.interface.color.grey,
      }
    }
  )

end

local function add_enemy(unitID)
  if not enemies_cache[unitID] and not UnitIsFriend("player", unitID) then
    local name, _ = UnitName(unitID)
    --print("adding: ", name)
    enemies_cache[unitID] = dark_addon.environment.conditions.unit(unitID)
  end
end

local function remove_enemy(unitID)
  if enemies_cache[unitID] then
    local name, _ = UnitName(unitID)
    --print("removing: ", name)
    enemies_cache[unitID] = nil
  end
end

dark_addon.event.register("NAME_PLATE_UNIT_ADDED", function(...)
  return add_enemy(...)
end)

dark_addon.event.register("NAME_PLATE_UNIT_REMOVED", function(...)
  return remove_enemy(...)
end)

dark_addon.rotation.register(
  {
    spec = dark_addon.rotation.classes.druid.balance,
    name = "faker",
    label = "faker",
    combat = combat,
    resting = resting,
    interface = interface
  }
)
