--magna totem should be a modifier




local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.shaman
local race = UnitRace("player")
local x = 0
local az_nh

--Spells not in spellbook
SB.Berserking = 26297
SB.StormKeeper = 191634
SB.Stormelemental = 192249

local function combat()
    local current_gcd = (1.5 / ((UnitSpellHaste("player") / 100) + 1))

    if toggle('multitarget', false) then
        enemyCount = enemies.around(40)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end

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
        if toggle('interrupts', false) and target.interrupt(50) and target.distance <= 30 and castable(SB.WindShear) then
            return cast(SB.WindShear, 'target')
        end
    end

    if talent(2, 3) and player.buff(SB.StormTotem).down then
        return cast(SB.TotemMastery)
    end

    --single target rotation
    if enemyCount >= 2 then

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
        --elemental blast
        if talent(1, 3) then
            if (talent(4, 1) and player.buff(SB.MasteroftheElemental).up and -power.maelstrom < 60
                    or not talent(4, 1)) and (not (-spell(SB.Stormelemental) > 120 and talent(4, 2))
                    or az_nh and player.buff(SB.AzeriteNaturalHarmony).count == 3 and player.buff(SB.Windgust) < 14) then
                return cast(SB.ElementalBlast, target)
            end
        end

        --stormkeepoer
        if talent(7, 2) and player.castable(SB.StormKeeper) then
            if (not talent(6, 1) or player.buff(SB.Surgeofpower).up or -power.maelstrom >= 44) then
                return cast(SB.StormKeeper)
            end
        end
        --lightning bolt
        if target.castable(SB.Lightningbolt) then
            if player.buff(SB.StormKeeper).up and (player.buff(SB.MasteroftheElements).up and not talent(6, 1) or player.buff(SB.Surgeofpower).up) then
                return cast(SB.Lightningbolt, target)
            end
        end
        --earth shock 1

        if target.castable(SB.Earthshock) then
            if not player.buff(SB.Surgeofpower).up and talent(4, 1)
                    and (player.buff(SB.MasteroftheElements).up or -power.maelstrom >= 92 + 30 * talent(2, 2)
                    --or buff.stormkeeper.up & active_enemies < 2)
                    or not talent(4, 1)
                    and (player.buff(SB.StormKeeper).up
                    or -power.maelstrom >= 90 + 30 * talent(2, 2)
                    or not (-spell(SB.Stormelemental) > 120 and talent(4, 2))
                    and target.time_to_die - -spell(SB.Stormelemental) - 150 * math.floor((target.time_to_die - -spell(SB.Stormelemental)) % 150) >= 30 * (1 + (player.buff(SB.AzeriteEchooftheElementals).count >= 2)))) then
                return cast(SB.Earthshock, target)
            elseif talent(4, 1) and player.buff(SB.Surgeofpower).down
                    and -spell(SB.Lavaburst) <= current_gcd and (not talent(4, 2) and not (-spell(SB.Fireelemental) > 120
                    or talent(4, 2) and not -spell(SB.Stormelemental) > 120)) then
                return cast(SB.Earthshock, target)
            end
        end
        --lightningbolt - round2
        if target.castable(SB.Lightningbolt) and -spell(SB.Stormelemental) > 120 and talent(4, 2) then
            return cast(SB.Lightningbolt, target)
        end
        --frost shock
        if talent(6, 3) and talent(4, 1) and player.buff(SB.Icefury).up and player.buff(SB.MasteroftheElements).up then
            return cast(SB.Frostshock, target)
        end
        --lavaburst
        if player.buff(SB.Ascendance).up and target.castable(SB.Lavaburst) then
            return cast(SB.Lavaburst, target)
        end
        --re-dot
        if target.castable(SB.Flameshock) and enemyCount > 1 and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) and player.buff(SB.Surgeofpower).up then
            return cast(SB.Flameshock, target)
        elseif target.castable(SB.Flameshock) and enemyCount == 1 and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) and player.buff(SB.Surgeofpower).down then
            return cast(SB.Flameshock, target)
        end

        --lava burst
        if target.castable(SB.Lavaburst) and player.buff(SB.Surgeofpower).up then
            return cast(SB.Lavaburst, target)
        end

        --lightningbolt - round3
        if target.castable(SB.Lightningbolt) and player.buff(SB.Surgeofpower).up then
            return cast(SB.Lightningbolt, target)
        end
        --frost shock
        if target.castable(SB.Frostshock) and talent(6, 2) and player.buff(SB.Icefury).up
                and (player.buff(SB.Icefury). remains < current_gcd * 4 * player.buff(SB.Icefury).count
                or player.buff(StormKeeper).up or not talent(4, 1)) then
            return cast(SB.Frostshock, target)
        end
        if talent(6, 2) and target.castable(SB.Icefury) then
            return cast(SB.Icefury, target)
        end
        --lightningbolt - round4
        if target.castable(SB.Lightningbolt) then
            return cast(SB.Lightningbolt, target)
        end

        if target.castable(SB.Frostshock) then
            return cast(SB.Frostshock, target)
        end
    end
end


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