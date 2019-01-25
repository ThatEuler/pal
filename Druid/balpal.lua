-- Balance Druid for 8.1 by Laksmackt - 10/2018
-- Talents: 3132222  or wahtever ...most works
-- Holding Right Alt = Treants spawn at your mousecursor
-- Holding Left Alt = bear form and defensive (for as long as you hold it down)
-- Holding Shift = Starfall (will halt starsurge)
-- Holding CONTROL = Battle Rez (works w/ raid frames)

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.druid
local DS = dark_addon.rotation.dispellbooks.soothe

--Spells not in spellbook
SB.StellarDrift = 163222
SB.TigerDashBuff = 252216
SB.Starlord = 279709
SB.CelestialAlignment = 194223
SB.Berserking = 26297
SB.DawningSun = 276152
SB.Sunblaze = 274399
SB.IncarnationBalance = 102560
SB.FuryofElune = 202770
---
SB.StellarFlare = 202347
SB.Rebirth = 20484
SB.RejuvenationGermination = 155777
SB.ForceofNature = 205636
SB.ArcanicPulsar = 287790
SB.Revive = 50769
SB.BearForm = 5487
SB.WhisperInsanityBuff = 176151
SB.StreakingStars = 272871
SB.Fullmoon = 274283
SB.Halfmoon = 202768
SB.Newmoon = 274281
SB.LivelySpirit = 279646
SB.FlaskofEndlessFathoms = 251837

local x = 0 -- counting seconds in resting
local y = 0 -- counter for opener
local z = 0 -- time in combat
local enemyCount
local burst
local autoDotCountCurrent = 0

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

local function findHealer(name)
    local members = GetNumGroupMembers()
    local group_type = GroupType()

    if group_type ~= 'solo' then
        if name ~= nil and name ~= '' then
            for i = 1, (members - 1) do
                local unit = group_type .. i
                local unitName, _ = UnitName(unit)
                if unitName == name then
                    return unit
                end
            end
        end

        for i = 1, (members - 1) do
            local unit = group_type .. i

            if (UnitGroupRolesAssigned(unit) == 'HEALER') and not UnitCanAttack('player', unit) and not UnitIsDeadOrGhost(unit) then
                return unit
            end
        end
    end

    return 'player'
end

local function gcd()
end

--- Combat Rotation
local function combat()


    if talent(5, 3) then
        burst = SB.IncarnationBalance
    else
        burst = SB.CelestialAlignment
    end

    local aoeTarget = 4

    if not arcanicPulsar == true and not talent(5, 2) and talent(6, 1) then
        aoeTarget = 3
    end
    if talent(6, 2) and (arcanicPulsar == true or talent(5, 2)) then
        aoeTarget = 5
    end

    if toggle('multitarget', false) then
        enemyCount = enemies.around(40)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end

    z = z + 1    --combat timer

    -----------------------------
    --- Reading from settings
    -----------------------------
    local intpercent = dark_addon.settings.fetch('balpal_settings_intpercent', 80)
    local usehealthstone = dark_addon.settings.fetch('balpal_settings_healthstone.check', 25)
    local usehealpot = dark_addon.settings.fetch('balpal_settings_usehealpot', true)
    local healthstonepercent = dark_addon.settings.fetch('balpal_settings_healthstone.spin', 20)
    local autoRacial = dark_addon.settings.fetch('balpal_settings_autoRacial', true)
    local arcanicPulsar = dark_addon.settings.fetch('balpal_settings_arcanicPulsar', false)
    local innervateTarget = dark_addon.settings.fetch('balpal_settings_innervateTarget', '')
    local autoPotion = dark_addon.settings.fetch('balpal_settings_autoPotion', 'pot_a')
    local autoRune = dark_addon.settings.fetch('balpal_settings_autoRune', 'rune_a')
    local az_ss = dark_addon.settings.fetch('balpal_settings_az_ss', false)
    local az_ls = dark_addon.settings.fetch('balpal_settings_az_ls', false)
    local autoDot = dark_addon.settings.fetch('protwarrior_defensives_autoDot.check', true)
    local autoDotCount = dark_addon.settings.fetch('protwarrior_defensives_autoDot.spin', 3)




    -----------------------------
    --- Modifiers
    -----------------------------
    --battle rez
    if modifier.control and not mouseover.alive and -spell(SB.Rebirth) == 0 then
        if modifier.control and not mouseover.alive and mouseover.castable(SB.Rebirth) then
            return cast(SB.Rebirth, 'mouseover')
        end
    end
    --Starfall
    if modifier.lshift and talent(5, 1) and enemyCount >= aoeTarget and -spell(SB.Starfall) == 0 and castable(SB.Starfall) and power.astral.actual > 40 then
        return cast(SB.Starfall, 'ground')
    elseif modifier.lshift and enemyCount >= aoeTarget and -spell(SB.Starfall) == 0 and power.astral.actual > 50 then
        return cast(SB.Starfall, 'ground')
    end

    if modifier.lalt then
        if castable(SB.BearForm) and not -buff(SB.BearForm) then
            return cast(SB.BearForm)
        end
        if castable(SB.Barkskin) and not -buff(SB.Barkskin) then
            return cast(SB.Barkskin)
        end
        if talent(3, 2) and player.buff(SB.Bearform).up and player.castable(SB.FrenziedRegeneration) and player.health.percent < 50 then
            return cast(SB.FrenziedRegeneration)
        end
        if -buff(SB.Barkskin) and -buff(SB.BearForm) then
            return
        end
    end
    --Manual treants
    if talent(1, 3) and modifier.ralt and -spell(SB.ForceofNature) == 0 then
        return cast(SB.ForceofNature, 'ground')
    end

    if GetShapeshiftForm() == 3 or player.buff(SB.Prowl).up or player.buff(SB.TigerDashBuff).up or player.buff(SB.Dash).up or not player.alive then
        return
    end

    ----------------------------------------------------------
    --- Health stone / Trinket  / Items / etc
    ----------------------------------------------------------

    --Health stone
    if usehealthstone == true and player.health.percent < healthstonepercent and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
        macro('/use Healthstone')
    end
    --health pot
    if usehealpot == true and GetItemCount(152494) >= 1 and player.health.percent < healthstonepercent and GetItemCooldown(5512) > 0 then
        macro('/use Coastal Healing Potion')
    end

    --trinkets

    local useTrinkets = "false"

    --Ancient knot of wisdom
    if useTrinkets == "true" and GetItemCount(166793) == 1 and GetItemCooldown(166793) == 0 and ((player.buff(SB.CelestialAlignment).up or player.buff(SB.IncarnationBalance).up) or (-spell(SB.CelestialAlignment) > 30 or -spell(SB.IncarnationBalance) > 30)) then
        macro('/use 13')
    end

    --potions



    if autoPotion == "pot_b" and target.time_to_die > 10 and player.buff(burst).remains > 6 and GetItemCount(163222) >= 1 and GetItemCooldown(163222) == 0 then
        macro('/use Battle Potion of Intellect')
        print("glug - battle potion of intellect - glug")
    end
    if autoPotion == "pot_c" and target.time_to_die > 10 and player.buff(burst).remains > 6 and GetItemCount(109218) >= 1 and GetItemCooldown(109218) == 0 then
        print("glug - Draenic int - glug")
        macro('/use Draenic Intellect Potion')
    end

    if autoPotion == "pot_d" and target.time_to_die > 10 and player.buff(burst).remains > 6 and GetItemCount(152559) >= 1 and GetItemCooldown(152559) == 0 then
        macro('/use Potion of rising death')
        print("glug - deadly grace - glug")
    end

    --Flasks
    if player.buff(SB.FlaskofEndlessFathoms).down and not autoRune == "rune_a" then
        if autoRune == "rune_b" and (player.buff(SB.WhisperInsanityBuff).down or player.buff(SB.WhisperInsanityBuff).remains < 600) and GetItemCount(118922) == 1 and GetItemCooldown(118922) == 0 then
            macro('/use item:118922')
            print("Applying WhisperInsanityBuff")
        end
    end
    -- Interupts
    if toggle('interrupts', false) and target.interrupt(intpercent) and target.distance <= 45 and target.castable(SB.SolarBeam) then
        return cast(SB.SolarBeam, 'target')
    end

    -- Barkskin
    if player.health.percent < 65 and -spell(SB.Barkskin) == 0 then
        cast(SB.Barkskin, 'player')
    end

    --Renewal
    if talent(2, 2) and -spell(SB.Renewal) == 0 and player.health.percent < 50 then
        return cast(SB.Renewal, player)
    end

    --soothe
    if target.castable(SB.Soothe) then
        for i = 1, 40 do
            local name, _, _, count, debuff_type, _, _, _, _, spell_id = UnitAura("target", i)
            if name and DS[spell_id] then
                print("Soothing " .. name .. " off the target.")
                return cast(SB.Soothe, target)
            end
        end
    end

    -----------------------------
    --- Racial active ability
    -----------------------------
    if autoRacial == true and -spell(SB.Berserking) == 0 and (player.buff(burst).remains > 10 or -spell(burst) > 30) then
        cast(SB.Berserking)
    end
    --todo add other races

    -----------------------------
    --- WarriorOfElune
    -----------------------------
    if talent(1, 2) and -spell(SB.WarriorOfElune) == 0 and player.buff(SB.WarriorOfElune).down then
        return cast(SB.WarriorOfElune)
    end

    -----------------------------
    ---     Innervate
    -----------------------------

    if toggle('Innervate', false) and IsInGroup() and -spell(SB.Innervate) == 0 then
        local iTarget = dark_addon.environment.conditions.unit(findHealer(innervateTarget))
        if iTarget.unitID ~= "player" and iTarget.distance <= 45 and iTarget.power.mana.percent < 99 then
            print("Innervate on " .. iTarget.name)
            return cast(SB.Innervate, iTarget)
        elseif iTarget.unitID == "player" then
            print("INVALID INNOTARGET NAME")
        end
    end


    -----------------------------
    --- autoDot
    -----------------------------

    if autoDot and mouseover.castable(SB.Moonfire) and mouseover.alive and UnitAffectingCombat and mouseover.enemy and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 6) then
        autoDotCountCurrent = autoDotCountCurrent + 1
        return cast(SB.Moonfire, 'mouseover')

    end
    -----------------------------
    --- Rotation
    -----------------------------

    -----------------------------
    --- Moving!
    -----------------------------
    -- Moonkin Form
    if not modifier.lalt and UnitLevel("player") >= 20 and not player.spell(SB.MoonkinForm).lastcast and player.buff(SB.TigerDashBuff).down and GetShapeshiftForm() ~= 4 then
        return cast(SB.MoonkinForm, player)
    end

    if player.moving and player.buff(SB.StellarDrift).down then
        if talent(1, 2) then
            if player.buff(SB.WarriorOfElune).up and target.castable(SB.LunarStrike) then
                return cast(SB.LunarStrike, 'target')
            end
            if player.buff(SB.WarriorOfElune).down and -spell(SB.WarriorOfElune) == 0 then
                return cast(SB.WarriorOfElune, player)
            end
        end
        if not modifier.shift and -spell(SB.Starsurge) == 0 and power.astral.actual >= 40 then
            return cast(SB.Starsurge, 'target')
        end

        if -spell(SB.Moonfire) == 0 and not target.debuff(SB.Moonfire) then
            return cast(SB.Moonfire, target)
        end
        if target.castable(SB.Sunfire) then
            return cast(SB.Sunfire, 'target')
        end
        if -spell(SB.Moonfire) == 0 then
            return cast(SB.Moonfire, target)
        end
    end


    -----------------------------
    --- Opener   it is assumed that you start the fight with a solar wrath
    -----------------------------
    --todo rewrite starlord opener ...its shit
    --starlord opener
    if toggle('opener', false) and y ~= 99 and arcanicPulsar == true and talent(5, 2) then
        if target.castable(SB.SolarWrath) and y == 0 then
            y = y + 1
            print("Starting opener")
            return cast(SB.SolarWrath, 'target')
        end

        if player.buff(SB.Starlord).count == 3 and power.astral.actual >= 40 and toggle('cooldowns', false) then

            local badguy = UnitClassification("target")
            y = 4
            if badguy ~= "normal" and badguy ~= "minus" then
                if talent(7, 3) and power.astral.actual > 40 and -spell(SB.IncarnationBalance) == 0 then
                    return cast(SB.IncarnationBalance)
                elseif power.astral.actual > 40 and -spell(SB.CelestialAlignment) == 0 then
                    return cast(SB.CelestialAlignment)
                end
            end
        end

        if player.buff(SB.Starlord).count <= 2 and y == 1 then
            if target.castable(SB.Starsurge) then
                return cast(SB.Starsurge, 'target')
            end
            if target.castable(SB.Moonfire) and y == 1 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 6) then
                return cast(SB.Moonfire, 'target')
            end
            if target.castable(SB.Sunfire) and y == 1 and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 5) then
                return cast(SB.Sunfire, 'target')
            end
            if talent(6, 3) and target.castable(SB.StellarFlare) and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
                return cast(SB.StellarFlare, 'target')
            end
            if target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 and player.buff(SB.SolarEmpowerment).count == 0 then
                return cast(SB.LunarStrike, 'target')
            end
            if target.castable(SB.SolarWrath) then
                return cast(SB.SolarWrath, 'target')
            end
        end

        if player.buff(SB.Starlord).count == 3 then
            y = 2
        end

        if y == 2 and power.astral.actual < 40 then

            if target.castable(SB.Moonfire) and y == 2 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 6) then
                return cast(SB.Moonfire, 'target')
            end
            if target.castable(SB.Sunfire) and y == 2 and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 5) then
                return cast(SB.Sunfire, 'target')
            end
            if talent(6, 3) and target.castable(SB.StellarFlare) and not lastcast(SB.StellarFlare) and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
                return cast(SB.StellarFlare, 'target')
            end
            if target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 and player.buff(SB.SolarEmpowerment).count == 0 then
                return cast(SB.LunarStrike, 'target')
            end
            if target.castable(SB.SolarWrath) then
                return cast(SB.SolarWrath, 'target')
            end
        end

        if power.astral.actual >= 80 then
            y = 3
        end

        if y == 2 and power.astral.actual < 80 then

            if target.castable(SB.Moonfire) and y == 3 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 6) then
                return cast(SB.Moonfire, 'target')
            end
            if target.castable(SB.Sunfire) and y == 3 and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 5) then
                return cast(SB.Sunfire, 'target')
            end
            if talent(6, 3) and target.castable(SB.StellarFlare) and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
                return cast(SB.StellarFlare, 'target')
            end
            if target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 and player.buff(SB.SolarEmpowerment).count == 0 then
                return cast(SB.LunarStrike, 'target')
            end
            if target.castable(SB.SolarWrath) then
                return cast(SB.SolarWrath, 'target')
            end
        end
        if y == 3 and power.astral.actual >= 80 then
            print("done")
            y = 99
            macro('/cancelaura Starlord')
        end
    end -- end starlord opener

    -- standard opener
    if toggle('opener', false) and not talent(5, 2) and y ~= 99 then
        if target.castable(SB.SolarWrath) and y <= 1 then
            y = y + 1
            return cast(SB.SolarWrath, 'target')
        end
        if talent(6, 3) and target.castable(SB.StellarFlare) and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
            return cast(SB.StellarFlare, 'target')
        end
        if target.castable(SB.Sunfire) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 5) then
            return cast(SB.Sunfire, 'target')
        end
        if target.castable(SB.Moonfire) and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 6) then
            return cast(SB.Moonfire, 'target')
        end

        if y ~= 3 and target.debuff(SB.MoonfireDebuff).exists and target.debuff(SB.SunfireDebuff).exists then
            y = 3
        end

        if y == 3 and power.astral.actual < 40 then
            if target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 and player.buff(SB.SolarEmpowerment).count == 0 then
                return cast(SB.LunarStrike, 'target')
            end
            if target.castable(SB.SolarWrath) then
                return cast(SB.SolarWrath, 'target')
            end
        elseif y == 3 and power.astral.actual >= 40 then
            print("opener stop")
            y = 99
        end
    end -- standard opener


    --- CD /Healing
    if toggle('Heal', false) then

        if talent(3, 3) then
            -- Swiftmend
            if player.castable(SB.Swiftmend) and player.health.percent < 50 and (not player.buff(SB.MoonkinForm).exists or player.health.percent < 30) then
                return cast(SB.Swiftmend, player)
            end
            -- Rejuvenation
            if player.castable(SB.Rejuvenation) and player.health.percent < 75 and not player.buff(SB.MoonkinForm).exists and not (player.buff(SB.Rejuvenation).up or player.buff(SB.RejuvenationGermination).up) then
                return cast(SB.Rejuvenation, player)
            end
        end

        -- Regrowth
        if player.castable(SB.Regrowth) and ((player.health.percent < 48 and not player.buff(SB.Regrowth).up) or player.health.percent < 30) then
            return cast(SB.Regrowth, player)
        end


    end

    -----------------------------
    --- CoolDowns
    -----------------------------
    badguy = UnitClassification("target")
    -- and badguy ~= "normal" and badguy ~= "minus"
    if toggle('cooldowns', false) and target.time_to_die > 5 then
        if talent(5, 3) and power.astral.actual > 40 and -spell(SB.IncarnationBalance) == 0 then
            return cast(SB.IncarnationBalance)
        elseif player.castable(burst)
                and (not az_ls or player.buff(SB.LivelySpirit).up)
                and (player.buff(SB.Starlord).count >= 2 or not talent(5, 2)) then
            return cast(burst)
        end

        if talent(7, 2) and -player.spell(SB.FuryofElune) == 0 and power.astral.actual <= 87 and (player.buff(burst).up or -spell(burst) > 30) then
            return cast(SB.FuryofElune, 'target')
        end
    end

    -----------------------------
    --- Treants
    -----------------------------

    if talent(1, 3) and toggle('FON', false) and -spell(205636) == 0 and mouseover.alive and UnitAffectingCombat and mouseover.enemy and (player.buff(burst).remains > 10 or -spell(burst) > 30) then
        return cast(SB.ForceofNature, 'ground')
    end



    -----------------------------
    --- StarSurge / Starlord
    -----------------------------

    --new starsurge


    if power.astral.actual >= 87 and player.buff(SB.Starlord).up and player.buff(SB.Starlord).remains <= 7 then
        -- print("canceling at: " .. player.buff(SB.Starlord).remains)
        macro('/cancelaura Starlord')
    end

    if not modifier.shift and talent(5, 2) and target.castable(SB.Starsurge) and power.astral.actual >= 40 then
        if (player.buff(SB.Starlord).count < 3 or player.buff(SB.Starlord).remains >= 8 and player.buff(SB.ArcanicPulsar).count < 8)
                and enemyCount <= aoeTarget
                and (player.buff(SB.SolarEmpowerment).count + player.buff(SB.LunarEmpowerment).count) < 4
                and player.buff(SB.SolarEmpowerment).count < 3
                and player.buff(SB.LunarEmpowerment).count < 3
                and (not az_ss or not player.buff(burst).up or not player.spell(SB.Starsurge).lastcast)
                or target.time_to_die <= (1.5 / ((UnitSpellHaste("player") / 100) + 1)) * power.astral.actual % 40
                or power.astral.actual >= 87 then
            return cast(SB.Starsurge, 'target')
        end
    end

    if not modifier.shift and not talent(5, 2) and enemyCount < aoeTarget and target.castable(SB.Starsurge) and player.buff(SB.LunarEmpowerment).count <= 2 and player.buff(SB.SolarEmpowerment).count <= 2 then
        return cast(SB.Starsurge, 'target')
    end

    --sunfire

    local floor = math.floor(target.time_to_die % (2 * UnitSpellHaste("player")) * enemyCount)
    local ceiling = math.floor(2 % enemyCount) * 1.5

    if target.castable(SB.Sunfire) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) and power.astral.actual < 87 and floor >= ceiling + 2 * enemyCount
            and (enemyCount > 1 or target.debuff(SB.Moonfire).up)
            and (not az_ss or not player.buff(burst).up or not player.spell(SB.Sunfire).lastcast) then
        return cast(SB.Sunfire, 'target')
    end
    --moonfire

    if target.castable(SB.Moonfire) and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8)
            and target.time_to_die % (2 * UnitSpellHaste("player")) * enemyCount >= 6
            and (not az_ss or not player.buff(burst).up or not player.spell(SB.Moonfire).lastcast) then
        return cast(SB.Moonfire, 'target')
    end

    -- stellar
    if target.castable(SB.StellarFlare) and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2)
            and target.time_to_die % (2 * UnitSpellHaste("player")) >= 5
            and (not az_ss or not player.buff(burst).up or not player.spell(SB.StellarFlare).lastcast) then
        return cast(SB.StellarFlare, 'target')
    end

    if talent(7, 3) then
        -- fullmoon talent rotation
        if target.castable(SB.Fullmoon) and power.astral.actual <= 55 then
            return cast(SB.Fullmoon, target)
        elseif target.castable(SB.Halfmoon) and power.astal.actual <= 78 then
            return cast(SB.Halfmoon, target)
        elseif target.castable(SB.Newmoon) and power.astral.actual <= 86 then
            return cast(SB.Newmoon, target)
        end
    end

    if target.castable(SB.LunarStrike) then
        if (player.buff(SB.SolarEmpowerment).count < 3 or player.buff(SB.SolarEmpowerment).down)
                and (power.astral.actual <= 86 or player.buff(SB.LunarEmpowerment).count == 3)
                and ((player.buff(SB.WarriorOfElune).up or player.buff(SB.LunarEmpowerment).up or enemyCount >= 2
                and player.buff(SB.SolarEmpowerment).down)
                and (not az_ss or player.buff(burst).down
                or (not player.spell(SB.LunarStrike).lastcast and not talent(5, 3) or player(SB.SolarWrath).lastcast))
                or az_ss and player.buff(burst).up and player.spell(SB.SolarWrath).lastcast) then
            return cast(SB.LunarStrike, 'target')
        end
    end


    --solar_wrath,if=variable.az_ss<3|!buff.ca_inc.up|!prev.solar_wrath
    if target.castable(SB.SolarWrath) and (player.buff(SB.StreakingStars).down or player.buff(SB.StreakingStars).count < 3)
            or player.buff(burst).down or not player.spell(SB.SolarWrath).lastcast then
        return cast(SB.SolarWrath, 'target')
    end

    if target.castable(SB.Sunfire) then
        return cast(SB.Sunfire)
    end
end

--todo add support for off-specs


--[[
--TANK SECTION - EMERGENCY BEAR
if toggle('TANK', false) and talent(3, 2) then

if toggle('interrupts', false) and target.interrupt() and player.talent(4, 1) and -spell(SB.MightyBash) == 0 then
return cast(SB.MightyBash)
end

--going bear
if castable(SB.BearForm, 'player') and not -buff(SB.BearForm) then
return cast(SB.BearForm, 'player')
end

auto_attack()

--- Frenzied Regeneration
if castable(SB.FrenziedRegeneration, 'player') and not -buff(SB.FrenziedRegeneration) and player.health.percent < 50 then
return cast(SB.FrenziedRegeneration, 'player')
end

if castable(SB.Ironfur, 'player') and not -buff(SB.Ironfur) then
return cast(SB.Ironfur, 'player')
end

if not target.debuff(SB.MoonfireDebuff) or target.debuff(SB.MoonfireDebuff).remains <= 3 then
return cast(SB.Moonfire, 'target')
end

if -spell(SB.Mangle) == 0 and target.distance <= 10 then
return cast(SB.Mangle, 'target')
end

if castable(SB.Thrash, 'target') and target.distance <= 10 then
return cast(SB.Thrash, 'target')
end
return
end
]]-- end auto bear


local function resting()


    y = 0
    z = 0

    -----------------------------
    --- Modifiers
    -----------------------------
    if modifier.control and not mouseover.alive and -spell(SB.Revive) == 0 then
        return cast(SB.Revive, 'mouseover')
    end

    if modifier.lalt then
        if castable(SB.BearForm) and not -buff(SB.BearForm) then
            return cast(SB.BearForm)
        end
        if castable(SB.Barkskin) and not -buff(SB.Barkskin) then
            return cast(SB.Barkskin)
        end
        if -buff(SB.Barkskin) and -buff(SB.BearForm) then
            return
        end
    end

    if GetShapeshiftForm() == 3 and player.moving then
        return
    elseif toggle('Forms', false) and not player.moving and UnitLevel("player") >= 20 and player.buff(SB.Prowl).down and player.buff(SB.MoonkinForm).down and player.buff(SB.TigerDashBuff).down and player.buff(1850).down and player.alive then
        x = x + 1
        if x >= 14 then
            x = 0
            return cast(SB.MoonkinForm)
        end
    end

    if player.alive then
        if toggle('Heal', false) then
            -- Swiftmend
            if player.castable(SB.Swiftmend) and player.health.percent < 50 and (not player.buff(SB.MoonkinForm).exists or player.health.percent < 30) then
                return cast(SB.Swiftmend, player)
            end
            -- Rejuvenation
            if player.castable(SB.Rejuvenation) and player.health.percent < 75 and not player.buff(SB.MoonkinForm).exists and not (player.buff(SB.Rejuvenation).up or player.buff(SB.RejuvenationGermination).up) then
                return cast(SB.Rejuvenation, player)
            end
            -- Regrowth
            if player.castable(SB.Regrowth) and ((player.health.percent < 48 and not player.buff(SB.Regrowth).up) or player.health.percent < 30) then
                return cast(SB.Regrowth, player)
            end
            -- Barkskin
            if player.health.percent < 20 and -spell(SB.Barkskin) == 0 then
                return cast(SB.Barkskin, 'player')
            end
        end
        local outdoor = IsOutdoors()
        if toggle('Forms', false) and player.moving and player.buff(SB.Prowl).down and player.buff(SB.TigerDashBuff).down and player.buff(1850).down and player.alive then
            x = x + 1
            if player.moving and player.buff(SB.CatForm).up and -spell(SB.Dash) == 0 then
                return cast(SB.Dash)
            end
            if outdoor and x >= 8 then
                x = 0
                return cast(SB.TravelForm)
            end

            if not outdoor and x >= 8 and player.buff(SB.CatForm).down then
                x = 0
                return cast(SB.CatForm)
            end
        end

    end
end
local function interface()

    local settings = {
        key = 'balpal_settings',
        title = 'Balance Druid',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = '               Balance Druid Settings' },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine.' },
            { type = 'rule' },
            { type = 'text', text = 'General Settings' },
            { key = 'healthstone', type = 'checkspin', default = '30', text = 'Healthstone', desc = 'Auto use Healthstone at health %', min = 5, max = 100, step = 5 },
            -- { key = 'input', type = 'input', text = 'TextBox', desc = 'Description of Textbox' },
            { key = 'usehealpot', type = 'checkbox', text = 'Healing Pot', desc = 'Use Coastal Healing Potion if HS on CD/none' },
            { key = 'intpercent', type = 'spinner', text = 'Interrupt %', default = '50', desc = '% cast time to interrupt at', min = 5, max = 100, step = 5 },
            { key = 'autoDot', type = 'checkspin', text = 'Auto Dot', desc = 'Max dot targets', default_check = true, default_spin = 35, min = 1, max = 5, step = 1 },
            { type = 'rule' },
            { type = 'text', text = 'Utility' },
            { key = 'autoRacial', type = 'checkbox', text = 'Racial', desc = 'Use Racial on CD (Troll only)' },
            { key = 'arcanicPulsar', type = 'checkbox', text = 'Arcanic Pulsar', desc = 'this changes the rotation, do you have it?' },
            { key = 'az_ss', type = 'checkbox', text = 'Streaking Stars', desc = 'this changes the rotation, do you have it?' },
            { key = 'az_ls', type = 'checkbox', text = 'Living Spirit', desc = 'this changes the rotation, do you have it?' },
            { key = 'innervateTarget', type = 'input', default = '', text = 'Inno Target (blank for auto)', desc = '' },
            { type = 'rule' },
            { key = 'autoPotion', type = 'dropdown',
              text = 'Potion',
              desc = 'Potion to auto use',
              default = 'pot_a',
              list = {
                  { key = 'pot_a', text = 'NONE' },
                  { key = 'pot_b', text = 'Battle Potion of Intellect' },
                  { key = 'pot_c', text = 'Draenic Intellect Potion' },
                  { key = 'pot_d', text = 'Potion of rising death' },
              }
            },
            { key = 'autoRune', type = 'dropdown',
              text = 'Auto Rune',
              desc = '',
              default = 'rune_a',
              list = {
                  { key = 'rune_a', text = 'NONE' },
                  { key = 'rune_b', text = 'Oralius Whispering Crystal' },
              }
            },

        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'opener',
        label = 'Opener',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('bars'),
            color = dark_addon.interface.color.green,
            color2 = dark_addon.interface.color.dark_green
        },
        off = {
            label = dark_addon.interface.icon('bars'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })

    dark_addon.interface.buttons.add_toggle({
        name = 'Heal',
        label = 'Defensive CD',
        on = {
            label = 'Heal',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Heal',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'Forms',
        label = 'change forms',
        on = {
            label = 'Forms',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Forms',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'racial',
        label = 'Use Racial',
        on = {
            label = 'Racial',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Racial',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'FON',
        label = 'Auto Treants',
        on = {
            label = 'FoN',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'FoN',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'Innervate',
        label = 'Auto Innervate',
        on = {
            label = 'Inno',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Inno',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'TANK',
        label = 'bear form tank',
        on = {
            label = 'BEAR',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'OWL',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
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

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.druid.balance,
    name = 'balpal',
    label = 'PAL: Balance Druide',
    combat = combat,
    gcd = gcd,
    resting = resting,
    interface = interface
})
