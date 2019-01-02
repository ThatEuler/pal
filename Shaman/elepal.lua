local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.shaman
local race = UnitRace("player")
local x = 0


local function combat()
    local current_gcd = (1.5 / ((UnitSpellHaste("player") / 100) + 1))

    --Spells not in spellbook
    SB.Berserking = 26297
    SB.StormKeeper = 191634


    if talent(2, 3) and modifier.alt then
        return cast(SB.TotemMastery)
    end

    if modifier.shift and -power.maelstrom >= 60 then
        return cast(SB.Earthquake, 'ground')
    end

    if modifier.control and -spell(SB.CapacitorTotem) == 0 then
        return cast(SB.CapacitorTotem, 'ground')
    end

    if target.alive and target.enemy then

        if talent(2, 3) and player.buff(SB.StormTotem).down then
            return cast(SB.TotemMastery)
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
        if toggle('interrupts', false) and target.interrupt(50) and target.distance <= 30 and castable(SB.WindShear) then
            return cast(SB.WindShear, 'target')
        end
    end
    --flameshock
    if target.castable(SB.Flameshock) and (target.debuff(SB.Flameshock).down
            or talent(4, 2) and -spell(SB.Stormelemental) < 2 * current_gcd
            or target.debuff(SB.Flameshock).remains <= current_gcd
            or talent(7, 3) and target.debuff(SB.Flameshock).remains < (-spell(SB.Ascendance) + 15) and -spell(SB.Ascendance) < 4
            and (not talent(4, 2) or talent(4, 2) and -spell(SB.Stormelemental) < 120))
            and player.buff(SB.Windgust) < 14 and player.buff(SB.Surgeofpower).down then
        return cast(SB.Flameshock, target)
    end

    --ascendance
    if talent(7, 3) and player.castable(SB.Ascendance) and (target.time_to_die > 20 or player.buff(SB.Bloodlust).up)
            and -spell(SB.Lavaburst) > 0 and (not talent(4, 2) or talent(4, 2) and -spell(SB.Stormelemental) > 120)
            and (talent(6, 3) or player.buff(SB.Icefury).down and -spell(SB.Icefury > 0)) then
        return cast(SB.Ascendance, player)
    end

end

