---  Protection Warrior for 8.1 by Laksmackt and Rebecca  - 01/2019
--- Holding Shift = mobility - will leap if it can, will intercept if possible
---CTRL = stun - hammer or shockwave
--- Supported talents: all


local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warrior
local PB = dark_addon.rotation.spellbooks.purgeables
local race = UnitRace("player")
local badguy = UnitClassification("target")
local enemyCount = 0
local lftime = 0

--missing spells
SB.RevengeProc = 5302
SB.DeafeningCrash = 272824
SB.ShieldBlockBuff = 132404
SB.VictoryRushBuff = 32216
SB.BattleShout = 6673
--racials
SB.GiftOftheNaaru = 59544
SB.MendingBuff = 41635
SB.AncestralCall = 274738
SB.LightsJudgement = 255647

local function combat()
    -------------------------
    -------Modifiers---------
    -------------------------
    if modifier.alt and castable(SB.HeroicThrow) and mouseover.enemy and mouseover.alive then
        return cast(SB.HeroicThrow, 'mouseover')
    end

    if modifier.shift then
        if castable(SB.HeroicLeap) then
            return cast(SB.HeroicLeap, 'ground')
        elseif -spell(SB.Intercept) == 0 and target.enemy and target.distance <= 25 then
            return cast(SB.Intercept, 'mouseover')
        end
    end

    if toggle('multitarget', false) then
        enemyCount = enemies.around(8)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end

    -----------------------------
    --- Reading from settings
    -----------------------------


    local shoutInt = dark_addon.settings.fetch('protwarrior_settings_shoutInt', true)
    local shockwaveInt = dark_addon.settings.fetch('protwarrior_settings_shockwaveInt', true)
    local stormboltInt = dark_addon.settings.fetch('protwarrior_settings_stormboltInt', true)
    local healthPop = dark_addon.settings.fetch('protwarrior_settings_healthPop.check', true)
    local healthPoppercent = dark_addon.settings.fetch('protwarrior_settings_healthPop.spin', 35)
    local useTrinkets = dark_addon.settings.fetch('protwarrior_settings_useTrinkets', true)
    local deafeningCrash = dark_addon.settings.fetch('protwarrior_settings_deafeningCrash', false)


    --Defensives
    local shieldblock = dark_addon.settings.fetch('protwarrior_defensives_shieldblock.check', true)
    local shieldblockpercent = dark_addon.settings.fetch('protwarrior_defensives_shieldblock.spin', 90)
    local demoshout = dark_addon.settings.fetch('protwarrior_defensives_demoshout.check', true)
    local demoshoutpercent = dark_addon.settings.fetch('protwarrior_defensives_demoshout.spin', 75)
    local ignorepain = dark_addon.settings.fetch('protwarrior_defensives_ignorepain.check', true)
    local ignorepainpercent = dark_addon.settings.fetch('protwarrior_defensives_ignorepain.spin', 85)
    local laststand = dark_addon.settings.fetch('protwarrior_defensives_laststand.check', true)
    local laststandpercent = dark_addon.settings.fetch('protwarrior_defensives_laststand.spin', 50)
    local shieldwall = dark_addon.settings.fetch('protwarrior_defensives_shieldwall.check', true)
    local shieldwallpercent = dark_addon.settings.fetch('protwarrior_defensives_shieldwall.spin', 35)





    if not target.alive or not target.enemy then
        return
    end

    if target.enemy and target.distance <= 8 then
        auto_attack()
    end
    -------------------------
    --- INTERRUPT OPTIONS ---
    -------------------------

    if toggle('interrupts', false) and target.interrupt(math.random(25, 75)) and target.distance < 8 then
        if target.castable(SB.Pummel) then
            return cast(SB.Pummel, 'target')
        elseif shoutInt and castable(SB.IntimidatingShout) then
            return cast(SB.IntimidatingShout)
        elseif shockwaveInt and UnitLevel("player") >= 50 and castable(SB.Shockwave) then
            return cast(SB.Shockwave)
        elseif stormboltInt and target.castable(SB.StormBolt) then
            return cast(SB.StormBolt, target)
        end
    end

    --spellreflection
    if castable(SB.SpellReflect) and target.interrupt(100, false) then
        return cast(SB.SpellReflect)
    end

    --regain control
    if not HasFullControl() and castable(SB.BerserkerRage) then
        print("Berserk!")
        return cast(SB.BerserkerRage)
    end

    -------------------------
    --- Trinkets /Healthstones
    -------------------------
    local Trinket13 = GetInventoryItemID("player", 13)
    local Trinket14 = GetInventoryItemID("player", 14)

    if useTrinkets then
        --doomsfury trinket
        if Trinket13 == 161463 and player.buff(SB.Avatar).up and GetItemCooldown(161463) == 0 then
            macro('/use 13')
        end
        if Trinket14 == 161463 and player.buff(SB.Avatar).up and GetItemCooldown(161463) == 0 then
            macro('/use 14')
        end
        --Jes Howler (159622)
        if Trinket13 == 159622 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use 13')
        end
        if Trinket14 == 159622 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use 14')
        end
        --Razdunk big red button  (159611)
        if Trinket13 == 159611 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159611) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use [@player] 13 ')
        end
        if Trinket14 == 159611 and target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159611) == 0 and -spell(SB.Avatar) > 10 and player.buff(SB.Avatar).down then
            macro('/use [@player] 14 ')
        end
        --touch of the void
        if Trinket13 == 128318 and (target.time_to_die > 10 or enemyCount >= 3) and GetItemCooldown(128318) == 0 then
            macro('/use 13')
        end
        if Trinket14 == 128318 and (target.time_to_die > 10 or enemyCount >= 3) and GetItemCooldown(128318) == 0 then
            macro('/use 14')
        end
    end


    --Health stone
    if healthPop == true and player.health.percent < healthPoppercent and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
        macro('/use Healthstone')
    end
    --health pot
    if usehealpot == true and GetItemCount(152494) >= 1 and player.health.percent < healthPoppercent and GetItemCooldown(5512) > 0 then
        macro('/use Coastal Healing Potion')
    end

    --done with equipment stuff
    -------------------------
    --- Cool Downs
    -------------------------
    --avatar - on CD, but dont pop if mobs almost ead or trash - cant wait up to 4 seconds to get shield slam in
    -- and badguy ~= "normal" and badguy ~= "minus"
    if toggle('cooldowns', false) and target.time_to_die > 8 then
        if castable(SB.Avatar) and (-spell(SB.ShieldSlam) == 0 or -spell(SB.ShieldSlam) > 4) then
            return cast(SB.Avatar)
        end
        --Intercept/charge  (always keep one charge for movement) ..might need to rethink this ..not sure ...might get us in trouble ;)
        if IsInRaid() == false and target.castable(SB.Intercept) and player.spell(SB.Intercept).count > 1 then
            return cast(SB.Intercept, target)
        end
        if talent(6, 1) and castable(SB.DemoralizingShout) and (-spell(SB.ShieldSlam) == 0 or -spell(SB.ShieldSlam) > 4) then
            return cast(SB.DemoralizingShout)
        end
    end

    -------------------------
    -------Auto racial-------
    -------------------------
    if autoRacial == true and target.distance <= 8 and target.time_to_die > 6 then
        if race == "Blood Elf" - spell(SB.ArcaneTorrent) == 0 then
            for i = 1, 40 do
                local name, _, _, count, debuff_type, _, _, _, _, spell_id = UnitAura("target", i)
                if spell_id == nil then
                    break
                end
                if name and PB[spell_id] then
                    print("Purging " .. name .. " off the target.")
                    return cast(SB.ArcaneTorrent)
                end
            end
        end
        elseif race == "Orc" and -spell(SB.BloodFury) == 0 then
            cast(SB.BloodFury)
        elseif race == "Troll" and -spell(SB.Berserking) == 0 then
            cast(SB.Berserking)
        elseif race == "Mag'har Orc" and -spell(SB.AncestralCall) == 0 then
            cast(SB.AncestralCall)
        elseif race == "LightforgedDraenei" and -spell(SB.LightsJudgement) == 0 then
            cast(SB.LightsJudgement)
    end

    -------------------------
    -------Auto Taunt--------
    -------------------------
    --[[
        if autoTaunt and -spell(SB.Taunt) == 0 and UnitAffectingCombat("target") and not (UnitIsUnit("targettarget", "player")) then
            return cast(SB.Taunt)
        end
    ]]
    local taunttarget
    if toggle('autoTaunt', false) and -spell(SB.Taunt) == 0 then
        if IsSpellInRange('Taunt', 'target') and UnitAffectingCombat('target') and (isTanking == 0 or isTanking == nil) then
            return cast(SB.Taunt, target)
        end
        for i = 1, 40 do
            local isTanking = UnitThreatSituation("player", "mouseover")
            if UnitExists('mouseover') and IsSpellInRange('Taunt', 'mouseover') and UnitAffectingCombat('mouseover') and (isTanking == 0 or isTanking == nil) then
                return cast(SB.Taunt, mouseover)
            end
        end
    end


    -------------------------
    --- Damage mitigation
    -------------------------

    if -spell(SB.ShieldBlock) == 0 and -power.rage >= 30 and target.time_to_die > 6
            and ((player.buff(SB.IgnorePain).down and player.health.percent < 90)
            or (player.buff(SB.IgnorePain).up and player.health.percent < 60))
            and not talent(4, 3) and player.buff(SB.LastStand).up then
    if shieldblock == true and -spell(SB.ShieldBlock) == 0 and -power.rage >= 30 and target.time_to_die > 6 and player.health.percent < shieldblockpercent and not (talent(4, 3) and player.buff(SB.LastStand).up) then
        return cast(SB.ShieldBlock)
    elseif (player.buff(SB.ShieldBlockBuff).down or player.health.percent < 40) and target.time_to_die > 6 then
        if UnitLevel("player") >= 48 and -spell(SB.DemoralizingShout) == 0 and demoshout == true and (enemyCount >= 3 or player.health.percent < demoshoutpercent or deafeningCrash) then
            return cast(SB.DemoralizingShout)
        elseif UnitLevel("player") >= 36 and -spell(SB.IgnorePain) == 0 and -power.rage >= 40
                and (player.buff(SB.IgnorePain).down and player.health.percent < 85
        or player.buff(SB.IgnorePain).up and player.health.percent < 45) then
        elseif UnitLevel("player") >= 36 and ignorepain == true and -spell(SB.IgnorePain) == 0 and -power.rage >= 40 and player.buff(SB.IgnorePain).down and player.health.percent < ignorepainpercent then
            return cast(SB.IgnorePain)
        elseif UnitLevel("player") >= 32 and laststand == true and -spell(SB.LastStand) == 0 and player.health.percent < laststandpercent then
            return cast(SB.LastStand)
        elseif UnitLevel("player") >= 55 and shieldwall == true and -spell(SB.ShieldWall) == 0 and player.health.percent < shieldwallpercent then
            return cast(SB.ShieldWall)
        end
    end

    -------------------------
    --- Standard Rotation stuff
    -------------------------

    if not isCC("target") and UnitAffectingCombat("target") then
        if player.buff(SB.VictoryRushBuff).up and -spell(SB.VictoryRush) == 0 and target.castable(SB.VictoryRush) and player.health.percent < 99 then
            return cast(SB.VictoryRush, target)
        elseif target.castable(SB.HeroicThrow) and -spell(SB.HeroicThrow) == 0 and target.enemy and (target.distance > 8 and target.distance <= 30) then
            return cast(SB.HeroicThrow, target)
        elseif target.castable(SB.StormBolt) then
            return cast(SB.StormBolt, target)
        end
    end
    -------------------------
    --- single Target Standard Rotation
    -------------------------
    if enemyCount == 1 and target.enemy and target.distance <= 8 and not isCC("target") and UnitAffectingCombat("target") then
        if target.castable(SB.ShieldSlam) and -spell(SB.ShieldSlam) == 0 then
            return cast(SB.ShieldSlam, target)
        elseif castable(SB.Revenge) and -spell(SB.Revenge) == 0 and (player.buff(SB.RevengeProc).up or UnitLevel("player") < 36 or (-power.rage > 80 and -spell(SB.ShieldBlock) == 0)) then
            return cast(SB.Revenge)
        elseif castable(SB.ThunderClap) and target.distance <= 6 and -spell(SB.ThunderClap) == 0 then
            return cast(SB.ThunderClap)
        elseif target.castable(SB.Devastate) and -spell(SB.Devastate) == 0 then
            return cast(SB.Devastate, target)
        end
    end

    -------------------------
    --- multi Target Standard Rotation
    -------------------------
    if enemyCount >= 2 and target.enemy and target.distance <= 8 and not isCC("target") and UnitAffectingCombat("target") then
        if enemyCount >= 3 and UnitLevel("player") >= 50 and -spell(SB.Shockwave) == 0 then
            return cast(SB.Shockwave)
        elseif castable(SB.ThunderClap) and -spell(SB.ThunderClap) == 0 then
            return cast(SB.ThunderClap)
        elseif target.castable(SB.ShieldSlam) and -spell(SB.ShieldSlam) == 0 then
            return cast(SB.ShieldSlam, target)
        elseif (player.health.percent >= 65 or player.buff(SB.RevengeProc).up or UnitLevel("player") < 36 or (-power.rage > 80 and -spell(SB.ShieldBlock) == 0)) and -spell(SB.Revenge) == 0 then
            return cast(SB.Revenge)
        elseif target.castable(SB.Devastate) and -spell(SB.Devastate) == 0 then
            return cast(SB.Devastate, target)
        end
    end


end

local function resting()
    -----------------------------
    --- Reading from settings
    -----------------------------

    local lfg = GetLFGProposal();
    local hasData = GetLFGQueueStats(LE_LFG_CATEGORY_LFD);
    local hasData2 = GetLFGQueueStats(LE_LFG_CATEGORY_LFR);
    local hasData3 = GetLFGQueueStats(LE_LFG_CATEGORY_RF);
    local hasData4 = GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO);
    local hasData5 = GetLFGQueueStats(LE_LFG_CATEGORY_FLEXRAID);
    local hasData6 = GetLFGQueueStats(LE_LFG_CATEGORY_WORLDPVP);
    local bgstatus = GetBattlefieldStatus(1);
    local autojoin = dark_addon.settings.fetch('protwarrior_settings_autojoin', true)


    -------------------------
    -------Modifiers---------
    -------------------------

    if modifier.alt and castable(SB.HeroicThrow) and mouseover.enemy and mouseover.alive then
        return cast(SB.HeroicThrow, 'mouseover')
    end

    if modifier.shift then
        if castable(SB.HeroicLeap) then
            return cast(SB.HeroicLeap, 'ground')
        elseif -spell(SB.Intercept) == 0 and mouseover.distance <= 25 then
            return cast(SB.Intercept, 'mouseover')
        end
    end

    if modifier.control and -spell(SB.Shockwave) == 0 then
        return cast(SB.Shockwave)
    elseif talent()
        return cast(SB.HeroicThrow, 'mouseover')
    end

    -------------
    --Auto Join--
    -------------
    if autojoin == true and hasData == true or hasData2 == true or hasData4 == true or hasData5 == true or hasData6 == true or bgstatus == "queued" then
     SetCVar ("Sound_EnableSoundWhenGameIsInBG",1)
    elseif autojoin == false and hasdata == nil or hasData2 == nil or hasData3 == nil or hasData4 == nil or hasData5 == nil or hasData6 == nil or bgstatus == "none" then
        SetCVar ("Sound_EnableSoundWhenGameIsInBG",0)
    end

    if autojoin ==true and lfg == true or bgstatus == "confirm" then
        PlaySound(SOUNDKIT.IG_PLAYER_INVITE, "Dialog");
        lftime = lftime + 1
    end

    if lftime >=math.random(20,35) then
        SetCVar ("Sound_EnableSoundWhenGameIsInBG",0)
        macro('/click LFGDungeonReadyDialogEnterDungeonButton')
        lftime = 0
    end

    -------------
    ----Buff-----
    ------------
    local allies_without_my_buff = group.count(function(unit)
        return unit.alive and unit.distance < 40 and unit.buff(SB.BattleShout).down
    end)
    if allies_without_my_buff >= 1 and castable(SB.BattleShout) then
        return cast(SB.BattleShout)
    end


end
local function interface()
    local settings = {
        key = 'protwarrior_settings',
        title = 'Protection Warrior - the REAL tank!',
        width = 250,
        height = 420,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = 'Protection Warrior - the REAL tank!', align= 'center' },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine.' },
            { type = 'rule' },
            { type = 'header', text = 'Interrupts', align = 'center' },
            { key = 'intpercent', type = 'spinner', text = 'Interrupt %', desc = '% cast time to interrupt at', default = 50, min = 5, max = 100, step = 5 },
            { key = 'shoutInt', type = 'checkbox', text = 'Use shout as an interrupt', desc = '', default = true },
            { key = 'shockwaveInt', type = 'checkbox', text = 'Use shockwave as an interrupt', desc = '', default = true },
            { key = 'stormboltInt', type = 'checkbox', text = 'Use Storm Bolt as an interrupt', desc = '', default = true },
            { type = 'rule' },
             { type = 'header', text = 'General Settings', align = 'center' },
            { key = 'autoTaunt', type = 'checkbox', text = 'Auto Taunt', desc = '', default = true },
            { key = 'useTrinkets', type = 'checkbox', text = 'Auto Trinket', desc = '', default = true },
            { key = 'healthPop', type = 'checkspin', text = 'HealthsStone', desc = 'Auto use Healthstone/Healpot at health %', default_check = true, default_spin = 35, min = 5, max = 100, step = 5 },
            { key = 'autoRacial', type = 'checkbox', text = 'Racial', desc = 'Use Racial', default = true },
            { key = 'autojoin', type = 'checkbox', text = 'Auto Join', desc = 'Automatically accept Dungeon/Battleground Invites', default = true },
            { type = 'rule' },
            { type = 'text', text = 'Traits that impact rotation - enable if you got them' },
            { key = 'deafeningCrash', type = 'checkbox', text = 'Deafening Crash', desc = '', default = true },
        }
    }
    configWindowtwo = dark_addon.interface.builder.buildGUI(settings)

local utility = {
        key = 'protwarrior_defensives',
        title = 'Protection Warrior - the REAL tank!',
        width = 250,
        height = 390,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = 'Protection Warrior - the REAL tank!', align= 'center' },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine.' },
            { type = 'rule' },
            { type = 'header', text = 'Defensives', align= 'center' },
            { key = 'shieldblock', type = 'checkspin', text = 'Shieldblock', desc = 'Health % to Cast At', default_check = true, default_spin = 90, min = 5, max = 100, step = 5 },
            { key = 'demoshout', type = 'checkspin', text = 'Demoralizing Shout', desc = 'Health % to Cast At', default_check = true, default_spin = 75, min = 5, max = 100, step = 5 },
            { key = 'ignorepain', type = 'checkspin', text = 'Ignore Pain', desc = 'Health % to Cast At', default_check = true, default_spin = 85, min = 5, max = 100, step = 5 },
            { key = 'laststand', type = 'checkspin', text = 'Last Stand', desc = 'Health % to Cast At', default_check = true, default_spin = 50, min = 5, max = 100, step = 5 },
            { key = 'shieldwall', type = 'checkspin', text = 'Shield wall', desc = 'Health % to Cast At', default_check = true, default_spin = 35, min = 5, max = 100, step = 5 },


        }
    }




  configWindow = dark_addon.interface.builder.buildGUI(utility)



    dark_addon.interface.buttons.add_toggle({
        name = 'autoTaunt',
        label = 'Taunt',
        on = {
            label = 'Taunt On',
            color = dark_addon.interface.color.brown,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Taunt Off',
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
            color = dark_addon.interface.color.brown,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        },
        callback = function(self)
            if configWindowtwo.parent:IsShown() then
                configWindowtwo.parent:Hide()
            else
                configWindowtwo.parent:Show()
            end
        end
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'settingstwo',
        label = 'Defensive Settings',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('shield'),
            color = dark_addon.interface.color.brown,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = dark_addon.interface.icon('shield'),
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
    spec = dark_addon.rotation.classes.warrior.protection,
    name = 'protwarpal',
    label = 'Pal: Prot Warrior - BETA',
    combat = combat,
    resting = resting,
    interface = interface,
})
