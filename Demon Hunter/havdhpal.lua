local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.demonhunter

-- To Do

-- Spells

SB.DemonsBite = 162243
SB.DemonBlades = 203555
SB.ChaosStrike = 162794
SB.VengefulRetreat = 198793
SB.FelRush = 195072
SB.FelBarrage = 258925
SB.DarkSlash = 258860
SB.EyeBeam = 198013
SB.Nemesis = 206491
SB.Metamorphosis = 191427
SB.Momentum = 208628
SB.BladeDance = 188499
SB.DeathSweep = 210152
SB.ImmolationAura = 258920
SB.Felblade = 232893
SB.Annihilation = 201427
SB.ThrowGlaive = 185123
SB.FirstBlood = 206416
SB.Demonic = 213410
SB.BlindFury = 203550
SB.ChaoticTransformation = 288754
SB.TrailofRuin = 258881
SB.DemonicAppetite = 206478
SB.InsatiableHunger = 258876
SB.CycleofHatred = 258887
SB.FelMastery = 192939
SB.Disrupt = 183752
SB.ConsumeMagic = 278326
SB.Netherwalk = 196555
SB.Blur = 198589
SB.Darkness = 196718

local function combat()
if target.alive and target.enemy and player.alive and not player.channeling() then

    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch('havdh_settings_intpercentlow',50)
    local intpercenthigh = dark_addon.settings.fetch('havdh_settings_intpercenthigh',65)
    local NWHealth = dark_addon.settings.fetch('havdh_settings_NWHealth',60)
    local BHealth = dark_addon.settings.fetch('havdh_settings_BHealth',60)
    local DHealth = dark_addon.settings.fetch('havdh_settings_DHealth',60)
    local GiftHealth = dark_addon.settings.fetch('havdh_settings_GiftHealth',20)
    local Hstonecheck = dark_addon.settings.fetch('havdh_settings_healthstone.check',true)
    local Hstonepercent = dark_addon.settings.fetch('havdh_settings_healthstone.spin',20)

    -- Targets in range function
    local enemyCount = enemies.around(8)
    if enemyCount == 0 then enemyCount = 1 end
    dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

    -- Auto Attack
     if target.enemy and target.alive and target.distance < 8 then
         auto_attack()
     end

    -- Interrupts
        -- Define random number for interrupt
        local intpercent = math.random(intpercentlow,intpercenthigh)

        -- Disrupt
        if toggle('interrupts', false) and castable(SB.Disrupt, 'target') and -spell(SB.Disrupt) == 0 and target.interrupt(intpercent, false) then
          print('Interrupt @' .. intpercent)
          return cast(SB.Disrupt, 'target')
        end

    -- Cooldowns
    if toggle('cooldowns', false) then
        -- Metamorphosis
        if castable(SB.Metamorphosis) and -spell(SB.Metamorphosis) == 0 and not player.buff(SB.Metamorphosis).up then
            return cast(SB.Metamorphosis, 'player')
        end

        -- Nemesis
        if castable(SB.Nemesis) and -spell(SB.Nemesis) == 0 and talent(7,3) then
            return cast(SB.Nemesis, 'target')
        end

    end

  -- Healing
    -- Healthstone
    if Hstonecheck == true and -player.health < Hstonepercent and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
        macro('/use Healthstone')
    end

    -- Demonic List
    if talent(7,1) then
        -- Fel Barrage on cooldown with Metamorphosis active, consider holding the cooldown for incoming adds in the near future.
        if castable(SB.FelBarrage, 'target') and -spell(SB.FelBarrage) == 0 and player.buff(SB.Metamorphosis).up and (enemyCount >= 2 or toggle('multitarget'))
                and talent(3,3) then
            return cast(SB.FelBarrage, 'target')
        end

        -- Death Sweep if  First Blood is talented or  Death Sweep will hit 2+ targets while  Trail of Ruin is talented.
        if castable(SB.DeathSweep, 'target') and -spell(SB.DeathSweep) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget')))) then
            return cast(SB.DeathSweep, 'target')
        end

        -- Blade Dance if  First Blood is talented or  Blade Dance will hit 2+ targets while  Trail of Ruin is talented. and  Metamorphosis is not ready.
        if castable(SB.BladeDance, 'target') and -spell(SB.BladeDance) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget'))))
                and -spell(SB.Metamorphosis) > 0 and target.distance < 8 then
            return cast(SB.BladeDance, 'target')
        end

        -- Immolation Aura if talented.
        if castable(SB.ImmolationAura, 'target') and -spell(SB.ImmolationAura) == 0 and talent(2,3) then
            return cast(SB.ImmolationAura)
        end

        -- Felblade if fury is < than 40 or (  Metamorphosis is not active and your fury deficit is >= than 40 ).
        if castable(SB.Felblade, 'target') and -spell(SB.Felblade) == 0 and (power.fury.actual < 40 or (not player.buff(SB.Metamorphosis).up and power.fury.actual <= 60)) and talent(1,3) then
            return cast(SB.Felblade)
        end

        -- Eye Beam if not talented into  Blind Fury or your fury deficit is >= 50 and you cannot extended Metamorphosis again.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 and (not talent(1,1) or (not player.buff(SB.Metamorphosis).up and power.fury.actual <= 50)) then
            return cast(SB.EyeBeam)
        end

        -- Annihilation if (  Blind Fury is talented or your fury deficit is < than 30 or the  Metamorphosis buff remaining time is < than 5 seconds ) and if  First Blood is talented your fury is >= 55.
        if castable(SB.Annihilation, 'target') and -spell(SB.Annihilation) == 0 and (talent(1,1) or power.fury.actual > 70 or player.buff(SB.Metamorphosis).remains < 5)
                and (talent(5,2) and power.fury.actual >= 55) then
            return cast(SB.Annihilation)
        end

        -- Chaos Strike if (  Blind Fury is talented or your fury deficit is < than 30 and the cooldown remaing on Metamorphosis is > than 6 seconds and your fury deficit is < 30 ) and if  First Blood is talented your fury is >= 55.
        if castable(SB.ChaosStrike, 'target') and -spell(SB.ChaosStrike) == 0 and (talent(1,1) or power.fury.actual > 70 and -spell(SB.Metamorphosis) > 6 and power.fury.actual > 70)
                and (talent(5,2) and power.fury.actual >= 55) then
            return cast(SB.ChaosStrike)
        end

        -- Fel Rush if  Demon Blades is talented and  Eye Beam is not ready and you have 2 charges of  Fel Rush ready.
        if castable(SB.FelRush, 'target') and -spell(SB.FelRush) == 0 and talent(2,2) and -spell(SB.EyeBeam) > 0 and spell(SB.FelRush).charges == 2 then
            return cast(SB.FelRush, 'target')
        end

        -- Demon's Bite.
        if castable(SB.DemonsBite, 'target') and -spell(SB.DemonsBite) == 0 and not talent(2,2) then
            return cast(SB.DemonsBite, 'target')
        end

        -- Throw Glaive if you will be out of range for the full duration of the next global cooldown or if you are talented into  Demon Blades and nothing else is available.
        if castable(SB.ThrowGlaive, 'target') and -spell(SB.ThrowGlaive) == 0 and ((target.distance >= 8 and target.distance <= 30) or talent(2,2)) then
          return cast(SB.ThrowGlaive, 'target')
        end

    end

    -- Nemesis List
    if target.debuff(SB.Nemesis).up then
        -- Fel Rush if  Fel Mastery is talented and you have 2 charges of  Fel Rush ready.
        if castable(SB.FelRush, 'target') and -spell(SB.FelRush) == 0 and talent(3,2) and spell(SB.FelRush).charges == 2 then
            return cast(SB.FelRush, 'target')
        end

        -- Fel Barrage on cooldown, consider holding the cooldown for incoming adds in the near future.
        if castable(SB.FelBarrage, 'target') and -spell(SB.FelBarrage) == 0 and talent(3,3) then
            return cast(SB.FelBarrage, 'target')
        end

        -- Immolation Aura if talented.
        if castable(SB.ImmolationAura, 'target') and -spell(SB.ImmolationAura) == 0 and talent(2,3) then
            return cast(SB.ImmolationAura)
        end

        -- Eye Beam.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 then
            return cast(SB.EyeBeam)
        end

        -- Death Sweep if  First Blood is talented or  Death Sweep will hit 2+ targets while  Trail of Ruin is talented.
        if castable(SB.DeathSweep, 'target') and -spell(SB.DeathSweep) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget')))) then
            return cast(SB.DeathSweep, 'target')
        end

        -- Blade Dance if  First Blood is talented or  Blade Dance will hit 2+ targets while  Trail of Ruin is talented.
        if castable(SB.BladeDance, 'target') and -spell(SB.BladeDance) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget')))) 
        and target.distance < 8 then
            return cast(SB.BladeDance, 'target')
        end

        -- Felblade if fury is < than 40.
        if castable(SB.Felblade, 'target') and -spell(SB.Felblade) == 0 and power.fury.actual < 40 and talent(1,3) then
            return cast(SB.Felblade)
        end

        -- Eye Beam if  Blind Fury is not talented and  Dark Slash is not talented and if  First Blood is talented your fury is >= 45.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 and not talent(1,1) and not talent(5,3) and (talent(5,2) and power.fury.actual >= 45) then
            return cast(SB.EyeBeam)
        end

        -- Annihilation if (  Demon Blades is talented or fury deficit < 30 or the  Metamorphosis buff remaining time is < than 5 seconds ) and if  First Blood is talented your fury is >= 55.
        if castable(SB.Annihilation, 'target') and -spell(SB.Annihilation) == 0 and (talent(2,2) or power.fury.actual > 70 or player.buff(SB.Metamorphosis).remains < 5)
                and (talent(5,2) and power.fury.actual >= 55) then
            return cast(SB.Annihilation)
        end

        -- Chaos Strike if (  Demon Blades is talented or fury deficit < 30 or the cooldown remaing on Metamorphosis is > than 6 seconds ) and if  First Blood is talented your fury is >= 55.
        if castable(SB.ChaosStrike, 'target') and -spell(SB.ChaosStrike) == 0 and (talent(2,2) or power.fury.actual > 70 or -spell(SB.Metamorphosis) > 6)
                and (talent(5,2) and power.fury.actual >= 55) then
            return cast(SB.ChaosStrike)
        end

        -- Eye Beam if talented into  Blind Fury.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 and talent(1,1) then
            return cast(SB.EyeBeam)
        end

        -- Demon's Bite.
        if castable(SB.DemonsBite, 'target') and -spell(SB.DemonsBite) == 0 and not talent(2,2) then
            return cast(SB.DemonsBite, 'target')
        end

        -- Fel Rush if if  Demon Blades and nothing else is available.
        if castable(SB.FelRush, 'target') and -spell(SB.FelRush) == 0 and talent(2,2) then
          return cast(SB.FelRush, 'target')
        end

        -- Throw Glaive if you will be out of range for the full duration of the next global cooldown or if you are talented into  Demon Blades and nothing else is available.
        if castable(SB.ThrowGlaive, 'target') and -spell(SB.ThrowGlaive) == 0 and ((target.distance >= 8 and target.distance <= 30) or talent(2,2)) then
          return cast(SB.ThrowGlaive, 'target')
        end

    end

    -- Momentum List
    if talent(7,2) then
        -- Vengeful Retreat.
        if castable(SB.VengefulRetreat, 'target') and -spell(SB.VengefulRetreat) == 0 then
          return cast(SB.VengefulRetreat, 'target')
        end

        -- Fel Rush if you have 2 charges of  Fel Rush ready.
        if castable(SB.FelRush, 'target') and -spell(SB.FelRush) == 0 and spell(SB.FelRush).charges == 2 then
          return cast(SB.FelRush, 'target')
        end

        -- Fel Barrage if  Momentum is active, consider holding the cooldown for incoming adds in the near future.
        if castable(SB.FelBarrage, 'target') and -spell(SB.FelBarrage) == 0 and talent(3,3) and player.buff(SB.Momentum).up then
            return cast(SB.FelBarrage, 'target')
        end

        -- Immolation Aura if talented.
        if castable(SB.ImmolationAura, 'target') and -spell(SB.ImmolationAura) == 0 and talent(2,3) then
            return cast(SB.ImmolationAura)
        end

        -- Eye Beam if  Momentum is active.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 and player.buff(SB.Momentum).up then
            return cast(SB.EyeBeam)
        end

        -- Death Sweep if  First Blood is talented or  Death Sweep will hit 2+ targets while  Trail of Ruin is talented.
        if castable(SB.DeathSweep, 'target') and -spell(SB.DeathSweep) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget')))) then
            return cast(SB.DeathSweep, 'target')
        end

        -- Blade Dance if  First Blood is talented or  Blade Dance will hit 2+ targets while  Trail of Ruin is talented.
        if castable(SB.BladeDance, 'target') and -spell(SB.BladeDance) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget')))) 
        and target.distance < 8 then
            return cast(SB.BladeDance, 'target')
        end

        -- Felblade if fury is < than 40.
        if castable(SB.Felblade, 'target') and -spell(SB.Felblade) == 0 and power.fury.actual < 40 and talent(1,3) then
            return cast(SB.Felblade)
        end

        -- Eye Beam if  Blind Fury is not talented and  Dark Slash is not talented and if  First Blood is talented your fury is >= 45.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 and not talent(1,1) and not talent(5,3) and (talent(5,2) and power.fury.actual >= 45) then
            return cast(SB.EyeBeam)
        end

        -- Annihilation if (  Demon Blades is talented or fury deficit < 30 or the  Metamorphosis buff remaining time is < than 5 seconds ) and if  First Blood is talented your fury is >= 55.
        if castable(SB.Annihilation, 'target') and -spell(SB.Annihilation) == 0 and (talent(2,2) or power.fury.actual > 70 or player.buff(SB.Metamorphosis).remains < 5)
                and (talent(5,2) and power.fury.actual >= 55) then
            return cast(SB.Annihilation)
        end

        -- Chaos Strike if (  Demon Blades is talented or fury deficit < 30 or the cooldown remaing on Metamorphosis is > than 6 seconds ) and if  First Blood is talented your fury is >= 55.
        if castable(SB.ChaosStrike, 'target') and -spell(SB.ChaosStrike) == 0 and (talent(2,2) or power.fury.actual > 70 or -spell(SB.Metamorphosis) > 6)
                and (talent(5,2) and power.fury.actual >= 55) then
            return cast(SB.ChaosStrike)
        end

        -- Eye Beam if talented into  Blind Fury.
        if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 and talent(1,1) then
            return cast(SB.EyeBeam)
        end

        -- Demon's Bite.
        if castable(SB.DemonsBite, 'target') and -spell(SB.DemonsBite) == 0 and not talent(2,2) then
            return cast(SB.DemonsBite, 'target')
        end

        -- Felblade.
        if castable(SB.Felblade, 'target') and -spell(SB.Felblade) == 0 and talent(1,3) then
            return cast(SB.Felblade)
        end

        -- Throw Glaive if you will be out of range for the full duration of the next global cooldown or if you are talented into  Demon Blades and nothing else is available.
        if castable(SB.ThrowGlaive, 'target') and -spell(SB.ThrowGlaive) == 0 and ((target.distance >= 8 and target.distance <= 30) or talent(2,2)) then
          return cast(SB.ThrowGlaive, 'target')
        end

    end

    -- Dark Slash List
    if talent(5,3) then
        -- Dark Slash if fury is >= than 80.
        if castable(SB.DarkSlash, 'target') and -spell(SB.DarkSlash) == 0 and power.fury.actual >= 80 then
            return cast(SB.DarkSlash)
        end

        -- Annihilation if  Dark Slash is active on target.
        if castable(SB.Annihilation, 'target') and -spell(SB.Annihilation) == 0 and target.debuff(SB.DarkSlash).up then
            return cast(SB.Annihilation)
        end

        -- Chaos Strike if  Dark Slash is active on target.
        if castable(SB.ChaosStrike, 'target') and -spell(SB.ChaosStrike) == 0 and target.debuff(SB.DarkSlash).up then
            return cast(SB.ChaosStrike)
        end

    end

    -- Simple Rotation
    -- Dark Slash if fury is >= than 80.
    if castable(SB.DarkSlash, 'target') and -spell(SB.DarkSlash) == 0 and power.fury.actual >= 80 and talent(5,3) then
        return cast(SB.DarkSlash)
    end

    -- Fel Barrage with  Metamorphosis active.
    if castable(SB.FelBarrage, 'target') and -spell(SB.FelBarrage) == 0 and player.buff(SB.Metamorphosis).up and talent(3,3) then
        return cast(SB.FelBarrage, 'target')
    end

    -- Eye Beam.
    if modifier.shift and castable(SB.EyeBeam, 'target') and -spell(SB.EyeBeam) == 0 then
        return cast(SB.EyeBeam)
    end

    -- Death Sweep if  First Blood is talented or on multiple targets (2+ with  Trail of Ruin 3+ otherwise.
    if castable(SB.DeathSweep, 'target') and -spell(SB.DeathSweep) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget')))) then
        return cast(SB.DeathSweep, 'target')
    end

    -- Blade Dance if  First Blood is talented or on multiple targets (2+ with  Trail of Ruin 3+ otherwise. and  Metamorphosis is not ready.
    if castable(SB.BladeDance, 'target') and -spell(SB.BladeDance) == 0 and (talent(5,2) or (talent(3,1) and (enemyCount >= 2 or toggle('multitarget'))))
            and -spell(SB.Metamorphosis) > 0 and target.distance < 8 then
        return cast(SB.BladeDance, 'target')
    end

    -- Immolation Aura.
    if castable(SB.ImmolationAura, 'target') and -spell(SB.ImmolationAura) == 0 and talent(2,3) then
        return cast(SB.ImmolationAura)
    end

    -- Felblade.
    if castable(SB.Felblade, 'target') and -spell(SB.Felblade) == 0 and talent(1,3) then
        return cast(SB.Felblade)
    end

    -- Annihilation.
    if castable(SB.Annihilation, 'target') and -spell(SB.Annihilation) == 0 then
        return cast(SB.Annihilation)
    end

    -- Chaos Strike.
    if castable(SB.ChaosStrike, 'target') and -spell(SB.ChaosStrike) == 0 then
        return cast(SB.ChaosStrike)
    end

    -- Fel Rush if  Demon Blades is talented and  Eye Beam is not ready and you have 2 charges of  Fel Rush ready.
    if castable(SB.FelRush, 'target') and -spell(SB.FelRush) == 0 and talent(2,2) and -spell(SB.EyeBeam) > 0 and spell(SB.FelRush).charges == 2 then
        return cast(SB.FelRush, 'target')
    end

    -- Demon's Bite.
    if castable(SB.DemonsBite, 'target') and -spell(SB.DemonsBite) == 0 and not talent(2,2) then
        return cast(SB.DemonsBite, 'target')
    end

    -- Throw Glaive if you will be out of range for the full duration of the next global cooldown or if you are talented into  Demon Blades and nothing else is available.
    if castable(SB.ThrowGlaive, 'target') and -spell(SB.ThrowGlaive) == 0 and ((target.distance >= 8 and target.distance <= 30) or talent(2,2)) then
        return cast(SB.ThrowGlaive, 'target')
    end

    -- Defensives
    if castable(SB.Netherwalk) and -spell(SB.Netherwalk) == 0 and -player.health <= NWHealth and talent(4,3) then
        print('Netherwalk @' .. NWHealth)
  		return cast(SB.Netherwalk)
    end

    if castable(SB.Blur) and -spell(SB.Blur) == 0 and -player.health <= BHealth then
        print('Blur @' .. BHealth)
  		return cast(SB.Blur)
  	end

end
end

local function resting()

  local enemyCount = enemies.around(8)
  dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

end

local function interface()

    local settings = {
        key = 'havdh_settings',
        title = 'Havoc Demon Hunter',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = "            Rex's Havoc Demon Hunter Settings" },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine' },
            { type = 'text', text = 'Suggested Talents - 1 3 1 1 2 1 1' },
            { type = 'text', text = 'If you want AOE DPS then please remember to turn on Multitarget on the interface' },
            { type = 'text', text = 'Metamorphosis and Nemesis are both controlled by the Cooldowns toggle on the interface' },
            { type = 'text', text = 'Eye Beam is cast using the SHIFT key modifier },
            { type = 'rule' },
            { type = 'text', text = 'Interrupt Settings' },
            { key = 'intpercentlow', type = 'spinner', text = 'Interrupt Low %', default = '50', desc = 'low% cast time to interrupt at', min = 5, max = 50, step = 1 },
            { key = 'intpercenthigh', type = 'spinner', text = 'Interrupt High %', default = '65', desc = 'high% cast time to interrupt at', min = 51, max = 100, step = 1 },
            { type = 'text', text = 'Defensive Settings' },
            { key = 'NWHealth', type = 'spinner', text = 'Netherwalker at Health %', default = '60', desc = 'cast Netherwalker at', min = 0, max = 100, step = 1 },
            { key = 'BHealth', type = 'spinner', text = 'Blur at Health %', default = '60', desc = 'cast Blur at', min = 0, max = 100, step = 1 },
            { key = 'DHealth', type = 'spinner', text = 'Darkness at Health %', default = '60', desc = 'cast Darkness at', min = 0, max = 100, step = 1 },
            { key = 'healthstone', type = 'checkspin', default = '20', text = 'Healthstone', desc = 'use Healthstone at health %', min = 1, max = 100, step = 1 },
            { key = 'GiftHealth', type = 'spinner', text = 'Gift of the Naaru at Health %', default = '20', desc = 'cast Gift of the Naaru at', min = 0, max = 100, step = 1 },
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
    spec = dark_addon.rotation.classes.demonhunter.havoc,
    name = 'havdhpal',
    label = 'Rex Havoc Demon Hunter',
    combat = combat,
    resting = resting,
    interface = interface
})
