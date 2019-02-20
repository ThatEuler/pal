local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.druid

-- To Do

-- Spells

SB.ForceofNature = 205636
SB.TigerDash = 252216
SB.GuardianAffinity = 197491
SB.Typhoon = 132469
SB.SouloftheForest = 158476
SB.TwinMoons = 279620
SB.FuryofElune = 202770
SB.SolarWrath = 5176
SB.MoonkinForm = 24858
SB.Moonfire = 8921
SB.Sunfire = 93402
SB.CelestialAlignment = 194223
SB.SolarEmpowerment = 164545
SB.Starsurge = 78674
SB.Starfall = 191034
SB.LunarStrike = 194153
SB.LunarEmpowerment = 164547
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
SB.Predator = 202021
SB.WildChargeBear = 16979
SB.BalanceAffinity = 197488
SB.MightyBash = 5211
SB.BrutalSlash = 202028
SB.Bloodtalons = 155672
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
SB.RipandTear = 203242
SB.SavageMomentum = 205673
SB.FreshWound = 203224
SB.FerociousWound = 236020
SB.Thorns = 236696
SB.KingoftheJungle = 203052
SB.ToothandClaw = 236019
SB.EnragedMaul = 236716
SB.EarthenGrasp = 236023
SB.FreedomoftheHerd = 213200
SB.MalornesSwiftness = 236147
SB.EnragedMaim = 236026
SB.ProtectoroftheGrove = 209730
SB.Brambles = 203953
SB.FeralAffinity = 197490
SB.GalacticGuardian = 213708
SB.Earthwarden = 203974
SB.RendandTear = 204053
SB.Maul = 6807
SB.Ironfur = 192081
SB.FrenziedRegeneration = 22842
SB.IncapacitatingRoar = 99
SB.ThickHide = 16931
SB.Gore = 210706
SB.MasteryNaturesGuardian = 159195
SB.SharpenedClaws = 202110
SB.AlphaChallenge = 207017
SB.RagingFrenzy = 236153
SB.MasterShapeshifter = 236144
SB.DemoralizingRoar = 201664
SB.EntanglingClaws = 202226
SB.Overrun = 202246
SB.RoaringSpeed = 236148
SB.CenarionWard = 102351
SB.IncarnationTreeofLife = 33891
SB.Stonebark = 197061
SB.Germination = 155675
SB.Rejuvenation = 774
SB.Swiftmend = 18562
SB.Lifebloom = 33763
SB.NaturesCure = 88423
SB.WildGrowth = 48438
SB.Ironbark = 102342
SB.UrsolsVortex = 102793
SB.Revitalize = 203399
SB.Efflorescence = 145205
SB.Tranquility = 740
SB.Overgrowth = 203651
SB.Nourish = 203374
SB.BristlingFur = 155835
SB.IncarnationGuardianofUrsoc = 102558
SB.LunarBeam = 204066
SB.Pulverize = 80313


local function combat()
if target.alive and target.enemy and player.alive and not player.channeling() then

    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch('gudr_settings_intpercentlow', 50)
    local intpercenthigh = dark_addon.settings.fetch('gudr_settings_intpercenthigh', 65)
	local BSHealth = dark_addon.settings.fetch('gudr_settings_BSHealth', 30)
	local BFHealth = dark_addon.settings.fetch('gudr_settings_BFHealth', 30)
	local FRHealth = dark_addon.settings.fetch('gudr_settings_FRHealth', 50)
	local SIHealth = dark_addon.settings.fetch('gudr_settings_SIHealth', 20)
    local race = UnitRace('player')
	local dispellable_unit = player.removable('curse','poison')

    -- Targets in range check
    local enemyCount = enemies.around(8)
    if enemyCount == 0 then enemyCount = 1 end
    dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

    -- Auto Attack
     if target.enemy and target.alive and target.distance < 8 then
         auto_attack()
     end

--Make sure to always remain in Bear Form whenever you are in combat
    if castable(SB.BearForm) and -spell(SB.BearForm) == 0 and player.buff(SB.BearForm).down then
      return cast(SB.BearForm, 'target')
    end

    -- Interrupts
        -- Define random number for interrupt
        local intpercent = math.random(intpercentlow,intpercenthigh)

        -- Skull Bash
        if toggle('interrupts', false) and castable(SB.SkullBash, 'target') and -spell(SB.SkullBash) == 0 and target.interrupt(intpercent, false) and target.distance < 13 then
         print('Skull Bash @ ' .. intpercent)
          return cast(SB.SkullBash, 'target')
        end

        --Option for Mighty Bash as interrupt
        if toggle('interrupts', false) and castable(SB.MightyBash, 'target') and -spell(SB.MightyBash) == 0 and -spell(SB.SkullBash) > 0 and target.interrupt(intpercent, false) and target.distance < 5 and talent(4,1) then
         print('Mighty Bash @ ' .. intpercent)
         return cast(SB.MightyBash, 'target')
        end

        --Option for Incapacitating Roar as interrupt
        if toggle('interrupts', false) and castable(SB.IncapacitatingRoar, 'target') and -spell(SB.IncapacitatingRoar) == 0 and -spell(SB.SkullBash) > 0 and -spell(SB.MightyBash) > 0 and target.interrupt(intpercent, false) and target.distance < 5 then
         print('Incapacitating Roar @ ' .. intpercent)
         return cast(SB.IncapacitatingRoar, 'target')
        end

--Defensive and Utility Abilities
--Frenzied Regeneration
    if castable(SB.FrenziedRegeneration) and -spell(SB.FrenziedRegeneration) == 0 and -player.health <= FRHealth then
        print('Frenzied Regeneration @ ' .. FRHealth)
        return cast(SB.FrenziedRegeneration)
    end

--Survival Instincts
    if castable(SB.SurvivalInstincts) and -spell(SB.SurvivalInstincts) == 0 and -player.health <= SIHealth then
        print('Survival Instincts @ ' .. SIHealth)
  		return cast(SB.SurvivalInstincts)
    end

--Ironfur
    if castable(SB.Ironfur) and -spell(SB.Ironfur) == 0 and player.buff(SB.Ironfur).down and power.rage.actual >= 45 then
  		return cast(SB.Ironfur)
    end
--Pool Rage for Multiple Iron Fur toggle

--Barkskin
    if castable(SB.Barkskin) and -spell(SB.Barkskin) == 0 and (-player.health <= BSHealth or talent(1,1)) then
        print('Barkskin @ ' .. BSHealth)
  		return cast(SB.Barkskin)
    end

--Wild Charge with Shift Modifier
    if modifier.shift and castable(SB.WildChargeBear) and -spell(SB.WildChargeBear) == 0 and talent(2,3) then
        return cast(SB.WildChargeBear, 'target')
    end

--Bristling Fur based on percentage of health
    if castable(SB.BristlingFur) and -spell(SB.BristlingFur) == 0 and -player.health <= BFHealth and talent(1,3) then
        print('Bristling Fur @ ' .. BFHealth)
        return cast(SB.BristlingFur, 'target')
    end

--Cooldowns
--Incarnation: Guardian of Ursoc, you will prioritize Mangle at all times for Rage generation, or on up to 3 targets for damage output.
--On 4 or more targets, Thrash deals more damage per cast. Using Maul to dump excess Rage is a damage increase on up to 3 targets.
--It is also worth maintaining Moonfire on one target during Incarnation, keeping in mind that you should refresh Moonfire just before you enter Incarnation so that you only need to refresh it once during the cooldown.
    if toggle('cooldowns', false) then
        if castable(SB.IncarnationGuardianofUrsoc) and -spell(SB.IncarnationGuardianofUrsoc) == 0 then
            return cast(SB.IncarnationGuardianofUrsoc)
        end
    end

    if player.buff(SB.IncarnationGuardianofUrsoc).up then
        --Keep Moonfire ticking on your target
        if castable(SB.Moonfire) and -spell(SB.Moonfire) == 0 and target.debuff(SB.Moonfire).down and target.distance < 40 then
                        print("Incarnation Moonfire")
            return cast(SB.Moonfire, 'target')
        end

        --Use Mangle
        if castable(SB.Mangle) and -spell(SB.Mangle) == 0 and target.distance < 6 and enemyCount <= 3 then
            print("Incarnation Mangle")
          return cast(SB.Mangle, 'target')
        end

    --Use Thrash
        if castable(SB.Thrash) and -spell(SB.Thrash) == 0 and target.distance < 6 and enemyCount >= 4 then
                        print("Incarnation Thrash")
          return cast(SB.Thrash, 'target')
        end

    --Use Maul to dump Rage
        if castable(SB.Maul) and -spell(SB.Maul) == 0 and power.rage.actual >= 90 and target.distance < 6 and enemyCount <= 3 then
                        print("Incarnation Maul")
          return cast(SB.Maul, 'target')
        end

    end

--Single or 2 Targets Rotation
if enemyCount == 1 or enemyCount == 2 then
    --Keep Moonfire ticking on your target
        if castable(SB.Moonfire) and -spell(SB.Moonfire) == 0 and target.debuff(SB.Moonfire).down and target.distance < 40 then
            return cast(SB.Moonfire, 'target')
        end

    --Use Thrash if your target does not have 3 stacks of the bleed yet
        if castable(SB.Thrash) and -spell(SB.Thrash) == 0 and target.debuff(SB.Thrash).count < 3 and target.distance < 6 then
          return cast(SB.Thrash, 'target')
        end

    --Use Pulverize at 3 stacks of Thrash
        if castable(SB.Pulverize) and -spell(SB.Pulverize) == 0 and target.debuff(SB.Thrash).count == 3 and talent(7,3) and target.distance < 6 then
          return cast(SB.Pulverize, 'target')
        end

    --Use Lunar Beam as often as possible
        if castable(SB.LunarBeam) and -spell(SB.LunarBeam) == 0 and talent(7,2) then
          return cast(SB.LunarBeam, 'target')
        end

    --Use Mangle
        if castable(SB.Mangle) and -spell(SB.Mangle) == 0 and target.distance < 6 then
          return cast(SB.Mangle, 'target')
        end

    --Use Thrash
        if castable(SB.Thrash) and -spell(SB.Thrash) == 0 and target.distance < 6 then
          return cast(SB.Thrash, 'target')
        end

    --Use Moonfire with a Galactic Guardian proc, if talented
        if castable(SB.Moonfire) and -spell(SB.Moonfire) == 0 and player.buff(SB.GalacticGuardian).up and talent(5,2) and target.distance < 40 then
          return cast(SB.Moonfire, 'target')
        end

    --Use Maul to dump Rage, of you do not need the Rage for Ironfur or Frenzied Regeneration
        if castable(SB.Maul) and -spell(SB.Maul) == 0 and power.rage.actual >= 90 and target.distance < 6 then
          return cast(SB.Maul, 'target')
        end

    --Use Swipe
        if castable(SB.Swipe) and -spell(SB.Swipe) == 0 and target.distance < 6 then
          return cast(SB.Swipe, 'target')
        end
end

--3+ Targets Rotation
if enemyCount >= 3 then
    --Keep Moonfire ticking on your target
        if enemyCount == 3 and castable(SB.Moonfire) and -spell(SB.Moonfire) == 0 and target.debuff(SB.Moonfire).down and target.distance < 40 then
            return cast(SB.Moonfire, 'target')
        end

    --Use Lunar Beam as often as possible
        if castable(SB.LunarBeam) and -spell(SB.LunarBeam) == 0 and talent(7,2) then
          return cast(SB.LunarBeam, 'target')
        end

    --Use Moonfire with a Galactic Guardian proc, if talented
        if enemyCount == 3 and castable(SB.Moonfire) and -spell(SB.Moonfire) == 0 and player.buff(SB.GalacticGuardian).up and talent(5,2) and target.distance < 40 then
          return cast(SB.Moonfire, 'target')
        end

    --Use Thrash
        if castable(SB.Thrash) and -spell(SB.Thrash) == 0 and target.distance < 6 then
          return cast(SB.Thrash, 'target')
        end

    --Use Swipe
        if castable(SB.Swipe) and -spell(SB.Swipe) == 0 and target.distance < 6 then
          return cast(SB.Swipe, 'target')
        end

    --Use Mangle with a Gore proc
        if castable(SB.Mangle) and -spell(SB.Mangle) == 0 and player.buff(SB.Gore).up and target.distance < 6 then
          return cast(SB.Mangle, 'target')
        end

end

end
end

local function resting()

local RGHealth = dark_addon.settings.fetch('gudr_settings_RGHealth', 70)

  local enemyCount = enemies.around(8)
  if enemyCount == 0 then enemyCount = 1 end
  dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

--RemoveCorruption (only OOC as you drop Bear Form)
    if castable(SB.RemoveCorruption) and dispellable_unit and spell(SB.RemoveCorruption).cooldown == 0 then
     return cast(SB.RemoveCorruption, dispellable_unit)
    end

--Wild Charge with Shift Modifier
    if modifier.shift and castable(SB.WildChargeBear) and -spell(SB.WildChargeBear) == 0 and talent(2,3) then
        return cast(SB.WildChargeBear, 'target')
    end

--Healing
--Regrowth
    if castable(SB.Regrowth) and -spell(SB.Regrowth) == 0 and -player.health <= RGHealth then
        print('Regrowth @ ' .. RGHealth)
        return cast(SB.Regrowth)
    end

end

local function interface()

    local settings = {
        key = 'gudr_settings',
        title = 'Guardian Druid',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = "            Rex's Guardian Druid Settings" },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine' },
            { type = 'text', text = 'Suggested Talents - 1 2 3 3 2 1 1' },
            { type = 'text', text = 'Supports all talents however' },
            { type = 'text', text = 'If you want automatic AOE then please remember to turn on EnemyNamePlates in WoW (V key)' },
            { type = 'text', text = 'Wild Charge (if talented) is activated using the Shift Modifier' },
            { type = 'text', text = 'Bristling Fur (if talented) is activated using the CTRL Modifier' },
            { type = 'text', text = 'Incarnation: Guardian of Ursoc is the only spell activated thorugh Cooldown Toggle' },
            { type = 'rule' },
            { type = 'text', text = 'Interrupt Settings' },
            { key = 'intpercentlow', type = 'spinner', text = 'Interrupt Low %', default = '50', desc = 'low% cast time to interrupt at', min = 5, max = 50, step = 1 },
            { key = 'intpercenthigh', type = 'spinner', text = 'Interrupt High %', default = '65', desc = 'high% cast time to interrupt at', min = 51, max = 100, step = 1 },
            { type = 'text', text = 'Defensive Settings' },
            { key = 'BSHealth', type = 'spinner', text = 'Bark Skin at Health %', default = '30', desc = 'cast Bark Skin at', min = 0, max = 100, step = 1 },
            { key = 'BFHealth', type = 'spinner', text = 'Bristling Fur at Health %', default = '30', desc = 'cast Bristling Fur at', min = 0, max = 100, step = 1 },
            { key = 'RGHealth', type = 'spinner', text = 'Regrowth at Health %', default = '70', desc = 'cast Regrowth at', min = 0, max = 100, step = 1 },
            { key = 'FRHealth', type = 'spinner', text = 'Frenzied Regen at Health %', default = '50', desc = 'cast Frenzied Regen at', min = 0, max = 100, step = 1 },
            { key = 'SIHealth', type = 'spinner', text = 'Survival Instincts at Health %', default = '20', desc = 'cast Survival Instincts at', min = 0, max = 100, step = 1 },
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'settings',
        label = 'Rotation Settings',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.cyan,
            color2 = dark_addon.interface.color.dark_cyan
        },
        off = {
            label = dark_addon.interface.icon('cog'),
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
    })
    

end

-- This is what actually tells DR about your custom rotation
dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.druid.guardian,
    name = 'RexGuDr',
    label = 'Rex Guardian Druid',
    combat = combat,
    resting = resting,
    interface = interface
})
