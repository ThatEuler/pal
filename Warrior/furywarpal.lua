-- Fury Warrior for 8.1 by Rex
-- version 1.3 - 26th Jan 2019
-- Holding Shift = Heroic Leap to cursor

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warrior
local lftime = 0

-- To Do

-- Spells

SB.FuriousSlash = 100130
SB.Rampage = 184367
SB.Enrage = 184361
SB.Recklessness = 1719
SB.Siegebreaker = 280772
SB.Execute = 5308
SB.Bloodthirst = 23881
SB.RagingBlow = 85288
SB.DragonRoar = 118000
SB.Bladestorm = 46924
SB.Whirlwind = 190411
SB.Massacre = 206315
SB.SuddenDeath = 280721
SB.Charge = 100
SB.RecklessAbandon = 202751
SB.AngerManagement = 152278
SB.PulverizingBlows = 275632
SB.SimmeringRage = 278757
SB.RecklessFlurry = 278758
SB.UnbridledFerocity = 288056
SB.WarMachine = 262231
SB.EndlessRage = 202296
SB.Carnage = 202922
SB.HeroicLeap = 6544
SB.DoubleTime = 103827
SB.BoundingStride = 202163
SB.EnragedRegeneration = 184364
SB.VictoryRush = 34428
SB.RallyingCry = 97462
SB.BattleShout = 6673
SB.Pummel = 6552
SB.StormBolt = 107570
SB.ImpendingVictory = 202168
SB.VictoryRushBuff = 32216
SB.AncestralCall = 274738
SB.Berserking = 26297
SB.BloodFury = 33697
SB.GiftoftheNaaru = 121093
SB.LightsJudgement = 255647


local function combat()
if target.alive and target.enemy and player.alive and not player.channeling() then

    -- Reading from settings
    local intpercentlow = dark_addon.settings.fetch('furywar_settings_intpercentlow',50)
    local intpercenthigh = dark_addon.settings.fetch('furywar_settings_intpercenthigh',65)
    local ERHealth = dark_addon.settings.fetch('furywar_settings_ERHealth',60)
    local VRHealth = dark_addon.settings.fetch('furywar_settings_VRHealth',80)
    local GiftHealth = dark_addon.settings.fetch('armswar_settings_GiftHealth',20)
    local Hstonecheck = dark_addon.settings.fetch('furywar_settings_healthstone.check',true)
    local Hstonepercent = dark_addon.settings.fetch('furywar_settings_healthstone.spin',20)
    local race = UnitRace('player')

    -- Targets in range check
    local enemyCount = enemies.around(8)
    dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

  -- Use Racials
    if toggle('useracials', false) then
      if race == "Orc" and castable(SB.BloodFury) then
        return cast(SB.BloodFury)
      end
      if race == "Troll" and castabe(SB.Berserking) then
        return cast(SB.Berserking)
      end
      if race == "Mag'har Orc" and castable(SB.AncestralCall) then
        return cast(SB.AncestralCall)
      end
      if race == "LightforgedDraenei" and castable(SB.LightsJudgement) then
        return cast(SB.LightsJudgement)
      end
      if race == "Draenei" and -player.health <= GiftHealth then
        return cast(SB.GiftoftheNaaru)
      end
    end

    -- Auto Attack
     if target.enemy and target.alive and target.distance < 8 then
         auto_attack()
     end

    -- Heroic Leap IC
    if modifier.shift and castable(SB.HeroicLeap) then
        return cast(SB.HeroicLeap, 'ground')
    end

    -- Charge
    if castable(SB.Charge) and target.distance > 8 and target.distance < 25 then
        return cast(SB.Charge)
    end

    -- Interrupts
        -- Define random number for interrupt
        local intpercent = math.random(intpercentlow,intpercenthigh)

        -- Pummel
        if toggle('interrupts', false) and castable(SB.Pummel, 'target') and -spell(SB.Pummel) == 0 and target.interrupt(intpercent, false) and target.distance < 8 then
          print('Interrupt @ ' .. intpercent)
          return cast(SB.Pummel, 'target')
        end

    -- Cooldowns
    if toggle('cooldowns', false) then
        -- Recklessness on cooldown or for burst DPS
        if castable(SB.Recklessness) and -spell(SB.Recklessness) == 0 then
            return cast(SB.Recklessness)
        end
    end

    --Defensive and Utility Abilities
    -- Enraged Regeneration is Fury's only personal cooldown, good for mitigating damage and healing it back up with Bloodthirst. Note that the buff is not consumed by Bloodthirst, meaning it can be used multiple times during the 8-second duration for increased healing.
    if castable(SB.EnragedRegeneration) and -spell(SB.EnragedRegeneration) == 0 and -player.health <= ERHealth then
        print('EnragedRegeneration @ ' .. ERHealth)
  		return cast(SB.EnragedRegeneration)
  	end

    -- Rallying Cry is one of the few group/raid wide cooldowns, good for both mitigating large attacks and granting a buffer when players are already close to death. Use primarily when large, group-wide damage is incoming.
    -- Piercing Howl is Fury's snare; good for kiting targets and proccing  Furious Charge heals.
    -- Intimidating Shout is also good for kiting, but keep in mind that feared targets can aggro other hostile enemies.
    -- Taunt is a generic taunt, though due to Fury's lack of Die by the Sword, it's not recommended to use unless in an effort to save the group from a wipe.


    -- Healing
    if castable(SB.VictoryRush) and -buff(SB.VictoryRushBuff) and -player.health <= VRHealth  then
        print('Heal @ ' .. -player.health)
        return cast(SB.VictoryRush)
    end

    if castable(SB.ImpendingVictory) and -player.health <= VRHealth and talent(2,2) then
        print('Heal @ ' .. -player.health)
        return cast(SB.ImpendingVictory)
    end

    -- Healthstone
    if Hstonecheck == true and -player.health < Hstonepercent and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
        macro('/use Healthstone')
    end

    --Multi-target
    --Whirlwind allows Fury to cleave its normal single target rotation on up to 4 additional targets, although some setup is done to ensure larger Bladestorm burst on intermittent waves of adds.

    --For general multitarget cleave
    if enemyCount >= 2 or toggle('multitarget', false) then
        -- Whirlwind to apply  Whirlwind whenever the buff is not up
        if castable(SB.Whirlwind) and -spell(SB.Whirlwind) == 0 and player.buff(SB.Whirlwind).down then
            return cast(SB.Whirlwind)
        end
    --Continue the single target rotation, and Whirlwind should be kept up naturally
    --An example sequence might look like this:  Whirlwind -  Rampage -  Raging Blow -  Whirlwind -   Bloodthirst -  Raging Blow -  Whirlwind -  Bloodthirst -  Rampage -  Whirlwind...

    end

    -- Single Target
    if enemyCount >= 1 then
    -- Top talents: Endless Rage, Furious Slash, Carnage, Dragon Roar, Siegebreaker
        -- Furious Slash until 3 stacks, or to keep the buff from falling
        if castable(SB.FuriousSlash) and -spell(SB.FuriousSlash) == 0 and player.buff(SB.FuriousSlash).count < 3 and talent(3,3) then
            return cast(SB.FuriousSlash)
        end

        -- Rampage when not Enraged or above 90 rage
        if castable(SB.Rampage) and -spell(SB.Rampage) == 0 and -power.rage > 90 then
            return cast(SB.Rampage)
        end

        -- Siegebreaker during Recklessness, or between its cooldown (you should get two casts between each Recklessness)
        if castable(SB.Siegebreaker) and -spell(SB.Siegebreaker) == 0 and talent(7,3) then
            return cast(SB.Siegebreaker)
        end

        -- Execute while Enraged
        if castable(SB.Execute) and -spell(SB.Execute) == 0 and player.buff(SB.Enrage).up then
            return cast(SB.Execute)
        end

        -- Raging Blow at 2 charges and Enraged
        if castable(SB.RagingBlow) and -spell(SB.RagingBlow) == 0 and spell(SB.RagingBlow).charges == 2 and player.buff(SB.Enrage).up then
            return cast(SB.RagingBlow)
        end

        -- Bloodthirst
        if castable(SB.Bloodthirst) and -spell(SB.Bloodthirst) == 0 then
            return cast(SB.Bloodthirst)
        end

        -- Dragon Roar while Enraged
        if castable(SB.DragonRoar) and -spell(SB.DragonRoar) == 0 and player.buff(SB.Enrage).up and talent(6,2) then
            return cast(SB.DragonRoar)
        end

        -- Bladestorm while Enraged
        if castable(SB.Bladestorm) and -spell(SB.Bladestorm) == 0 and player.buff(SB.Enrage).up and talent(6,3) then
            return cast(SB.Bladestorm)
        end

        -- Raging Blow
        if castable(SB.RagingBlow) and -spell(SB.RagingBlow) == 0 then
            return cast(SB.RagingBlow)
        end

        -- Furious Slash if talented
        if castable(SB.FuriousSlash) and -spell(SB.FuriousSlash) == 0 and talent(3,3) then
            return cast(SB.FuriousSlash)
        end

        -- Storm Bolt if talented
        if castable(SB.StormBolt) and -spell(SB.StormBolt) == 0 and talent(2,3) then
            return cast(SB.StormBolt)
        end

        -- Whirlwind
        if castable(SB.Whirlwind) and -spell(SB.Whirlwind) == 0 then
            return cast(SB.Whirlwind)
        end

        --An example sequence with talents might look like this:  Siegebreaker -  Rampage -  Raging Blow -  Bloodthirst -  Dragon Roar -  Furious Slash -  Bloodthirst -  Rampage -  Raging Blow...
        --An example sequence without talents might look like this:  Rampage -  Raging Blow - Bloodthirst -  Raging Blow -  Whirlwind -  Bloodthirst -  Rampage -  Whirlwind...

    end

end
end

local function resting()
  local lfg = GetLFGProposal();
  local hasData = GetLFGQueueStats(LE_LFG_CATEGORY_LFD);
  local hasData2 = GetLFGQueueStats(LE_LFG_CATEGORY_LFR);
  local hasData3 = GetLFGQueueStats(LE_LFG_CATEGORY_RF);
  local hasData4 = GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO);
  local hasData5 = GetLFGQueueStats(LE_LFG_CATEGORY_FLEXRAID);
  local hasData6 = GetLFGQueueStats(LE_LFG_CATEGORY_WORLDPVP);
  local bgstatus = GetBattlefieldStatus(1);
  local autojoin = dark_addon.settings.fetch('furywar_settings_autojoin', true)

  -------------
  --Auto Join--
  -------------
  if autojoin == true and hasData == true or hasData2 == true or hasData4 == true or hasData5 == true or hasData6 == true or bgstatus == "queued" then
      SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)
  elseif autojoin == false and hasdata == nil or hasData2 == nil or hasData3 == nil or hasData4 == nil or hasData5 == nil or hasData6 == nil or bgstatus == "none" then
      SetCVar("Sound_EnableSoundWhenGameIsInBG", 0)
  end

  if autojoin == true and lfg == true or bgstatus == "confirm" then
      PlaySound(SOUNDKIT.IG_PLAYER_INVITE, "Dialog");
      lftime = lftime + 1
  end

  if lftime >= math.random(20, 35) then
      SetCVar("Sound_EnableSoundWhenGameIsInBG", 0)
      macro('/click LFGDungeonReadyDialogEnterDungeonButton')
      lftime = 0
  end




  local enemyCount = enemies.around(8)
  dark_addon.interface.status_extra('T#:' .. enemyCount .. ' D:' .. target.distance)

  -- Infernal Strike OOC
  if modifier.shift and castable(SB.HeroicLeap) then
      return cast(SB.HeroicLeap, 'ground')
  end

end

local function interface()

    local settings = {
        key = 'furywar_settings',
        title = 'Fury Warrior',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = "            Rex's Fury Warrior Settings" },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine' },
            { type = 'text', text = 'Suggested Talents - 1 3 1 1 2 1 1' },
            { type = 'text', text = 'If you want automatic AOE then please remember to turn on EnemyNamePlates in WoW (V key)' },
            { type = 'text', text = 'Shift Modifier used for Heroic Leap' },
            { type = 'rule' },
            { type = 'text', text = 'Interrupt Settings' },
            { key = 'intpercentlow', type = 'spinner', text = 'Interrupt Low %', default = '50', desc = 'low% cast time to interrupt at', min = 5, max = 50, step = 1 },
            { key = 'intpercenthigh', type = 'spinner', text = 'Interrupt High %', default = '65', desc = 'high% cast time to interrupt at', min = 51, max = 100, step = 1 },
            { type = 'text', text = 'Defensive Settings' },
            { key = 'ERHealth', type = 'spinner', text = 'Enraged Regeneration at Health %', default = '60', desc = 'cast Enraged Regeneration at', min = 0, max = 100, step = 1 },
            { key = 'VRHealth', type = 'spinner', text = 'Victory Rush/Imp Victory at Health %', default = '80', desc = 'cast Victory Rush/Imp Victory at', min = 0, max = 100, step = 1 },
            { key = 'healthstone', type = 'checkspin', default = '20', text = 'Healthstone', desc = 'use Healthstone at health %', min = 1, max = 100, step = 1 },
            { key = 'GiftHealth', type = 'spinner', text = 'Gift of the Naaru at Health %', default = '20', desc = 'cast Gift of the Naaru at', min = 0, max = 100, step = 1 },
            { key = 'autojoin', type = 'checkbox', text = 'Auto Join', desc = 'Automatically accept Dungeon/Battleground Invites', default = true },

        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'settings',
        label = 'Rotation Settings',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.warrior_brown,
            color2 = dark_addon.interface.color.warrior_brown
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
    dark_addon.interface.buttons.add_toggle({
        name = 'useracials',
        label = 'Use Racials',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('toggle-on'),
            color = dark_addon.interface.color.warrior_brown,
            color2 = dark_addon.interface.color.warrior_brown
        },
        off = {
            label = dark_addon.interface.icon('toggle-off'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })

end

-- This is what actually tells DR about your custom rotation
dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.warrior.fury,
    name = 'furywarpal',
    label = 'Pal Project: Fury Warrior',
    combat = combat,
    resting = resting,
    interface = interface
})
