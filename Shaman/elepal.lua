-- modifiers:
-- Holding down shift will first cast Magna Totem if you got the talent then/or Earthquake - all at cursor. Shift == AOE
-- Holding down Control will cast stun totem at cursor
-- Holding down ALT will drop your totems - if you got the talent

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.shaman
local race = UnitRace("player")
local x = 0
local az_nh
local maelstrom_pool = 100



--Spells not in spellbook
SB.Berserking = 26297
SB.StormKeeper = 191634
SB.Stormelemental = 192249
SB.EarthElemental = 198103
SB.Windgust = 263806
SB.Flameshock = 188389
SB.Surgeofpower = 285514
SB.MasteroftheElements = 260734
SB.Bloodlust = 2825
SB.ElementalBlast = 117014
SB.Lightningbolt = 188196
SB.Earthshock = 8042
SB.Lavaburst = 51505
SB. AzeriteEchooftheElementals = 275381

local function combat()
    local current_gcd = (1.5 / ((UnitSpellHaste("player") / 100) + 1))
    if talent(2, 2) then
        maelstrom_pool = 120
    end

    if toggle('multitarget', false) then
        enemyCount = enemies.around(40)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end

    if talent(2, 3) and modifier.alt then
        return cast(SB.TotemMastery)
    end

    if modifier.shift then
        if talent(4, 3) and toggle('cooldowns') and -spell(SB.LiquidMagmaTotem) == 0 and not player.spell(SB.LiquidMagmaTotem).lastcast then
            return cast(SB.LiquidMagmaTotem, 'ground')
        elseif -power.maelstrom >= 60 then
            return cast(SB.Earthquake, 'ground')
        end
    end

    if modifier.control and -spell(SB.CapacitorTotem) == 0 then
        return cast(SB.CapacitorTotem, 'ground')
    end

    if target.alive and target.enemy then

        if talent(2, 3) and player.buff(SB.StormTotem).down then
            return cast(SB.TotemMastery)
        end
        -- defensive cooldowns
        if toggle('DEF', false) then
            if castable(SB.AstralShift) and player.health.percent <= 80 then
                return cast(SB.AstralShift, player)
            end
            if player.health.percent <= 30 and castable(SB.HealingSurgeEle, player) then
                return cast(SB.HealingSurgeEle, player)
            end
            if player.health.percent <= 50 and castable(SB.EarthElemental) == 0 then
                return cast(SB.EarthElemental, player)
            end
        end
        --------------------
        --- racial
        --------------------
        if race == 'Troll' then
            if talent(7, 3) and player.buff(SB.Ascendance).up and player.castable(SB.Berserking) then
                cast(SB.Berserking)
            elseif not talent(7, 3) and -spell(SB.Berserking) == 0 then
                cast(SB.Berserking)
            end
        end
        -- Interupts
        if toggle('interrupts', false) and target.castable(SB.WindShear) and target.interrupt(math.random(25, 75)) and target.distance <= 30 then
            return cast(SB.WindShear, 'target')
        end

        if talent(2, 3) and player.buff(SB.StormTotem).down then
            return cast(SB.TotemMastery)
        end

        --moving
        if player.moving then
            if player.buff(SB.Ascendance).up and target.castable(SB.Lavaburst) then
                return cast(SB.Lavaburst, target)
            elseif target.castable(SB.Flameshock) and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) then
                return cast(SB.Flameshock, target)
            elseif target.castable(SB.FrostShock) then
                return cast(SB.FrostShock)
            end
        end

        --single target rotation
        if enemyCount <= 2 then
            print(enemyCount)
            --flameshock
            if target.castable(SB.Flameshock) then
                if target.debuff(SB.Flameshock).down
                        or (talent(4, 2) and -spell(SB.Stormelemental) < 2 * current_gcd
                        or target.debuff(SB.Flameshock).remains <= current_gcd
                        or talent(7, 3) and target.debuff(SB.Flameshock).remains < (-spell(SB.Ascendance) + 15) and -spell(SB.Ascendance) < 4
                        and (not talent(4, 2) or talent(4, 2) and -spell(SB.Stormelemental) < 120))
                        and player.buff(SB.Windgust).count < 14 and player.buff(SB.Surgeofpower).down then
                    return cast(SB.Flameshock, target)
                end
            end
            print("2")

            --Cool Downs

            if toggle('cooldowns') and castable(SB.FireElemental) then
                return cast(SB.FireElemental)
            end
            -- if toggle('cooldowns') and -spell(SB.EarthElemental) == 0 and -spell(SB.FireElemental) > 60 and -spell(SB.FireElemental) < 120 then
            --   return cast(SB.EarthElemental)
            -- end

            --ascendance
            if talent(7, 3) and toggle('cooldowns', false) and -spell(SB.Ascendance) == 0 then
                if player.buff(SB.Bloodlust).up
                        or -spell(SB.Lavaburst) > 0
                        and (not talent(4, 2) or talent(4, 2) and -spell(SB.Stormelemental) > 120)
                        and (not talent(6, 3) or player.buff(SB.Icefury).down and -spell(SB.Icefury > 0)) then
                    return cast(SB.Ascendance, player)
                end
            end


            --elemental blast
            if talent(1, 3) and target.castable(SB.ElementalBlast)
                    and (talent(4, 1) and player.buff(SB.MasteroftheElements).up and -power.maelstrom < 60 or not talent(4, 1))
                    and (not (-spell(SB.Stormelemental) > 120 and talent(4, 2))
                    or az_nh and player.buff(SB.AzeriteNaturalHarmony).count == 3 and (player.buff(SB.windgust).down or player.buff(SB.Windgust).count < 14)) then
                return cast(SB.ElementalBlast, target)
            end

            --stormkeepoer
            if talent(7, 2) and -spell(SB.StormKeeper) == 0 and not talent(6, 1) then
                return cast(SB.StormKeeper, player)
            elseif talent(7, 2) and talent(6, 1) and player.buff(SB.Surgeofpower).up and -power.maelstrom >= 44 then
                return cast(SB.StormKeeper, player)
            end

            --nukes if we runnig out of time
            if target.castable(SB.Lightningbolt) and (player.buff(SB.StormKeeper).remains < current_gcd * 4 * player.buff(SB.StormKeeper).count) then
                return cast(SB.Lightningbolt, target)
            end

            --frost shock
            if target.castable(SB.FrostShock) then
                if talent(6, 3) and player.buff(SB.Icefury).up and
                        (player.buff(SB.Icefury).remains < current_gcd * 4 * player.buff(SB.Icefury).count)
                        or player.moving then
                    return cast(SB.FrostShock, target)
                end
            end

            --lightning bolt
            if target.castable(SB.Lightningbolt) then
                if player.buff(SB.StormKeeper).up
                        and enemyCount < 2
                        and (player.buff(SB.MasteroftheElements).up and (not talent(6, 1) or player.buff(SB.Surgeofpower).up)) then
                    return cast(SB.Lightningbolt, target)
                end
            end


            --earth shock 1
            --[[if target.castable(SB.Earthshock) then
                if player.buff(SB.Surgeofpower).down and talent(4, 1)
                        and (player.buff(SB.MasteroftheElements).up or -power.maelstrom >= (maelstrom_pool - 8) or player.buff(SB.StormKeeper).up and enemyCount < 2)
                        or not talent(4, 1) and (player.buff(SB.StormKeeper).up
                        or -power.maelstrom >= (maelstrom_pool - 8)
                        or not (-spell(SB.Stormelemental) > 120 and talent(4, 2))
                        and target.time_to_die - -spell(SB.Stormelemental) - 150 * math.floor((target.time_to_die - -spell(SB.Stormelemental)) % 150) >= 30 * (1 + (player.buff(SB.AzeriteEchooftheElementals).count >= 2))) then
                    return cast(SB.Earthshock, target)
                elseif talent(4, 1) and player.buff(SB.Surgeofpower).down
                        and -spell(SB.LavaBurst) <= current_gcd and (not talent(4, 2) and not (-spell(SB.FireElemental) > 120
                        or talent(4, 2) and not -spell(SB.Stormelemental) > 120)) then
                    return cast(SB.Earthshock, target)
                end
            end
]]
            if target.castable(SB.EarthShock) then
                if talent(4, 1) and player.buff(SB.Surgeofpower).down and player.buff(SB.MasteroftheElements).up or -power.maelstrom >= (maelstrom_pool - 8) or (player.buff(SB.StormKeeper).up and enemyCount < 2) then
                    return cast(SB.Earthshock, target)
                elseif not talent(4, 1) and (player.buff(SB.StormKeeper).up or -power.maelstrom >= (maelstrom_pool - 8)) then
                    return cast(SB.Earthshock, target)
                elseif not (talent(4, 2) or -spell(SB.Stormelemental) > 120) and target.time_to_die - -spell(SB.Stormelemental) - 150 * math.floor((target.time_to_die - -spell(SB.Stormelemental)) % 150) >= 30 * (1 + (player.buff(SB.AzeriteEchooftheElementals).count)) >= 2 then
                    return cast(SB.Earthshock, target)
                end

            end

            --lightningbolt - round2
            if talent(4, 2) and target.castable(SB.Lightningbolt) and -spell(SB.Stormelemental) > 120 then
                return cast(SB.Lightningbolt, target)
            end

            --frost shock
            if talent(6, 3) and talent(4, 1) and player.buff(SB.Icefury).up and player.buff(SB.MasteroftheElements).up then
                return cast(SB.FrostShock, target)
            end

            --lavaburst
            if player.buff(SB.Ascendance).up and target.castable(SB.LavaBurst) then
                return cast(SB.LavaBurst, target)
            end

            --re-dot
            if target.castable(SB.Flameshock) and enemyCount > 1 and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) and player.buff(SB.Surgeofpower).up then
                return cast(SB.Flameshock, target)
            elseif target.castable(SB.Flameshock) and enemyCount == 1 and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) and player.buff(SB.Surgeofpower).down then
                return cast(SB.Flameshock, target)
            end

            --lightningbolt - round3
            if target.castable(SB.Lightningbolt) and player.buff(SB.Surgeofpower).up then
                return cast(SB.Lightningbolt, target)
            end
            --lava burst
            if target.castable(SB.LavaBurst) then
                return cast(SB.LavaBurst, target)
            end

            if talent(6, 3) and target.castable(SB.Icefury) then
                return cast(SB.Icefury, target)
            end

            --lightningbolt - round4
            if target.castable(SB.Lightningbolt) then
                return cast(SB.Lightningbolt, target)
            end

            if target.castable(SB.FrostShock) then
                return cast(SB.FrostShock, target)
            end
        end --end single rotation

        --AOE rotation
        if enemyCount >= 3 then

            --stormkeeper
            if talent(7, 2) and -spell(SB.StormKeeper) == 0 then
                return cast(SB.StormKeeper, player)
            end
            --Ascendance
            if talent(7, 3) and -spell(SB.Ascendance) == 0 then
                if (talent(4, 2) and -spell(SB.Stormelemental) < 120 and -spell(SB.Stormelemental) > 15 or not talent(4, 2)) then
                    return cast(SB.Ascendance)
                end
            end
            -- flame shock
            if target.castable(SB.Flameshock) and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6)
                    and enemyCount < 5 and (not talent(4, 2) or (talent(4, 2) and -spell(SB.Stormelemental) < 120) or enemyCount == 3 and (player.buff(SB.Windgust).down or player.buff(SB.Windgust).count < 14)) then
                return cast(SB.Flameshock, target)
            end
            --lave burst
            if target.castable(SB.Lavaburst) and (player.buff(SB.LavaSurge).up or player.buff(SB.Ascendance).up)
                    and enemyCount < 4 and (not talent(4, 2) or (talent(4, 2) and -spell(SB.Stormelemental) < 120)) then
                return cast(SB.Lavaburst, target)
            end
            --elemental blast
            if talent(1, 3) and target.castable(SB.ElementalBlast) and enemyCount < 4 and (not talent(4, 2) or (talent(4, 2) and -spell(SB.Stormelemental) < 120)) then
                return cast(SB.ElementalBlast, target)
            end
            --lava beam
            if talent(7, 3) and player.buff(SB.Ascendance).up and target.castable(SB.LavaBeam) then
                return cast(SB.LavaBeam, target)
            end
            if target.castable(SB.ChainLightning) then
                return cast(SB.ChainLightning, target)

            end


        end -- end AOE
    end --end target alive
end -- end combat
local function resting()
    if talent(2, 3) and modifier.alt then
        return cast(SB.TotemMastery)
    end

    if modifier.shift and -power.maelstrom >= 60 then
        return cast(SB.Earthquake, 'ground')
    end

    if modifier.control and -spell(SB.CapacitorTotem) == 0 then
        return cast(SB.CapacitorTotem, 'ground')
    end

    if player.moving and not player.buff(SB.GhostWolf).up then
        x = x + 1
        if x >= 7 then
            x = 0
            return cast(SB.GhostWolf)
        end
    end
end

function interface()
    dark_addon.interface.buttons.add_toggle({
        name = 'DEF',
        label = 'Defensive CD',
        on = {
            label = 'DEF',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'DEF',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.shaman.elemental,
    name = 'elepal',
    label = '8.1 BETA',
    combat = combat,
    resting = resting,
    interface = interface

})