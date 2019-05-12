local dark_addon = dark_interface

-- replace dark_addon.rotation.spellbooks.class
-- with the appropriate value for your class
-- ex: dark_addon.rotation.spellbooks.mage
local SB = dark_addon.rotation.spellbooks.warrior
SB.VictoryRushBuff = 32216
local EternalEmburfuryTalisman = 122667

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

  ---------
  -- Combat
  ---------

  -- Charge
  if target.castable(SB.Charge)
     and -spell(SB.Charge) == 0 then
    return cast(SB.Charge, target)
  end

  -- Shield Slam
  if target.castable(SB.ShieldSlam)
     and -spell(SB.ShieldSlam) == 0 then
    return cast(SB.ShieldSlam, target)
  end

  -- Devastate
  if target.castable(SB.Devastate)
     and -spell(SB.Devastate) == 0 then
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

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.warrior.protection,
  name = 'myprot',
  label = 'My Awesome Rotation',
  combat = combat,
  resting = resting,
  interface = interface
})
