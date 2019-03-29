--support functions etc.
local dark_addon = dark_interface
dark_addon.support = {}
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

function GroupType()
  return IsInRaid() and "raid" or IsInGroup() and "party" or "solo"
end

function getTanks()
  local tank1 = nil
  local tank2 = nil

  local group_type = GroupType()
  local members = GetNumGroupMembers()
  for i = 1, (members - 1) do
    local unit = group_type .. i
    if (UnitGroupRolesAssigned(unit) == "TANK") and not UnitCanAttack("player", unit) and not UnitIsDeadOrGhost(unit) then
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
  elseif
    tank1 ~= nil and talent(7, 1) and autoBeacon and tank1.buff(SB.BeaconofLight).down and tank1.distance <= 40 and
      not UnitIsDeadOrGhost("tank1")
   then
    return cast(SB.BeaconofLight, tank1)
  end
end

function GroupType()
  return IsInRaid() and "raid" or IsInGroup() and "party" or "solo"
end

function hasBuff(unit, buff)
  for i = 1, 40 do
    local _, _, _, _, _, _, _, _, _, spell_id = UnitBuff(unit, i)
    if spell_id == nil then
      break
    end
    if spell_id == buff then
      return true
    end
  end
  return false
end

function castGroupBuff(buff, min)
  local count = 0
  local group_type = GroupType()
  local members = GetNumGroupMembers()
  if group_type == "solo" then
    return min == 1 and not hasBuff("player", buff)
  end
  for i = 1, (members - 1) do
    if not hasBuff(group_type .. i, buff) then
      count = count + 1
      if (count >= min) then
        return true
      end
    end
  end
  return false
end
