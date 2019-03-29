local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.druid

-- Talents

-- Spells
SB.Regrowth = 8936
SB.CatForm = 768
SB.Dash = 1850
SB.BearForm = 5487
SB.Eclipse = 279619
SB.Growl = 6795
SB.Revive = 50769
SB.TravelForm = 783
SB.AquaticForm = 276012
SB.FlightForm = 165962
SB.EntanglingRoots = 339
SB.Barkskin = 22812
SB.Rebirth = 20484
SB.Innervate = 29166
SB.MasteryStarlight = 77492
SB.SolarBeam = 78675
SB.Relentless = 196029
SB.GladiatorsMedallion = 208683
SB.Adaptation = 214027
SB.IronfeatherArmor = 233752
SB.PricklingThorns = 200549
SB.CrescentBurn = 200567
SB.MoonkinAura = 209740
SB.DeepRoots = 233755
SB.WildCharge = 102401
SB.MightyBash = 5211
SB.BrutalSlash = 202028
SB.Rip = 1079
SB.TigersFury = 5217
SB.Rake = 1822
SB.FerociousBite = 22568
SB.Shred = 5221
SB.Thrash = 77758
SB.Berserk = 106951
SB.Swipe = 213764
SB.PredatorySwiftness = 16974
SB.Mangle = 33917
SB.Prowl = 5215
SB.RemoveCorruption = 2782
SB.SurvivalInstincts = 61336
SB.OmenofClarity = 16864
SB.StampedingRoar = 106898
SB.InfectedWounds = 48484
SB.Soothe = 2908
SB.Maim = 22570
SB.Hibernate = 2637
SB.SkullBash = 106839
SB.MasteryRazorClaws = 77493
SB.WarStomp = 20549
SB.PrimalWrath = 285381

local function combat()
  if target.alive and target.enemy and player.alive and not player.channeling() then
    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch("ferdru_settings_intpercentlow", 50)
    local intpercenthigh = dark_addon.settings.fetch("ferdru_settings_intpercenthigh", 65)

    -- Targets in range check
    local enemyCount = enemies.around(8)
    if enemyCount == 0 then
      enemyCount = 1
    end
    dark_addon.interface.status_extra("T#:" .. enemyCount .. " D:" .. target.distance)

    -- Auto Attack
    if target.enemy and target.alive and target.distance < 8 then
      auto_attack()
    end

    -- Define random number for interrupt
    local intpercent = math.random(intpercentlow, intpercenthigh)

    -- PVE Defensive Spells

    -- Healing
    if castable(SB.Regrowth) and -spell(SB.Regrowth) == 0 and -player.health <= 60 then
      print("Regrowth @ " .. -player.health)
      return cast(SB.Regrowth)
    end

    -- Remove Curse and Poison
    local dispellable_unit = player.removable("curse", "poison")

    if castable(SB.RemoveCorruption) and -spell(SB.RemoveCorruption) == 0 and dispellable_unit then
      return cast(SB.RemoveCorruption, dispellable_unit)
    end

    -- Interrupts
    if castable(SB.SkullBash, "target") and -spell(SB.SkullBash) == 0 and target.interrupt(intpercent, false) then
      print("SkullBash @ " .. intpercent)
      return cast(SB.SkullBash, "target")
    end

    --[[    if castable(SB.WarStomp, 'target') and -spell(SB.WarStomp) == 0 and target.interrupt(intpercent, false) then
        print('WarStomp @ ' .. intpercent)
        return cast(SB.WarStomp, 'target')
    end]]
    -- Apply Cat Form IC
    if castable(SB.CatForm) and not (-buff(SB.CatForm)) then
      return cast(SB.CatForm, "player")
    end

    if UnitLevel("player") >= 110 then
      --Cast Regrowth with Bloodtalons if at 4-5 Combo Points.
      if castable(SB.Regrowth) and -spell(SB.Regrowth) == 0 and player.buff(SB.PredatorySwiftness).up and talent(7, 2) then
        return cast(SB.Regrowth)
      end

      --Cast Tiger's Fury at 30 Energy or less.
      if castable(SB.TigersFury, "target") and -spell(SB.TigersFury) == 0 and player.power.energy.actual <= 30 then
        return cast(SB.TigersFury)
      end

      --Cast Berserk if available.
      if castable(SB.Berserk, "target") and -spell(SB.Berserk) == 0 then
        return cast(SB.Berserk)
      end

      --Apply Rip via Primal Wrath if two or more targets are present.
      if
        castable(SB.PrimalWrath, "target") and -spell(SB.PrimalWrath) == 0 and player.power.combopoints.actual >= 5 and
          enemyCount >= 2 and
          talent(6, 3)
       then
        return cast(SB.PrimalWrath)
      end

      --Maintain Rip
      if
        castable(SB.Rip, "target") and -spell(SB.Rip) == 0 and player.power.combopoints.actual >= 5 and
          target.debuff(SB.Rip).remains < 7
       then
        return cast(SB.Rip)
      end

      --Maintain Rake
      if castable(SB.Rake, "target") and -spell(SB.Rake) == 0 and target.debuff(SB.Rake).remains < 4 then
        return cast(SB.Rake)
      end

      --Maintain Thrash if two or more targets are present.
      if
        enemyCount >= 2 and castable(SB.Thrash, "target") and -spell(SB.Thrash) == 0 and
          target.debuff(SB.Thrash).remains < 4
       then
        return cast(SB.Thrash)
      end

      --Cast Ferocious Bite if at 5 Combo Points and Rip does not need refreshing within 10 sec.
      if
        castable(SB.FerociousBite, "target") and -spell(SB.FerociousBite) == 0 and player.power.combopoints.actual >= 5 and
          target.debuff(SB.Rip).remains < 10
       then
        return cast(SB.FerociousBite)
      end

      --Cast Shred to build Combo Points.
      if castable(SB.Shred, "target") and -spell(SB.Shred) == 0 and player.power.combopoints.actual <= 4 then
        return cast(SB.Shred)
      end
    end

    if UnitLevel("player") < 110 then
      -- Rip should be applied to your target when you have 5 Combo Points.
      if
        castable(SB.Rip, "target") and -spell(SB.Rip) == 0 and player.power.combopoints.actual >= 5 and
          not (-target.debuff(SB.Rip))
       then
        return cast(SB.Rip)
      end

      -- Tiger's Fury should be used as often as possible when low on Energy. Look out for resets of its cooldown when nearby enemies die with bleeds applied to them.
      if castable(SB.TigersFury, "target") and -spell(SB.TigersFury) == 0 and player.power.energy.actual <= 30 then
        return cast(SB.TigersFury)
      end

      -- Apply Rake to any nearby targets.
      if castable(SB.Rake, "target") and -spell(SB.Rake) == 0 and not (-target.debuff(SB.Rake)) then
        return cast(SB.Rake)
      end

      -- Cast Ferocious Bite when at 5 Combo Points.
      if castable(SB.FerociousBite, "target") and -spell(SB.FerociousBite) == 0 and player.power.combopoints.actual >= 5 then
        return cast(SB.FerociousBite)
      end

      -- At 90 or above Cast Brutal Slash whenever more than one target is nearby.
      if
        UnitLevel("player") >= 90 and enemyCount >= 2 and castable(SB.BrutalSlash, "target") and
          -spell(SB.BrutalSlash) == 0
       then
        return cast(SB.BrutalSlash)
      end

      -- Thrash should be maintained on all targets when there are multiple enemies nearby.
      if
        UnitLevel("player") >= 12 and enemyCount >= 2 and castable(SB.Thrash, "target") and -spell(SB.Thrash) == 0 and
          not (-target.debuff(SB.Thrash))
       then
        return cast(SB.Thrash)
      end

      -- Cast Shred to generate Combo Points whenever available if only one target is nearby.
      if castable(SB.Shred, "target") and -spell(SB.Shred) == 0 and player.power.combopoints.actual <= 4 then
        return cast(SB.Shred)
      end

      -- Berserk should be used as often as possible for a burst of free Energy regeneration.
      if castable(SB.Berserk, "target") and -spell(SB.Berserk) == 0 then
        return cast(SB.Berserk)
      end

      -- Below level 90 - Cast Swipe when multiple targets are nearby.
      if
        UnitLevel("player") >= 32 and UnitLevel("player") < 90 and enemyCount >= 2 and castable(SB.Swipe, "target") and
          -spell(SB.Swipe) == 0
       then
        return cast(SB.Swipe)
      end

    -- At 100 or above you should be consuming Predatory Swiftness whenever possible to gain the Bloodtalons buff between pulling enemies.
    end
  end
end

local function resting()
  -- Targets in range check
  local enemyCount = enemies.around(8)
  dark_addon.interface.status_extra("T#:" .. enemyCount .. " D:" .. target.distance)

  -- Apply Cat Form OOC
  if castable(SB.CatForm) and not (-buff(SB.CatForm)) and not (-buff(SB.TravelForm)) then
    return cast(SB.CatForm, "player")
  end

  -- Apply Prowl
  if castable(SB.Prowl) and not (-buff(SB.Prowl)) and -buff(SB.CatForm) then
    return cast(SB.Prowl, "player")
  end
end

local function interface()
  local settings = {
    key = "ferdru_settings",
    title = "Feral Druid",
    width = 300,
    height = 500,
    resize = true,
    show = false,
    template = {
      {type = "header", text = "            Rex's Feral Druid Settings"},
      {type = "text", text = "Everything on the screen is LIVE.  As you make changes, they are being fed to the engine"},
      {type = "text", text = "Suggested PVE Talents at Level 110 - 1 3 1 3 1 3 2"},
      {type = "text", text = "Suggested Levelling Talents - 1 3 1 1 1 2 2"},
      {type = "text", text = "If you want automatic AOE then please remember to turn on EnemyNamePlates in WoW (V key)"},
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
        color = dark_addon.interface.color.yellow,
        color2 = dark_addon.interface.color.yellow
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
  --[[    dark_addon.interface.buttons.add_toggle({
        name = 'pvp',
        label = 'PVP Features',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('toggle-on'),
            color = dark_addon.interface.color.yellow,
            color2 = dark_addon.interface.color.yellow
        },
        off = {
            label = dark_addon.interface.icon('toggle-off'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })]]
end

-- This is what actually tells DR about your custom rotation
dark_addon.rotation.register(
  {
    spec = dark_addon.rotation.classes.druid.feral,
    name = "ferdrupal",
    label = "Rex Feral Druid",
    combat = combat,
    resting = resting,
    interface = interface
  }
)
