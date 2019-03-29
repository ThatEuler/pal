-- Vengeance Demon Hunter for 8.1 by Rex
-- version 1.3 - 22nd Jan 2019
-- Holding Shift = Infernal Strike to cursor

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.demonhunter

-- To Do
-- Add Consume Magic

--Spells not in spellbook

SB.SpiritBomb = 247454
SB.ImmolationAura = 178740
SB.Fracture = 263642
SB.SoulCleave = 228477
SB.SigilofFlame = 204596
SB.Shear = 203783
SB.ThrowGlaive = 204157
SB.InfernalStrike = 189110
SB.FieryBrand = 204021
SB.DemonSpikes = 203720
SB.Metamorphosis = 187827
SB.Torment = 185245
SB.FeedtheDemon = 218612
SB.Disrupt = 183752
SB.ConsumeMagic = 278326
SB.SoulBarrier = 263648
SB.SigilofChains = 202138
SB.SigilofMisery = 207684
SB.SigilofSilence = 202137
SB.FelDevastation = 212084
SB.Felblade = 232893

local function combat()
  if target.alive and target.enemy and player.alive and not player.channeling() then
    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch("vengdh_settings_intpercentlow", 50)
    local intpercenthigh = dark_addon.settings.fetch("vengdh_settings_intpercenthigh", 65)
    local FBHealth = dark_addon.settings.fetch("vengdh_settings_FBHealth", 60)
    local MMHealth = dark_addon.settings.fetch("vengdh_settings_MMHealth", 35)
    local DSHealth = dark_addon.settings.fetch("vengdh_settings_DSHealth", 30)
    local SBHealth = dark_addon.settings.fetch("vengdh_settings_SBHealth", 70)
    local SBSouls = dark_addon.settings.fetch("vengdh_settings_SBSouls", 4)
    local SCSouls = dark_addon.settings.fetch("vengdh_settings_SCSouls", 2)
    local GiftHealth = dark_addon.settings.fetch("vengdh_settings_GiftHealth", 20)
    local Hstonecheck = dark_addon.settings.fetch("vengdh_settings_healthstone.check", true)
    local Hstonepercent = dark_addon.settings.fetch("vengdh_settings_healthstone.spin", 20)

    -- Targets in range function
    local enemyCount = enemies.around(8)
    dark_addon.interface.status_extra("T#:" .. enemyCount .. " D:" .. target.distance)

    --# Executed every time the actor is available.
    --actions=auto_attack
    if target.enemy and target.alive and target.distance < 8 then
      auto_attack()
    end

    -- Infernal Strike IC
    if modifier.shift and castable(SB.InfernalStrike) then
      return cast(SB.InfernalStrike, "ground")
    end

    -- Interrupts
    -- Define random number for interrupt
    local intpercent = math.random(intpercentlow, intpercenthigh)

    -- Disrupt
    if
      toggle("interrupts", false) and castable(SB.Disrupt, "target") and -spell(SB.Disrupt) == 0 and
        target.interrupt(intpercent, false)
     then
      print("Interrupt @" .. intpercent)
      return cast(SB.Disrupt, "target")
    end

    --actions+=/call_action_list,name=defensives
    --actions.defensives=demon_spikes
    if
      castable(SB.DemonSpikes) and -spell(SB.DemonSpikes) == 0 and -player.health <= DSHealth and
        power.pain.deficit >= 30
     then
      print("Demon Spikes @" .. DSHealth)
      return cast(SB.DemonSpikes)
    end

    --actions.defensives+=/metamorphosis
    if castable(SB.Metamorphosis) and -spell(SB.Metamorphosis) == 0 and -player.health <= MMHealth then
      print("Metamorphosis @" .. MMHealth)
      return cast(SB.Metamorphosis)
    end

    --actions.defensives+=/fiery_brand
    if castable(SB.FieryBrand) and -spell(SB.FieryBrand) == 0 and -player.health <= FBHealth then
      print("Fiery Brand @" .. FBHealth)
      return cast(SB.FieryBrand)
    end

    --actions.defensives+=/soul_barrier
    if castable(SB.SoulBarrier) and -spell(SB.SoulBarrier) == 0 and -player.health <= SBHealth and talent(7, 3) then
      print("Soul Barrier @" .. SBHealth)
      return cast(SB.SoulBarrier)
    end

    --actions+=/consume_magic
    --# ,if=!raid_event.adds.exists|active_enemies>1
    --actions+=/use_item,slot=trinket1
    --# ,if=!raid_event.adds.exists|active_enemies>1
    --actions+=/use_item,slot=trinket2

    --# Fiery Brand Rotation
    if talent(3, 2) then
      --actions.brand=sigil_of_flame,if=cooldown.fiery_brand.remains<2
      if castable(SB.SigilofFlame) and target.distance <= 8 and -spell(SB.FieryBrand) < 2 then
        return cast(SB.SigilofFlame, "player")
      end

      --actions.brand+=/infernal_strike,if=cooldown.fiery_brand.remains=0
      if castable(SB.InfernalStrike) and -spell(SB.FieryBrand) == 0 then
        return cast(SB.InfernalStrike, "player")
      end

      --actions.brand+=/fiery_brand
      if castable(SB.FieryBrand) and -spell(SB.FieryBrand) == 0 then
        return cast(SB.FieryBrand)
      end

      --actions.brand+=/immolation_aura,if=dot.fiery_brand.ticking
      if
        castable(SB.ImmolationAura, "target") and -spell(SB.ImmolationAura) == 0 and target.distance < 8 and
          target.debuff(SB.FieryBrand).up
       then
        return cast(SB.ImmolationAura)
      end

      --actions.brand+=/fel_devastation,if=dot.fiery_brand.ticking
      if
        castable(SB.FelDevastation, "target") and -spell(SB.FelDevastation) == 0 and target.distance < 8 and
          target.debuff(SB.FieryBrand).up and
          talent(6, 3)
       then
        return cast(SB.FelDevastation, "target")
      end

      --actions.brand+=/infernal_strike,if=dot.fiery_brand.ticking
      if castable(SB.InfernalStrike) and target.debuff(SB.FieryBrand).up then
        return cast(SB.InfernalStrike, "player")
      end

      --actions.brand+=/sigil_of_flame,if=dot.fiery_brand.ticking
      if castable(SB.SigilofFlame) and target.distance <= 8 and target.debuff(SB.FieryBrand).up then
        return cast(SB.SigilofFlame, "player")
      end
    end

    --actions.normal+=/spirit_bomb,if=soul_fragments>=4
    if
      castable(SB.SpiritBomb, "target") and -spell(SB.SpiritBomb) == 0 and target.distance < 8 and
        buff(SB.SoulFragments).count >= SBSouls and
        power.pain.deficit <= 70 and
        talent(6, 2)
     then
      return cast(SB.SpiritBomb, "target")
    end

    --actions.normal+=/soul_cleave,if=!talent.spirit_bomb.enabled
    if
      castable(SB.SoulCleave, "target") and -spell(SB.SoulCleave) == 0 and target.distance < 8 and
        buff(SB.SoulFragments).count >= SCSouls and
        power.pain.deficit <= 70 and
        not talent(6, 2)
     then
      return cast(SB.SoulCleave, "target")
    end

    --actions.normal+=/soul_cleave,if=talent.spirit_bomb.enabled&soul_fragments=0
    if
      castable(SB.SoulCleave, "target") and -spell(SB.SoulCleave) == 0 and target.distance < 8 and
        buff(SB.SoulFragments).count == 0 and
        power.pain.deficit <= 70
     then
      return cast(SB.SoulCleave, "target")
    end

    --actions.normal+=/immolation_aura,if=pain<=90
    if
      castable(SB.ImmolationAura, "target") and -spell(SB.ImmolationAura) == 0 and target.distance < 8 and
        power.pain.deficit >= 10
     then
      return cast(SB.ImmolationAura)
    end

    --actions.normal+=/felblade,if=pain<=70
    if
      castable(SB.Felblade, "target") and -spell(SB.Felblade) == 0 and target.distance < 8 and power.pain.deficit >= 30 and
        talent(3, 3)
     then
      return cast(SB.Felblade)
    end

    --actions.normal+=/fracture,if=soul_fragments<=3
    if
      castable(SB.Fracture, "target") and -spell(SB.Fracture) == 0 and target.distance < 8 and
        buff(SB.SoulFragments).count <= 3 and
        talent(4, 3)
     then
      return cast(SB.Fracture, "target")
    end

    --actions.normal+=/fel_devastation
    if castable(SB.FelDevastation, "target") and -spell(SB.FelDevastation) == 0 and target.distance < 8 and talent(6, 3) then
      return cast(SB.FelDevastation, "target")
    end

    --actions.normal+=/sigil_of_chains
    if toggle("sigilofchains", false) then
      if castable(SB.SigilofChains) and target.distance <= 8 and talent(5, 3) then
        return cast(SB.SigilofChains, "player")
      end
    end

    --actions.normal+=/sigil_of_flame
    if castable(SB.SigilofFlame) and target.distance <= 8 and not talent(5, 3) then
      return cast(SB.SigilofFlame, "player")
    end

    --actions.normal+=/shear
    if castable(SB.Shear, "target") and -spell(SB.Shear) == 0 and target.distance < 8 and not talent(4, 3) then
      return cast(SB.Shear, "target")
    end

    --actions.normal+=/throw_glaive
    if castable(SB.ThrowGlaive, "target") and -spell(SB.ThrowGlaive) == 0 and target.distance <= 30 then
      return cast(SB.ThrowGlaive, "target")
    end
  end
end

local function resting()
  local enemyCount = enemies.around(8)
  dark_addon.interface.status_extra("T#:" .. enemyCount .. " D:" .. target.distance)

  -- Infernal Strike OOC
  if modifier.shift and castable(SB.InfernalStrike) then
    return cast(SB.InfernalStrike, "ground")
  end
end

local function interface()
  local settings = {
    key = "vengdh_settings",
    title = "Vengeance Demon Hunter",
    width = 300,
    height = 500,
    resize = true,
    show = false,
    template = {
      {type = "header", text = "            Rex's Vengeance Demon Hunter Settings"},
      {type = "text", text = "Everything on the screen is LIVE.  As you make changes, they are being fed to the engine"},
      {type = "text", text = "Suggested talents - 1 2 1 3 3 2 1"},
      {type = "text", text = "Toggle Sigil of Chains on interface for M+ runs"},
      {type = "text", text = "Shift Modifier used for Infernal Strike"},
      {type = "rule"},
      {type = "text", text = "Interrupt Settings"},
      {
        key = "intpercentlow",
        type = "spinner",
        text = "Interrupt Low %",
        default = "50",
        desc = "low% cast time to interrupt at",
        min = 5,
        max = 50,
        step = 1
      },
      {
        key = "intpercenthigh",
        type = "spinner",
        text = "Interrupt High %",
        default = "65",
        desc = "high% cast time to interrupt at",
        min = 51,
        max = 100,
        step = 1
      },
      {type = "text", text = "Defensive Settings"},
      {
        key = "FBHealth",
        type = "spinner",
        text = "Fiery Brand at Health %",
        default = "60",
        desc = "cast Fiery Brand at",
        min = 0,
        max = 100,
        step = 1
      },
      {
        key = "MMHealth",
        type = "spinner",
        text = "Metamorphosis at Health %",
        default = "35",
        desc = "cast Metamorphosis at",
        min = 0,
        max = 100,
        step = 1
      },
      {
        key = "DSHealth",
        type = "spinner",
        text = "Demon Spikes at Health %",
        default = "30",
        desc = "cast Demon Spikes at",
        min = 0,
        max = 100,
        step = 1
      },
      {
        key = "SBHealth",
        type = "spinner",
        text = "Soul Barrier at Health %",
        default = "70",
        desc = "cast Soul Barrier at",
        min = 0,
        max = 100,
        step = 1
      },
      {
        key = "healthstone",
        type = "checkspin",
        default = "20",
        text = "Healthstone",
        desc = "use Healthstone at health %",
        min = 1,
        max = 100,
        step = 1
      },
      {
        key = "GiftHealth",
        type = "spinner",
        text = "Gift of the Naaru at Health %",
        default = "20",
        desc = "cast Gift of the Naaru at",
        min = 0,
        max = 100,
        step = 1
      },
      {type = "text", text = "DPS Settings"},
      {
        key = "SBSouls",
        type = "spinner",
        text = "Spirit Bomb at Souls#",
        default = "4",
        desc = "cast Spirit Bomb at",
        min = 0,
        max = 5,
        step = 1
      },
      {
        key = "SCSouls",
        type = "spinner",
        text = "Soul Cleave at Souls#",
        default = "2",
        desc = "cast Soul Cleave at",
        min = 0,
        max = 5,
        step = 1
      }
    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(settings)

  dark_addon.interface.buttons.add_toggle(
    {
      name = "settings",
      label = "Rotation Settings",
      font = "dark_addon_icon",
      on = {
        label = dark_addon.interface.icon("cog"),
        color = dark_addon.interface.color.cyan,
        color2 = dark_addon.interface.color.dark_cyan
      },
      off = {
        label = dark_addon.interface.icon("cog"),
        color = dark_addon.interface.color.grey,
        color2 = dark_addon.interface.color.dark_grey
      },
      callback = function(self)
        if configWindow.parent:IsShown() then
          configWindow.parent:Hide()
        else
          configWindow.parent:Show()
        end
      end
    }
  )
  dark_addon.interface.buttons.add_toggle(
    {
      name = "sigilofchains",
      label = "Sigil of Chains",
      font = "dark_addon_icon",
      on = {
        label = dark_addon.interface.icon("toggle-on"),
        color = dark_addon.interface.color.cyan,
        color2 = dark_addon.interface.color.dark_cyan
      },
      off = {
        label = dark_addon.interface.icon("toggle-off"),
        color = dark_addon.interface.color.grey,
        color2 = dark_addon.interface.color.dark_grey
      }
    }
  )
end

-- This is what actually tells DR about your custom rotation
dark_addon.rotation.register(
  {
    spec = dark_addon.rotation.classes.demonhunter.vengeance,
    name = "vengdhpal",
    label = "Pal Project: Vengeance Demon Hunter",
    combat = combat,
    resting = resting,
    interface = interface
  }
)
