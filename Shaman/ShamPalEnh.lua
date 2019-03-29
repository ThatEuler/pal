local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.shaman

-- To Do

-- Spells

SB.CrashLightning = 187874
SB.FuryofAir = 197211
SB.TotemMastery = 262395
SB.Windstrike = 115356
SB.Ascendance = 114051
SB.Flametongue = 193796
SB.FeralSpirit = 51533
SB.EarthenSpike = 188089
SB.Frostbrand = 196834
SB.Hailstorm = 210853
SB.Stormstrike = 17364
SB.Stormbringer = 201845
SB.LavaLash = 60103
SB.HotHand = 201900
SB.Rockbiter = 193786
SB.LightningBolt = 187837
SB.SearingAssault = 192087
SB.Sundering = 197214
SB.PrimalPrimer = 272992
SB.ElementalSpirits = 262624
SB.StrengthofEarth = 273461
SB.Overcharge = 210727
SB.Landslide = 197992
SB.CrashingStorm = 192246
SB.Windfury = 33757
SB.ForcefulWinds = 262647
SB.FeralLunge = 196884
SB.WindRushTotem = 192077
SB.NaturesGuardian = 30884
SB.MoltenWeapon = 271924
SB.IcyEdge = 271920
SB.HealingSurge = 188070
SB.WindShear = 57994
SB.ResonanceTotem = 262417
SB.StormTotem = 262397
SB.EmberTotem = 262399
SB.TailwindTotem = 262400
SB.LightningShield = 192106
SB.EarthShield = 974
SB.FeralLunge = 196884
SB.AstralShift = 108271

local function combat()
  if target.alive and target.enemy and player.alive and not player.channeling() then
    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch("enhsha_settings_intpercentlow", 50)
    local intpercenthigh = dark_addon.settings.fetch("enhsha_settings_intpercenthigh", 65)
    local primalprimerbuild = dark_addon.settings.fetch("enhsha_settings_primalprimerbuild")
    local stormstrikebuild = dark_addon.settings.fetch("enhsha_settings_stormstrikebuild")
    local HSHealth = dark_addon.settings.fetch("enhsha_settings_HSHealth", 60)
    local ASHealth = dark_addon.settings.fetch("enhsha_settings_ASHealth", 20)
    local GiftHealth = dark_addon.settings.fetch("enhsha_settings_GiftHealth", 20)
    local Hstonecheck = dark_addon.settings.fetch("enhsha_settings_healthstone.check", true)
    local Hstonepercent = dark_addon.settings.fetch("enhsha_settings_healthstone.spin", 20)
    local race = UnitRace("player")

    -- Targets in range check
    local enemyCount = enemies.around(8)
    if enemyCount == 0 then
      enemyCount = 1
    end
    dark_addon.interface.status_extra("T#:" .. enemyCount .. " D:" .. target.distance)

    -- Use Racials
    --    if toggle('useracials', false) then
    --      if race == "Orc" and castable(SB.BloodFury) then
    --        return cast(SB.BloodFury)
    --      end
    --      if race == "Troll" and castabe(SB.Berserking) then
    --        return cast(SB.Berserking)
    --      end
    --      if race == "Mag'har Orc" and castable(SB.AncestralCall) then
    --        return cast(SB.AncestralCall)
    --      end
    --      if race == "LightforgedDraenei" and castable(SB.LightsJudgement) then
    --        return cast(SB.LightsJudgement)
    --      end
    --      if race == "Draenei" and -player.health <= GiftHealth then
    --        return cast(SB.GiftoftheNaaru)
    --      end
    --    end

    -- Auto Attack
    if target.enemy and target.alive and target.distance < 8 then
      auto_attack()
    end

    -- FeralLunge IC
    if modifier.shift and castable(SB.FeralLunge) and talent(5, 2) and target.distance < 25 then
      return cast(SB.FeralLunge, "target")
    end

    -- Interrupts
    -- Define random number for interrupt
    local intpercent = math.random(intpercentlow, intpercenthigh)

    -- Wind Shear
    if
      toggle("interrupts", false) and castable(SB.WindShear, "target") and -spell(SB.WindShear) == 0 and
        target.interrupt(intpercent, false) and
        target.distance < 30
     then
      print("Interrupt @ " .. intpercent)
      return cast(SB.WindShear, "target")
    end

    -- Healing
    if castable(SB.HealingSurge) and -player.health <= HSHealth then
      print("Healing Surge @ " .. HSHealth)
      return cast(SB.HealingSurge)
    end

    -- Defensives
    if castable(SB.AstralShift) and -player.health <= ASHealth then
      print("Astral Shift @ " .. ASHealth)
      return cast(SB.AstralShift)
    end

    -- Healthstone
    if Hstonecheck == true and -player.health < Hstonepercent and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
      macro("/use Healthstone")
    end

    if primalprimerbuild == true then
      --Primal Primer Rotation
      --Cast Crash Lightning if two or more targets are in range and the buff has less than 2 seconds remaining (or is inactive).
      if
        castable(SB.CrashLightning) and -spell(SB.CrashLightning) == 0 and enemyCount >= 2 and
          (not player.buff(SB.CrashLightning).up or player.buff(SB.CrashLightning).remains <= 2)
       then
        return cast(SB.CrashLightning)
      end

      --Cast Lava Lash if your target has 10 stacks of Primal Primer
      if castable(SB.LavaLash) and -spell(SB.LavaLash) == 0 and target.debuff(SB.PrimalPrimer).count >= 10 then
        return cast(SB.LavaLash)
      end

      --Cast Totem Mastery if the buff is down or will expire within the next 3 seconds.
      if
        castable(SB.TotemMastery) and -spell(SB.TotemMastery) == 0 and talent(2, 3) and not (-buff(SB.ResonanceTotem)) and
          not (-buff(SB.StormTotem)) and
          not (-buff(SB.EmberTotem)) and
          not (-buff(SB.TailwindTotem))
       then
        return cast(SB.TotemMastery)
      end

      --Cast Sundering if two or more targets are in range.
      if castable(SB.Sundering) and -spell(SB.Sundering) == 0 and enemyCount >= 2 then
        return cast(SB.Sundering)
      end

      --Cast Flametongue if the buff is not active.
      if castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 and not player.buff(SB.Flametongue).up then
        return cast(SB.Flametongue)
      end

      --Cast Frostbrand if the buff is not active to maintain the Hailstorm effect.
      if castable(SB.Frostbrand) and -spell(SB.Frostbrand) == 0 and not player.buff(SB.Frostbrand).up then
        return cast(SB.Frostbrand)
      end

      --Cast Feral Spirit if available.
      if castable(SB.FeralSpirit) and -spell(SB.FeralSpirit) == 0 then
        return cast(SB.FeralSpirit)
      end

      --Cast Stormstrike with a Stormbringer proc.
      if castable(SB.Stormstrike) and -spell(SB.Stormstrike) == 0 and player.buff(SB.Stormbringer).up then
        return cast(SB.Stormstrike)
      end

      --Cast Lava Lash if your target has 7 or more stacks of Primal Primer
      if castable(SB.LavaLash) and -spell(SB.LavaLash) == 0 and target.debuff(SB.PrimalPrimer).count >= 7 then
        return cast(SB.LavaLash)
      end

      --Cast Stormstrike without a Stormbringer proc active.
      if castable(SB.Stormstrike) and -spell(SB.Stormstrike) == 0 then
        return cast(SB.Stormstrike)
      end

      --Cast Rockbiter
      if castable(SB.Rockbiter) and -spell(SB.Rockbiter) == 0 then
        return cast(SB.Rockbiter)
      end

      --Cast Flametongue if less than 4.5 seconds of the buff remains.
      if castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 and player.buff(SB.Flametongue).remains <= 4.5 then
        return cast(SB.Flametongue)
      end

      --Cast Frostbrand if less than 4.5 seconds of the buff remains.
      if castable(SB.Frostbrand) and -spell(SB.Frostbrand) == 0 and player.buff(SB.Frostbrand).remains <= 4.5 then
        return cast(SB.Frostbrand)
      end

      --Cast Flametongue
      if castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 then
        return cast(SB.Flametongue)
      end
    end

    if stormstrikebuild == true then
      --Stormstrike Rotation
      --Cast Fury of Air if not active (with Fury of Air talent)
      if castable(SB.FuryofAir) and -spell(SB.FuryofAir) == 0 and not player.buff(SB.FuryofAir).up and talent(6, 2) then
        return cast(SB.FuryofAir)
      end

      --Cast Totem Mastery if not active
      if
        castable(SB.TotemMastery) and -spell(SB.TotemMastery) == 0 and talent(2, 3) and not (-buff(SB.ResonanceTotem)) and
          not (-buff(SB.StormTotem)) and
          not (-buff(SB.EmberTotem)) and
          not (-buff(SB.TailwindTotem))
       then
        return cast(SB.TotemMastery)
      end

      --Cast Crash Lightning Icon Crash Lightning if 2 targets are in range and the buff is not present.
      if
        castable(SB.CrashLightning) and -spell(SB.CrashLightning) == 0 and enemyCount >= 2 and
          not player.buff(SB.CrashLightning).up
       then
        return cast(SB.CrashLightning)
      end

      --Cast Windstrike during Ascendance (with Ascendance talent)
      if castable(SB.Windstrike) and -spell(SB.Windstrike) == 0 and player.buff(SB.Ascendance).up then
        return cast(SB.Windstrike)
      end

      --Cast Flametongue if the buff is not active.
      if castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 and not player.buff(SB.Flametongue).up then
        return cast(SB.Flametongue)
      end

      --Cast Feral Spirit on cooldown.
      if castable(SB.FeralSpirit) and -spell(SB.FeralSpirit) == 0 then
        return cast(SB.FeralSpirit)
      end

      --Cast Earthen Spike (with Earthen Spike talent)
      if castable(SB.EarthenSpike) and -spell(SB.EarthenSpike) == 0 and talent(7, 2) then
        return cast(SB.EarthenSpike)
      end

      --Cast Frostbrand if not active Hailstorm effect (with Hailstorm talent)
      if castable(SB.Frostbrand) and -spell(SB.Frostbrand) == 0 and talent(4, 2) then
        return cast(SB.Frostbrand)
      end

      --Cast Ascendance (with Ascendance talent)
      if toggle("cooldowns", false) and castable(SB.Ascendance) and -spell(SB.Ascendance) == 0 and talent(7, 3) then
        return cast(SB.Ascendance)
      end

      --Cast Stormstrike with a Stormbringer proc (with Hot Hand talent)
      if castable(SB.Stormstrike) and -spell(SB.Stormstrike) == 0 and player.buff(SB.Stormbringer).up and talent(1, 2) then
        return cast(SB.Stormstrike)
      end

      --Cast Lava Lash with Hot Hand procs
      if castable(SB.LavaLash) and -spell(SB.LavaLash) == 0 and player.buff(SB.HotHand).up and talent(1, 2) then
        return cast(SB.LavaLash)
      end

      --Cast Stormstrike with or without Stormbringer (without Hot Hand talent)
      if castable(SB.Stormstrike) and -spell(SB.Stormstrike) == 0 and not talent(1, 2) then
        return cast(SB.Stormstrike)
      end

      --Cast Crash Lightning if 3 targets are in range.
      if castable(SB.CrashLightning) and -spell(SB.CrashLightning) == 0 and enemyCount >= 3 then
        return cast(SB.CrashLightning)
      end

      --Cast Rockbiter if at 2 charges (with Landslide talent)
      if castable(SB.Rockbiter) and -spell(SB.Rockbiter) == 0 and spell(SB.Rockbiter).charges == 2 and talent(2, 1) then
        return cast(SB.Rockbiter)
      end

      --Cast Lightning Bolt if above 40 Maelstrom (50 with Fury of Air) with Overcharge talent.
      if
        castable(SB.LightningBolt) and -spell(SB.LightningBolt) == 0 and talent(4, 3) and
          (player.power.maelstrom.actual > 40 or (player.power.maelstrom.actual > 40 and talent(6, 2)))
       then
        return cast(SB.LightningBolt)
      end

      --Cast Flametongue regardless of buff duration to trigger Searing Assault (with Searing Assault talent)
      if castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 and talent(4, 1) then
        return cast(SB.Flametongue)
      end

      --Cast Sundering (with Sundering talent)
      if castable(SB.Sundering) and -spell(SB.Sundering) == 0 and talent(6, 3) then
        return cast(SB.Sundering)
      end

      --Cast Rockbiter if below 70 Maelstrom and about to reach 2 charges.
      if castable(SB.Rockbiter) and -spell(SB.Rockbiter) == 0 and player.power.maelstrom.actual < 70 then
        return cast(SB.Rockbiter)
      end

      --Cast Frostbrand with Hailstorm taken and the buff has less than 4.5 seconds remaining.
      if
        castable(SB.Frostbrand) and -spell(SB.Frostbrand) == 0 and player.buff(SB.Frostbrand).remains <= 4.5 and
          talent(4, 2)
       then
        return cast(SB.Frostbrand)
      end

      --Cast Flametongue if the buff has less than 4.5 seconds remaining.
      if
        castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 and player.buff(SB.Flametongue).remains <= 4.5 and
          not talent(4, 1)
       then
        return cast(SB.Flametongue)
      end

      --Cast Crash Lightning if 2 targets are in range.
      if castable(SB.CrashLightning) and -spell(SB.CrashLightning) == 0 and enemyCount >= 2 then
        return cast(SB.CrashLightning)
      end

      --Cast Crash Lightning on cooldown (with Crashing Storms talent)
      if castable(SB.CrashLightning) and -spell(SB.CrashLightning) == 0 and talent(6, 1) then
        return cast(SB.CrashLightning)
      end

      --Cast Lava Lash if above 40 Maelstrom (50 with Fury of Air taken)
      if
        castable(SB.LavaLash) and -spell(SB.LavaLash) == 0 and
          (player.power.maelstrom.actual > 40 or (player.power.maelstrom.actual > 40 and talent(6, 2)))
       then
        return cast(SB.LavaLash)
      end

      --Cast Rockbiter
      if castable(SB.Rockbiter) and -spell(SB.Rockbiter) == 0 then
        return cast(SB.Rockbiter)
      end

      --Cast Flametongue with nothing else available.
      if castable(SB.Flametongue) and -spell(SB.Flametongue) == 0 and not talent(4, 1) then
        return cast(SB.Flametongue)
      end
    end
  end
end

local function resting()
  local enemyCount = enemies.around(8)
  dark_addon.interface.status_extra("T#:" .. enemyCount .. " D:" .. target.distance)

  --Lightning Shield OOC
  if
    castable(SB.LightningShield) and -spell(SB.LightningShield) == 0 and not player.buff(SB.LightningShield).up and
      talent(1, 3)
   then
    return cast(SB.LightningShield, "player")
  end

  --Earth Shield OOC
  if castable(SB.EarthShield) and -spell(SB.EarthShield) == 0 and not player.buff(SB.EarthShield).up and talent(3, 2) then
    return cast(SB.EarthShield, "player")
  end

  -- FeralLunge OOC
  if modifier.shift and castable(SB.FeralLunge) and talent(5, 2) and target.distance < 25 then
    return cast(SB.FeralLunge, "target")
  end
end

local function interface()
  local settings = {
    key = "enhsha_settings",
    title = "Enhancement Shaman",
    width = 300,
    height = 500,
    resize = true,
    show = false,
    template = {
      {type = "header", text = "            Rex's Enhancement Shaman Settings"},
      {type = "text", text = "Everything on the screen is LIVE.  As you make changes, they are being fed to the engine"},
      {type = "text", text = "Stormstrike Rotation is flexible with talents"},
      {type = "text", text = "Under Stormstrike Rotation, Ascendance is activated by Cooldowns toggle"},
      {type = "text", text = "For Primal Primer Rotation you must use 2 (2 or 3) 2 2 2 3 1"},
      {type = "text", text = "If you want automatic AOE then please remember to turn on EnemyNamePlates in WoW (V key)"},
      {type = "text", text = "Shift Modifier used for Feral Lunge"},
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
      {type = "text", text = "Select Rotation Type"},
      {key = "primalprimerbuild", type = "checkbox", text = "Primal Primer", desc = "Use Primal Primer Rotation"},
      {key = "stormstrikebuild", type = "checkbox", text = "Stormstrike", desc = "Use Stormstrike Rotation"},
      {type = "text", text = "Defensive Settings"},
      {
        key = "HSHealth",
        type = "spinner",
        text = "Healing Surge at Health %",
        default = "60",
        desc = "cast Healing Surge at",
        min = 0,
        max = 100,
        step = 1
      },
      {
        key = "ASHealth",
        type = "spinner",
        text = "Astral Shift at Health %",
        default = "20",
        desc = "cast Astral Shift at",
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
  --    dark_addon.interface.buttons.add_toggle({
  --        name = 'useracials',
  --        label = 'Use Racials',
  --        font = 'dark_addon_icon',
  --        on = {
  --            label = dark_addon.interface.icon('toggle-on'),
  --            color = dark_addon.interface.color.cyan,
  --            color2 = dark_addon.interface.color.dark_cyan
  --        },
  --        off = {
  --            label = dark_addon.interface.icon('toggle-off'),
  --            color = dark_addon.interface.color.grey,
  --            color2 = dark_addon.interface.color.dark_grey
  --        }
  --    })
end

-- This is what actually tells DR about your custom rotation
dark_addon.rotation.register(
  {
    spec = dark_addon.rotation.classes.shaman.enhancement,
    name = "ShamPalEnh",
    label = "Rex Enhancement Shaman",
    combat = combat,
    resting = resting,
    interface = interface
  }
)
