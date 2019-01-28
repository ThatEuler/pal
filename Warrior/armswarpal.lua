-- Arms Warrior for 8.1 by Rex
-- version 1.2 - 22nd Jan 2019
-- Holding Shift = Heroic Leap to cursor

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.warrior
local lftime = 0

-- To do

-- Spells

SB.Massacre = 281001
SB.Execute = 163201
SB.Rend = 772
SB.ColossusSmash = 167105
SB.Skullsplitter = 260643
SB.Bladestorm = 227847
SB.Avatar = 107574
SB.Ravager = 152277
SB.Warbreaker = 262161
SB.DeadlyCalm = 262228
SB.SuddenDeath = 29725
SB.Overpower = 7384
SB.MortalStrike = 12294
SB.DeepWounds = 262304
SB.TestofMight = 275529
SB.Whirlwind = 1680
SB.Slam = 1464
SB.CrushingAssault = 278751
SB.Dreadnaught = 262150
SB.Charge = 100
SB.SweepingStrikes = 260708
SB.Cleave = 845
SB.Tactician = 184783
SB.SeismicWave = 277639
SB.StrikingtheAnvil = 288452
SB.WarMachine = 262231
SB.HeroicLeap = 6544
SB.DoubleTime = 103827
SB.BoundingStride = 202163
SB.DiebytheSword = 118038
SB.DefensiveStance = 197690
SB.RallyingCry = 97462
SB.BattleShout = 6673
SB.VictoryRush = 34428
SB.ImpendingVictory = 202168
SB.Pummel = 6552
SB.StormBolt = 107570
SB.AncestralCall = 274738
SB.Berserking = 26297
SB.BloodFury = 33697
SB.GiftoftheNaaru = 121093
SB.LightsJudgement = 255647

-- Define Counters
  local DefStance = 0

local function combat()
if target.alive and target.enemy and player.alive and not player.channeling() then

  -- Reading from settings
  local intpercentlow = dark_addon.settings.fetch('armswar_settings_intpercentlow',50)
  local intpercenthigh = dark_addon.settings.fetch('armswar_settings_intpercenthigh',65)
  local StormBoltInt = dark_addon.settings.fetch('armswar_settings_StormBoltInt',true)
  local DBTSHealth = dark_addon.settings.fetch('armswar_settings_DBTSHealth',60)
  local VRHealth = dark_addon.settings.fetch('armswar_settings_VRHealth',80)
  local GiftHealth = dark_addon.settings.fetch('armswar_settings_GiftHealth',20)
  local Hstonecheck = dark_addon.settings.fetch('armswar_settings_healthstone.check',true)
  local Hstonepercent = dark_addon.settings.fetch('armswar_settings_healthstone.spin',20)
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

  -- Interrupts
    -- Define random number for interrupt
    local intpercent = math.random(intpercentlow,intpercenthigh)

    -- Pummel
    if castable(SB.Pummel, 'target') and -spell(SB.Pummel) == 0 and target.interrupt(intpercent, false) then
      print('Pummel Interrupt @ ' .. intpercent)
      return cast(SB.Pummel, 'target')
    end

    -- Storm Bolt
    if castable(SB.StormBolt, 'target') and -spell(SB.StormBolt) == 0 and target.interrupt(intpercent, false) and StormBoltInt and target.distance < 20 and talent(2,3) then
      print('Storm Bolt Interrupt @ ' .. intpercent)
      return cast(SB.StormBolt, 'target')
    end

    -- Cooldowns
    if toggle('cooldowns', false) then
        -- Avatar on cooldown or for burst DPS
        if castable(SB.Avatar) and -spell(SB.Avatar) == 0 and -spell(SB.ColossusSmash) == 0 and talent(6,2) then
            return cast(SB.Avatar)
        end
    end

  -- Defensive Spells
      -- Defensive Stance
        if castable(SB.DefensiveStance) and talent(4,3) and toggle('defensivestance', false) and DefStance == 0 then
          print('Defensive Stance On')
            DefStance = 1
            return cast(SB.DefensiveStance)
        end

        if castable(SB.DefensiveStance) and talent(4,3) and not toggle('defensivestance', false) and DefStance == 1 then
          print('Defensive Stance Off')
            DefStance = 0
            return cast(SB.DefensiveStance)
        end

      -- Die by the Sword
        if castable(SB.DiebytheSword) and -buff(SB.DiebytheSword) and -player.health <= DBTSHealth then
          print('Heal @ ' .. -player.health)
            return cast(SB.DiebytheSword)
        end

  -- Healing
    if castable(SB.VictoryRush) and -buff(SB.Victorious) and -player.health <= VRHealth then
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


    if enemyCount == 1 then

      -- Single Target - non-Execute phase
      if -target.health >= 20 or (talent(3,1) and -target.health >= 35) then
          print'ST non Execute phase'

        -- Cast Rend if less than 4 seconds remains, outside of Colossus Smash
        if castable(SB.Rend, 'target') and target.debuff(SB.Rend).remains < 4 and not -target.debuff(SB.ColossusSmashDebuff) and -power.rage > 30 and talent(3,3) then
          return cast(SB.Rend)
        end

        -- Cast Skullsplitter when less than 60 Rage, when Bladestorm is not about to be used.
        if castable(SB.Skullsplitter, 'target') and -spell(SB.Skullsplitter) == 0 and -spell(SB.Bladestorm) > 12 and -power.rage < 60 and talent(1,3) then
          return cast(SB.Skullsplitter)
        end

--[[        -- Cast Avatar prior to Colossus Smash
        if castable(SB.Avatar, 'target') and -spell(SB.Avatar) == 0 and -spell(SB.ColossusSmash) == 0 and talent(6,2) then
          print'ST NE'
          return cast(SB.Avatar)
        end]]

        -- Cast Ravager immediately prior to Colossus Smash
        if castable(SB.Ravager, 'target') and -spell(SB.Ravager) == 0 and -spell(SB.ColossusSmash) == 0 and talent(7,3) then
          return cast(SB.Ravager, 'player')
        end

        -- Cast Colossus Smash
        if castable(SB.ColossusSmash, 'target') and -spell(SB.ColossusSmash) == 0 then
          return cast(SB.ColossusSmash)
        end

        -- Cast Warbreaker
        if castable(SB.Warbreaker, 'target') and -spell(SB.Warbreaker) == 0 and talent(5,2) then
          return cast(SB.Warbreaker)
        end

        -- Cast Deadly Calm
        if castable(SB.DeadlyCalm, 'target') and -spell(SB.DeadlyCalm) == 0 and talent(6,3) then
          return cast(SB.DeadlyCalm)
        end

        -- Cast Execute with Sudden Death proc
        if castable(SB.Execute, 'target') and -buff(SB.SuddenDeath) and -power.rage >= 20 then
          return cast(SB.Execute)
        end

        -- Cast Overpower to buff Mortal Strike
        if castable(SB.Overpower, 'target') and -spell(SB.Overpower) == 0 and -power.rage >= 10 then
          return cast(SB.Overpower)
        end

        -- Cast Mortal Strike to maintain Deep Wounds
        if castable(SB.MortalStrike, 'target') and -spell(SB.MortalStrike) == 0 and -power.rage >= 30 then
          return cast(SB.MortalStrike)
        end

        -- Cast Bladestorm during Colossus Smash or Test of Might (see below)
        if castable(SB.Bladestorm, 'target') and -spell(SB.Bladestorm) == 0 and -target.debuff(SB.ColossusSmashDebuff) then
          return cast(SB.Bladestorm)
        end

        -- Cast Whirlwind
        if castable(SB.Whirlwind, 'target') and -spell(SB.Whirlwind) == 0 and -power.rage >= 30 then
          return cast(SB.Whirlwind)
        end
      end

      -- Single Target - Execute phase
      if -target.health < 20 or (talent(3,1) and -target.health < 35) then
          print'ST Execute phase'

        -- Cast Skullsplitter when less than 60 Rage
        if castable(SB.Skullsplitter, 'target') and -spell(SB.Skullsplitter) == 0 and -power.rage < 60 and talent(1,3) then
          return cast(SB.Skullsplitter)
        end

--[[        -- Cast Avatar prior to Colossus Smash
        if castable(SB.Avatar, 'target') and -spell(SB.Avatar) == 0 and -spell(SB.ColossusSmash) == 0 and talent(6,2) then
          print'ST Execute'
          return cast(SB.Avatar)
        end]]

        -- Cast Ravager immediately prior to Colossus Smash
        if castable(SB.Ravager, 'target') and -spell(SB.Ravager) == 0 and -spell(SB.ColossusSmash) == 0 and talent(7,3) then
          return cast(SB.Ravager, 'player')
        end

        -- Cast Colossus Smash
        if castable(SB.ColossusSmash, 'target') and -spell(SB.ColossusSmash) == 0 then
          return cast(SB.ColossusSmash)
        end

        -- Cast Warbreaker
        if castable(SB.Warbreaker, 'target') and -spell(SB.Warbreaker) == 0 and talent(5,2) then
          return cast(SB.Warbreaker)
        end

        -- Cast Bladestorm when under 30 Rage.
        if castable(SB.Bladestorm, 'target') and -spell(SB.Bladestorm) == 0 and -power.rage < 30 then
          return cast(SB.Bladestorm)
        end

        -- Cast Deadly Calm
        if castable(SB.DeadlyCalm, 'target') and -spell(SB.DeadlyCalm) == 0 and talent(6,3) then
          return cast(SB.DeadlyCalm)
        end

        -- Cast Mortal Strike with 2 stacks of Overpower and Dreadnaught talented.
        if castable(SB.MortalStrike, 'target') and -spell(SB.MortalStrike) == 0 and buff(SB.Overpower).count == 2 and talent(7,2) and -power.rage >= 30 then
          return cast(SB.MortalStrike)
        end

        -- Cast Overpower
        if castable(SB.Overpower, 'target') and -spell(SB.Overpower) == 0 and -power.rage >= 10 then
          return cast(SB.Overpower)
        end

        -- Cast Execute
        if castable(SB.Execute, 'target') and -power.rage >= 20 then
          return cast(SB.Execute)
        end

      end

    end

    -- Multiple Target - 2 to 3
    if enemyCount == 2 or enemyCount == 3 then
        print'MultiTarget 2-3'

        -- Cast Sweeping Strikes if you are not about to use Bladestorm
        if castable(SB.SweepingStrikes, 'target') and -spell(SB.SweepingStrikes) == 0 and -spell(SB.Bladestorm) > 12 then
          return cast(SB.SweepingStrikes)
        end

        -- Cast Rend if less than 4 seconds remains, outside of Colossus Smash
        if castable(SB.Rend, 'target') and target.debuff(SB.Rend).remains < 4 and not -target.debuff(SB.ColossusSmashDebuff) and -power.rage > 30 and talent(3,3) then
          return cast(SB.Rend)
        end

        -- Cast Skullsplitter when less than 60 Rage, when Bladestorm is not about to be used.
        if castable(SB.Skullsplitter, 'target') and -spell(SB.Skullsplitter) == 0 and -spell(SB.Bladestorm) > 12 and -power.rage < 60 and talent(1,3) then
          return cast(SB.Skullsplitter)
        end

--[[        -- Cast Avatar prior to Colossus Smash
        if castable(SB.Avatar, 'target') and -spell(SB.Avatar) == 0 and -spell(SB.ColossusSmash) == 0 and talent(6,2) then
          print'MT 2-3'
          return cast(SB.Avatar)
        end]]

        -- Cast Ravager immediately prior to Colossus Smash
        if castable(SB.Ravager, 'target') and -spell(SB.Ravager) == 0 and -spell(SB.ColossusSmash) == 0 and talent(7,3) then
          return cast(SB.Ravager, 'player')
        end

        -- Cast Colossus Smash
        if castable(SB.ColossusSmash, 'target') and -spell(SB.ColossusSmash) == 0 then
          return cast(SB.ColossusSmash)
        end

        -- Cast Warbreaker
        if castable(SB.Warbreaker, 'target') and -spell(SB.Warbreaker) == 0 and talent(5,2) then
          return cast(SB.Warbreaker)
        end

        -- Cast Bladestorm during the Colossus Smash debuff
        if castable(SB.Bladestorm, 'target') and -spell(SB.Bladestorm) == 0 and -target.debuff(SB.ColossusSmashDebuff) then
          return cast(SB.Bladestorm)
        end

        -- Cast Deadly Calm
        if castable(SB.DeadlyCalm, 'target') and -spell(SB.DeadlyCalm) == 0 and talent(6,3) then
          return cast(SB.DeadlyCalm)
        end

        -- Cast Cleave to maintain Deep Wounds
        if castable(SB.Cleave, 'target') and -spell(SB.Cleave) == 0 and -power.rage >= 20 and talent(5,3) then
          return cast(SB.Cleave)
        end

        -- Cast Mortal Strike with 2 stacks of Overpower and Dreadnaught talented
        if castable(SB.MortalStrike, 'target') and -spell(SB.MortalStrike) == 0 and buff(SB.Overpower).count == 2 and talent(7,2) and -power.rage >= 30 then
          return cast(SB.MortalStrike)
        end

        -- Cast Execute
        if castable(SB.Execute, 'target') and -power.rage >= 20 then
          return cast(SB.Execute)
        end

        -- Cast Overpower
         if castable(SB.Overpower, 'target') and -spell(SB.Overpower) == 0 and -power.rage >= 10 then
          return cast(SB.Overpower)
        end

        -- Cast Mortal Strike
        if castable(SB.MortalStrike, 'target') and -spell(SB.MortalStrike) == 0 and -power.rage >= 30 then
          return cast(SB.MortalStrike)
        end

        -- Cast Slam during Sweeping Strikes
        if castable(SB.Slam, 'target') and -spell(SB.Slam) == 0 and -power.rage >= 20 and -buff(SB.SweepingStrikes) then
          return cast(SB.Slam)
        end

        -- Cast Whirlwind
        if castable(SB.Whirlwind, 'target') and -spell(SB.Whirlwind) == 0 and -power.rage >= 30 then
          return cast(SB.Whirlwind)
        end

    end

    -- Multiple Target - 4+
    if enemyCount >= 4 then
        print'MultiTarget 4+'

        -- Cast Sweeping Strikes if you are not about to use Bladestorm
        if castable(SB.SweepingStrikes, 'target') and -spell(SB.SweepingStrikes) == 0 and -spell(SB.Bladestorm) > 12 then
          return cast(SB.SweepingStrikes)
        end

        -- Cast Skullsplitter when less than 60 Rage, when Bladestorm is not about to be used.
        if castable(SB.Skullsplitter, 'target') and -spell(SB.Skullsplitter) == 0 and -spell(SB.Bladestorm) > 12 and -power.rage < 60 and talent(1,3) then
          return cast(SB.Skullsplitter)
        end

--[[        -- Cast Avatar prior to Colossus Smash
        if castable(SB.Avatar, 'target') and -spell(SB.Avatar) == 0 and -spell(SB.ColossusSmash) == 0 and talent(6,2) then
          print'MT 4+'
          return cast(SB.Avatar)
        end]]

        -- Cast Ravager immediately prior to Colossus Smash
        if castable(SB.Ravager, 'target') and -spell(SB.Ravager) == 0 and -spell(SB.ColossusSmash) == 0 and talent(7,3) then
          return cast(SB.Ravager, 'player')
        end

        -- Cast Colossus Smash
        if castable(SB.ColossusSmash, 'target') and -spell(SB.ColossusSmash) == 0 then
          return cast(SB.ColossusSmash)
        end

        -- Cast Warbreaker
        if castable(SB.Warbreaker, 'target') and -spell(SB.Warbreaker) == 0 and talent(5,2) then
          return cast(SB.Warbreaker)
        end

        -- Cast Bladestorm during the Colossus Smash debuff
        if castable(SB.Bladestorm, 'target') and -spell(SB.Bladestorm) == 0 and -target.debuff(SB.ColossusSmashDebuff) then
          return cast(SB.Bladestorm)
        end

        -- Cast Deadly Calm
        if castable(SB.DeadlyCalm, 'target') and -spell(SB.DeadlyCalm) == 0 and talent(6,3) then
          return cast(SB.DeadlyCalm)
        end

        -- Cast Cleave to maintain Deep Wounds
        if castable(SB.Cleave, 'target') and -spell(SB.Cleave) == 0 and -power.rage >= 20 and talent(5,3) then
          return cast(SB.Cleave)
        end

        -- Cast Execute during Sweeping Strikes
         if castable(SB.Execute, 'target') and -spell(SB.Execute) == 0 and -power.rage >= 20 and -buff(SB.SweepingStrikes) then
          return cast(SB.Execute)
        end

        -- Cast Mortal Strike during Sweeping Strikes
         if castable(SB.MortalStrike, 'target') and -spell(SB.MortalStrike) == 0 and -power.rage >= 30 and -buff(SB.SweepingStrikes) then
          return cast(SB.MortalStrike)
        end

        -- Cast Whirlwind during Colossus Smash
         if castable(SB.Whirlwind, 'target') and -spell(SB.Whirlwind) == 0 and -power.rage >= 30 and -target.debuff(SB.ColossusSmashDebuff) then
          return cast(SB.Whirlwind)
        end

        -- Cast Overpower
         if castable(SB.Overpower, 'target') and -spell(SB.Overpower) == 0 and -power.rage >= 10 then
          return cast(SB.Overpower)
        end

        -- Cast Whirlwind
         if castable(SB.Whirlwind, 'target') and -spell(SB.Whirlwind) == 0 and -power.rage >= 30 then
          return cast(SB.Whirlwind)
        end

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
  local autojoin = dark_addon.settings.fetch('armswar_settings_autojoin', true)


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

  -- Heroic Leap OOC
  if modifier.shift and castable(SB.HeroicLeap) then
      return cast(SB.HeroicLeap, 'ground')
  end

end

local function interface()

    local settings = {
        key = 'armswar_settings',
        title = 'Arms Warrior',
        width = 300,
        height = 500,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = "                Rex's Arms Warrior Settings" },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine' },
            { type = 'text', text = 'Suggested Talents - 3 1 2 3 2 2 1' },
            { type = 'text', text = 'If you want automatic AOE then please remember to turn on EnemyNamePlates in WoW (V key)' },
            { type = 'text', text = 'Shift Modifier used for Heroic Leap' },
            { type = 'text', text = 'Avatar is controlled by the Cooldowns toggle on the interface (and waits for Colossus Smash to come off Cooldown before casting)' },
            { type = 'text', text = 'If you use Defensive Stance Talent use the Toggle On/Off on the interface' },
            { type = 'rule' },
            { type = 'text', text = 'Interrupt Settings' },
            { key = 'intpercentlow', type = 'spinner', text = 'Interrupt Low %', default = '50', desc = 'low% cast time to interrupt at', min = 5, max = 50, step = 1 },
            { key = 'intpercenthigh', type = 'spinner', text = 'Interrupt High %', default = '65', desc = 'high% cast time to interrupt at', min = 51, max = 100, step = 1 },
            { key = 'StormBoltInt', type = 'checkbox', text = 'Storm Bolt as an interrupt', desc = '', default = true },
            { type = 'text', text = 'Defensive Settings' },
            { key = 'DBTSHealth', type = 'spinner', text = 'Die by the Sword at Health %', default = '60', desc = 'cast Die by the Sword at', min = 0, max = 100, step = 1 },
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
    dark_addon.interface.buttons.add_toggle({
        name = 'defensivestance',
        label = 'Defensive Stance',
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
  spec = dark_addon.rotation.classes.warrior.arms,
  name = 'armswarpal',
  label = 'Pal Project: Arms Warrior',
  combat = combat,
  resting = resting,
  interface = interface
})
